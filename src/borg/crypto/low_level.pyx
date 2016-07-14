"""An AEAD style OpenSSL wrapper

Note: AES-GCM mode needs OpenSSL >= 1.0.1d due to bug fixes in OpenSSL.

API:

    encrypt(data, header=b'', aad_offset=0) -> envelope
    decrypt(envelope, header_len=0, aad_offset=0) -> data

Envelope layout:

|<--------------------------- envelope ------------------------------------------>|
|<------------ header ----------->|<---------- ciphersuite specific ------------->|
|<-- not auth data -->|<-- aad -->|<-- e.g.:  S(aad, iv, E(data)), iv, E(data) -->|

|--- #aad_offset ---->|
|------------- #header_len ------>|

S means a cryptographic signature function (like HMAC or GMAC).
E means a encryption function (like AES).
iv is the initialization vector / nonce, if needed.

The split of header into not authenticated data and aad (additional authenticated
data) is done to support the legacy envelope layout as used in attic and early borg
(where the TYPE byte was not authenticated) and avoid unneeded memcpy and string
garbage.

Newly designed envelope layouts can just authenticate the whole header.

IV handling:

    iv = ...  # just never repeat!
    cs = CS(hmac_key, enc_key, iv=iv)
    envelope = cs.encrypt(data, header, aad_offset)
    iv = cs.next_iv(len(data))
    (repeat)
"""

# TODO: get rid of small malloc
# as @enkore mentioned on github:
# "Since we do many small-object allocations here it is probably better to use
# PyMem_Alloc/Free instead of malloc/free (PyMem has many optimizations for
# small allocs)."
#
# Small mallocs currently happen if the total input file length is small, so
# the 1 chunk's size is less than what the chunker would produce for big files.

import hashlib
import hmac
from math import ceil

from libc.stdlib cimport malloc, free
from cpython.buffer cimport PyBUF_SIMPLE, PyObject_GetBuffer, PyBuffer_Release
from cpython.bytes cimport PyBytes_FromStringAndSize

API_VERSION = '1.1_02'

cdef extern from "openssl/crypto.h":
    int CRYPTO_memcmp(const void *a, const void *b, size_t len)

cdef extern from "../algorithms/blake2-libselect.h":
    ctypedef struct blake2b_state:
        pass

    int blake2b_init(blake2b_state *S, size_t outlen) nogil
    int blake2b_update(blake2b_state *S, const void *input, size_t inlen) nogil
    int blake2b_final(blake2b_state *S, void *out, size_t outlen) nogil


cdef extern from "openssl/evp.h":
    ctypedef struct EVP_MD:
        pass
    ctypedef struct EVP_CIPHER:
        pass
    ctypedef struct EVP_CIPHER_CTX:
        pass
    ctypedef struct ENGINE:
        pass

    const EVP_CIPHER *EVP_aes_256_ctr()
    const EVP_CIPHER *EVP_aes_256_gcm()

    void EVP_CIPHER_CTX_init(EVP_CIPHER_CTX *a)
    void EVP_CIPHER_CTX_cleanup(EVP_CIPHER_CTX *a)

    int EVP_EncryptInit_ex(EVP_CIPHER_CTX *ctx, const EVP_CIPHER *cipher, ENGINE *impl,
                           const unsigned char *key, const unsigned char *iv)
    int EVP_DecryptInit_ex(EVP_CIPHER_CTX *ctx, const EVP_CIPHER *cipher, ENGINE *impl,
                           const unsigned char *key, const unsigned char *iv)
    int EVP_EncryptUpdate(EVP_CIPHER_CTX *ctx, unsigned char *out, int *outl,
                          const unsigned char *in_, int inl)
    int EVP_DecryptUpdate(EVP_CIPHER_CTX *ctx, unsigned char *out, int *outl,
                          const unsigned char *in_, int inl)
    int EVP_EncryptFinal_ex(EVP_CIPHER_CTX *ctx, unsigned char *out, int *outl)
    int EVP_DecryptFinal_ex(EVP_CIPHER_CTX *ctx, unsigned char *out, int *outl)

    int EVP_CIPHER_CTX_ctrl(EVP_CIPHER_CTX *ctx, int type, int arg, void *ptr)
    int EVP_CTRL_GCM_GET_TAG
    int EVP_CTRL_GCM_SET_TAG
    int EVP_CTRL_GCM_SET_IVLEN

    const EVP_MD *EVP_sha256() nogil

    EVP_CIPHER_CTX *EVP_CIPHER_CTX_new()
    void EVP_CIPHER_CTX_free(EVP_CIPHER_CTX *a)

cdef extern from "openssl/hmac.h":
    ctypedef struct HMAC_CTX:
        pass

    void HMAC_CTX_init(HMAC_CTX *ctx)
    void HMAC_CTX_cleanup(HMAC_CTX *ctx)

    HMAC_CTX *HMAC_CTX_new()
    void HMAC_CTX_free(HMAC_CTX *a)

    int HMAC_Init_ex(HMAC_CTX *ctx, const void *key, int key_len, const EVP_MD *md, ENGINE *impl)
    int HMAC_Update(HMAC_CTX *ctx, const unsigned char *data, int len)
    int HMAC_Final(HMAC_CTX *ctx, unsigned char *md, unsigned int *len)

    unsigned char *HMAC(const EVP_MD *evp_md,
                    const void *key, int key_len,
                    const unsigned char *data, int data_len,
                    unsigned char *md, unsigned int *md_len) nogil

cdef extern from "_crypto_helpers.h":
    ctypedef struct HMAC_CTX:
        pass

    HMAC_CTX *HMAC_CTX_new()
    void HMAC_CTX_free(HMAC_CTX *a)


import struct

_int = struct.Struct('>I')
_long = struct.Struct('>Q')
_2long = struct.Struct('>QQ')

bytes_to_int = lambda x, offset=0: _int.unpack_from(x, offset)[0]
bytes_to_long = lambda x, offset=0: _long.unpack_from(x, offset)[0]
long_to_bytes = lambda x: _long.pack(x)


def bytes16_to_int(b, offset=0):
    h, l = _2long.unpack_from(b, offset)
    return (h << 64) + l


def int_to_bytes16(i):
    max_uint64 = 0xffffffffffffffff
    l = i & max_uint64
    h = (i >> 64) & max_uint64
    return _2long.pack(h, l)


def increment_iv(iv, amount=1):
    """
    Increment the IV by the given amount (default 1).

    :param iv: input IV, 16 bytes (128 bit)
    :param amount: increment value
    :return: input_IV + amount, 16 bytes (128 bit)
    """
    assert len(iv) == 16
    iv = bytes16_to_int(iv)
    iv += amount
    iv = int_to_bytes16(iv)
    return iv


def num_aes_blocks(length):
    """Return the number of AES blocks required to encrypt/decrypt *length* bytes of data.
       Note: this is only correct for modes without padding, like AES-CTR.
    """
    return (length + 15) // 16


class CryptoError(Exception):
    """Malfunction in the crypto module."""


class IntegrityError(CryptoError):
    """Integrity checks failed. Corrupted or tampered data."""


cdef Py_buffer ro_buffer(object data) except *:
    cdef Py_buffer view
    PyObject_GetBuffer(data, &view, PyBUF_SIMPLE)
    return view


cdef class AES256_CTR_HMAC_SHA256:
    # Layout: HEADER + HMAC 32 + IV 8 + CT (same as attic / borg < 1.2 IF HEADER = TYPE_BYTE, no AAD)

    cdef EVP_CIPHER_CTX *ctx
    cdef HMAC_CTX *hmac_ctx
    cdef unsigned char *mac_key
    cdef unsigned char *enc_key
    cdef unsigned char iv[16]
    cdef long long blocks

    def __init__(self, mac_key, enc_key, iv=None):
        assert isinstance(mac_key, bytes) and len(mac_key) == 32
        assert isinstance(enc_key, bytes) and len(enc_key) == 32
        assert iv is None or isinstance(iv, bytes) and len(iv) == 16
        self.mac_key = mac_key
        self.enc_key = enc_key
        if iv is not None:
            self.set_iv(iv)

    def __cinit__(self, mac_key, enc_key, iv=None):
        self.ctx = EVP_CIPHER_CTX_new()
        self.hmac_ctx = HMAC_CTX_new()

    def __dealloc__(self):
        EVP_CIPHER_CTX_free(self.ctx)
        HMAC_CTX_free(self.hmac_ctx)

    def encrypt(self, data, header=b'', aad_offset=0):
        """
        encrypt data, compute mac over aad + iv + cdata, prepend header.
        aad_offset is the offset into the header where aad starts.
        """
        cdef int ilen = len(data)
        cdef int hlen = len(header)
        cdef int aoffset = aad_offset
        cdef int alen = hlen - aoffset
        cdef unsigned char *odata = <unsigned char *>malloc(hlen + 32 + 8 + ilen + 16)
        if not odata:
            raise MemoryError
        cdef int olen
        cdef int offset
        cdef Py_buffer idata = ro_buffer(data)
        cdef Py_buffer hdata = ro_buffer(header)
        try:
            offset = 0
            for i in range(hlen):
                odata[offset+i] = header[i]
            offset += hlen
            offset += 32
            self.store_iv(odata+offset, self.iv)
            offset += 8
            rc = EVP_EncryptInit_ex(self.ctx, EVP_aes_256_ctr(), NULL, self.enc_key, self.iv)
            if not rc:
                raise CryptoError('EVP_EncryptInit_ex failed')
            rc = EVP_EncryptUpdate(self.ctx, odata+offset, &olen, <const unsigned char*> idata.buf, ilen)
            if not rc:
                raise CryptoError('EVP_EncryptUpdate failed')
            offset += olen
            rc = EVP_EncryptFinal_ex(self.ctx, odata+offset, &olen)
            if not rc:
                raise CryptoError('EVP_EncryptFinal_ex failed')
            offset += olen
            if not HMAC_Init_ex(self.hmac_ctx, self.mac_key, 32, EVP_sha256(), NULL):
                raise CryptoError('HMAC_Init_ex failed')
            if not HMAC_Update(self.hmac_ctx, <const unsigned char *> hdata.buf+aoffset, alen):
                raise CryptoError('HMAC_Update failed')
            if not HMAC_Update(self.hmac_ctx, odata+hlen+32, offset-hlen-32):
                raise CryptoError('HMAC_Update failed')
            if not HMAC_Final(self.hmac_ctx, odata+hlen, NULL):
                raise CryptoError('HMAC_Final failed')
            self.blocks += num_aes_blocks(ilen)
            return odata[:offset]
        finally:
            free(odata)
            PyBuffer_Release(&hdata)
            PyBuffer_Release(&idata)

    def decrypt(self, envelope, header_len=0, aad_offset=0):
        """
        authenticate aad + iv + cdata, decrypt cdata, ignore header bytes up to aad_offset.
        """
        cdef int ilen = len(envelope)
        cdef int hlen = header_len
        cdef int aoffset = aad_offset
        cdef int alen = hlen - aoffset
        cdef unsigned char *odata = <unsigned char *>malloc(ilen + 16)
        if not odata:
            raise MemoryError
        cdef int olen
        cdef int offset
        cdef unsigned char hmac_buf[32]
        cdef Py_buffer idata = ro_buffer(envelope)
        try:
            if not HMAC_Init_ex(self.hmac_ctx, self.mac_key, 32, EVP_sha256(), NULL):
                raise CryptoError('HMAC_Init_ex failed')
            if not HMAC_Update(self.hmac_ctx, <const unsigned char *> idata.buf+aoffset, alen):
                raise CryptoError('HMAC_Update failed')
            if not HMAC_Update(self.hmac_ctx, <const unsigned char *> idata.buf+hlen+32, ilen-hlen-32):
                raise CryptoError('HMAC_Update failed')
            if not HMAC_Final(self.hmac_ctx, hmac_buf, NULL):
                raise CryptoError('HMAC_Final failed')
            if CRYPTO_memcmp(hmac_buf, idata.buf+hlen, 32):
                raise IntegrityError('HMAC Authentication failed')
            iv = self.fetch_iv(<unsigned char *> idata.buf+hlen+32)
            self.set_iv(iv)
            if not EVP_DecryptInit_ex(self.ctx, EVP_aes_256_ctr(), NULL, self.enc_key, iv):
                raise CryptoError('EVP_DecryptInit_ex failed')
            offset = 0
            rc = EVP_DecryptUpdate(self.ctx, odata+offset, &olen, <const unsigned char*> idata.buf+hlen+32+8, ilen-hlen-32-8)
            if not rc:
                raise CryptoError('EVP_DecryptUpdate failed')
            offset += olen
            rc = EVP_DecryptFinal_ex(self.ctx, odata+offset, &olen)
            if rc <= 0:
                raise CryptoError('EVP_DecryptFinal_ex failed')
            offset += olen
            self.blocks += num_aes_blocks(offset)
            return odata[:offset]
        finally:
            free(odata)
            PyBuffer_Release(&idata)

    def set_iv(self, iv):
        self.blocks = 0  # how many AES blocks got encrypted with this IV?
        for i in range(16):
            self.iv[i] = iv[i]

    def next_iv(self):
        return increment_iv(self.iv[:16], self.blocks)

    cdef fetch_iv(self, unsigned char * iv_in):
        # fetch lower 8 bytes of iv and add upper 8 zero bytes
        return b"\0" * 8 + iv_in[0:8]

    cdef store_iv(self, unsigned char * iv_out, unsigned char * iv):
        # store only lower 8 bytes, upper 8 bytes are assumed to be 0
        cdef int i
        for i in range(8):
            iv_out[i] = iv[8+i]


cdef class AES256_GCM:
    # Layout: HEADER + GMAC 16 + IV 12 + CT

    cdef EVP_CIPHER_CTX *ctx
    cdef unsigned char *enc_key
    cdef unsigned char iv[12]
    cdef long long blocks

    def __init__(self, mac_key, enc_key, iv=None):
        assert mac_key is None
        assert isinstance(enc_key, bytes) and len(enc_key) == 32
        assert iv is None or isinstance(iv, bytes) and len(iv) == 12
        self.enc_key = enc_key
        if iv is not None:
            self.set_iv(iv)

    def __cinit__(self, mac_key, enc_key, iv=None):
        self.ctx = EVP_CIPHER_CTX_new()

    def __dealloc__(self):
        EVP_CIPHER_CTX_free(self.ctx)

    def encrypt(self, data, header=b'', aad_offset=0):
        """
        encrypt data, compute mac over aad + iv + cdata, prepend header.
        aad_offset is the offset into the header where aad starts.
        """
        cdef int ilen = len(data)
        cdef int hlen = len(header)
        cdef int aoffset = aad_offset
        cdef int alen = hlen - aoffset
        cdef unsigned char *odata = <unsigned char *>malloc(hlen + 16 + 12 + ilen + 16)
        if not odata:
            raise MemoryError
        cdef int olen
        cdef int offset
        cdef Py_buffer idata = ro_buffer(data)
        cdef Py_buffer hdata = ro_buffer(header)
        try:
            offset = 0
            for i in range(hlen):
                odata[offset+i] = header[i]
            offset += hlen
            offset += 16
            self.store_iv(odata+offset, self.iv)
            rc = EVP_EncryptInit_ex(self.ctx, EVP_aes_256_gcm(), NULL, NULL, NULL)
            if not rc:
                raise CryptoError('EVP_EncryptInit_ex failed')
            if not EVP_CIPHER_CTX_ctrl(self.ctx, EVP_CTRL_GCM_SET_IVLEN, 12, NULL):
                raise CryptoError('EVP_CIPHER_CTX_ctrl SET IVLEN failed')
            rc = EVP_EncryptInit_ex(self.ctx, NULL, NULL, self.enc_key, self.iv)
            if not rc:
                raise CryptoError('EVP_EncryptInit_ex failed')
            rc = EVP_EncryptUpdate(self.ctx, NULL, &olen, <const unsigned char*> hdata.buf+aoffset, alen)
            if not rc:
                raise CryptoError('EVP_EncryptUpdate failed')
            if not EVP_EncryptUpdate(self.ctx, NULL, &olen, odata+offset, 12):
                raise CryptoError('EVP_EncryptUpdate failed')
            offset += 12
            rc = EVP_EncryptUpdate(self.ctx, odata+offset, &olen, <const unsigned char*> idata.buf, ilen)
            if not rc:
                raise CryptoError('EVP_EncryptUpdate failed')
            offset += olen
            rc = EVP_EncryptFinal_ex(self.ctx, odata+offset, &olen)
            if not rc:
                raise CryptoError('EVP_EncryptFinal_ex failed')
            offset += olen
            if not EVP_CIPHER_CTX_ctrl(self.ctx, EVP_CTRL_GCM_GET_TAG, 16, odata+hlen):
                raise CryptoError('EVP_CIPHER_CTX_ctrl GET TAG failed')
            self.blocks += num_aes_blocks(ilen)
            return odata[:offset]
        finally:
            free(odata)
            PyBuffer_Release(&hdata)
            PyBuffer_Release(&idata)

    def decrypt(self, envelope, header_len=0, aad_offset=0):
        """
        authenticate aad + iv + cdata, decrypt cdata, ignore header bytes up to aad_offset.
        """
        cdef int ilen = len(envelope)
        cdef int hlen = header_len
        cdef int aoffset = aad_offset
        cdef int alen = hlen - aoffset
        cdef unsigned char *odata = <unsigned char *>malloc(ilen + 16)
        if not odata:
            raise MemoryError
        cdef int olen
        cdef int offset
        cdef Py_buffer idata = ro_buffer(envelope)
        try:
            if not EVP_DecryptInit_ex(self.ctx, EVP_aes_256_gcm(), NULL, NULL, NULL):
                raise CryptoError('EVP_DecryptInit_ex failed')
            iv = self.fetch_iv(<unsigned char *> idata.buf+hlen+16)
            self.set_iv(iv)
            if not EVP_CIPHER_CTX_ctrl(self.ctx, EVP_CTRL_GCM_SET_IVLEN, 12, NULL):
                raise CryptoError('EVP_CIPHER_CTX_ctrl SET IVLEN failed')
            if not EVP_DecryptInit_ex(self.ctx, NULL, NULL, self.enc_key, iv):
                raise CryptoError('EVP_DecryptInit_ex failed')
            if not EVP_CIPHER_CTX_ctrl(self.ctx, EVP_CTRL_GCM_SET_TAG, 16, <void *> idata.buf+hlen):
                raise CryptoError('EVP_CIPHER_CTX_ctrl SET TAG failed')
            rc = EVP_DecryptUpdate(self.ctx, NULL, &olen, <const unsigned char*> idata.buf+aoffset, alen)
            if not rc:
                raise CryptoError('EVP_DecryptUpdate failed')
            if not EVP_DecryptUpdate(self.ctx, NULL, &olen, <const unsigned char*> idata.buf+hlen+16, 12):
                raise CryptoError('EVP_DecryptUpdate failed')
            offset = 0
            rc = EVP_DecryptUpdate(self.ctx, odata+offset, &olen, <const unsigned char*> idata.buf+hlen+16+12, ilen-hlen-16-12)
            if not rc:
                raise CryptoError('EVP_DecryptUpdate failed')
            offset += olen
            rc = EVP_DecryptFinal_ex(self.ctx, odata+offset, &olen)
            if rc <= 0:
                # a failure here means corrupted or tampered tag (mac) or data.
                raise IntegrityError('GCM Authentication / EVP_DecryptFinal_ex failed')
            offset += olen
            self.blocks += num_aes_blocks(offset)
            return odata[:offset]
        finally:
            free(odata)
            PyBuffer_Release(&idata)

    def set_iv(self, iv):
        self.blocks = 0  # number of AES blocks encrypted with this IV
        for i in range(12):
            self.iv[i] = iv[i]

    def next_iv(self):
        assert self.blocks < 2**32
        # we need 16 bytes for increment_iv:
        last_iv = b'\0\0\0\0' + self.iv[:12]
        # gcm mode is special: it appends a internal 32bit counter to the 96bit (12 byte) we provide, thus we only
        # need to increment the 96bit counter by 1 (and we must not encrypt more than 2^32 AES blocks with same IV):
        next_iv = increment_iv(last_iv, 1)
        return next_iv[-12:]

    cdef fetch_iv(self, unsigned char * iv_in):
        return iv_in[0:12]

    cdef store_iv(self, unsigned char * iv_out, unsigned char * iv):
        cdef int i
        for i in range(12):
            iv_out[i] = iv[i]


def hmac_sha256(key, data):
    cdef Py_buffer data_buf = ro_buffer(data)
    cdef const unsigned char *key_ptr = key
    cdef int key_len = len(key)
    cdef unsigned char md[32]
    try:
        with nogil:
            rc = HMAC(EVP_sha256(), key_ptr, key_len, <const unsigned char*> data_buf.buf, data_buf.len, md, NULL)
        if rc != md:
            raise CryptoError('HMAC(EVP_sha256) failed')
    finally:
        PyBuffer_Release(&data_buf)
    return PyBytes_FromStringAndSize(<char*> &md[0], 32)


cdef blake2b_update_from_buffer(blake2b_state *state, obj):
    cdef Py_buffer buf = ro_buffer(obj)
    try:
        with nogil:
            rc = blake2b_update(state, buf.buf, buf.len)
        if rc == -1:
            raise Exception('blake2b_update() failed')
    finally:
        PyBuffer_Release(&buf)


def blake2b_256(key, data):
    cdef blake2b_state state
    if blake2b_init(&state, 32) == -1:
        raise Exception('blake2b_init() failed')

    cdef unsigned char md[32]
    cdef unsigned char *key_ptr = key

    # This is secure, because BLAKE2 is not vulnerable to length-extension attacks (unlike SHA-1/2, MD-5 and others).
    # See the BLAKE2 paper section 2.9 "Keyed hashing (MAC and PRF)" for details.
    # A nice benefit is that this simpler prefix-MAC mode has less overhead than the more complex HMAC mode.
    # We don't use the BLAKE2 parameter block (via blake2s_init_key) for this to
    # avoid incompatibility with the limited API of OpenSSL.
    rc = blake2b_update(&state, key_ptr, len(key))
    if rc == -1:
        raise Exception('blake2b_update() failed')
    blake2b_update_from_buffer(&state, data)

    rc = blake2b_final(&state, &md[0], 32)
    if rc == -1:
        raise Exception('blake2b_final() failed')

    return PyBytes_FromStringAndSize(<char*> &md[0], 32)


def blake2b_128(data):
    cdef blake2b_state state
    cdef unsigned char md[16]
    cdef unsigned char *data_ptr = data

    if blake2b_init(&state, 16) == -1:
        raise Exception('blake2b_init() failed')

    rc = blake2b_update(&state, data_ptr, len(data))
    if rc == -1:
        raise Exception('blake2b_update() failed')

    rc = blake2b_final(&state, &md[0], 16)
    if rc == -1:
        raise Exception('blake2b_final() failed')

    return PyBytes_FromStringAndSize(<char*> &md[0], 16)


def hkdf_hmac_sha512(ikm, salt, info, output_length):
    """
    Compute HKDF-HMAC-SHA512 with input key material *ikm*, *salt* and *info* to produce *output_length* bytes.

    This is the "HMAC-based Extract-and-Expand Key Derivation Function (HKDF)" (RFC 5869)
    instantiated with HMAC-SHA512.

    *output_length* must not be greater than 64 * 255 bytes.
    """
    digest_length = 64
    assert output_length <= (255 * digest_length), 'output_length must be <= 255 * 64 bytes'
    # Step 1. HKDF-Extract (ikm, salt) -> prk
    if salt is None:
        salt = bytes(64)
    prk = hmac.HMAC(salt, ikm, hashlib.sha512).digest()

    # Step 2. HKDF-Expand (prk, info, output_length) -> output key
    n = ceil(output_length / digest_length)
    t_n = b''
    output = b''
    for i in range(n):
        msg = t_n + info + (i + 1).to_bytes(1, 'little')
        t_n = hmac.HMAC(prk, msg, hashlib.sha512).digest()
        output += t_n
    return output[:output_length]
