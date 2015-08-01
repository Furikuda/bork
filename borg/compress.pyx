import zlib

from libc.stdlib cimport malloc, free


cdef extern from "lz4.h":
    int LZ4_compress_limitedOutput(const char* source, char* dest, int inputSize, int maxOutputSize) nogil
    int LZ4_decompress_safe(const char* source, char* dest, int inputSize, int maxOutputSize) nogil


cdef class CompressorBase:
    """
    base class for all (de)compression classes,
    also handles compression format auto detection and
    adding/stripping the ID header (which enable auto detection).
    """
    ID = b'\xFF\xFF'  # reserved and not used
                      # overwrite with a unique 2-bytes bytestring in child classes
    name = 'baseclass'

    @classmethod
    def detect(cls, data):
        return data.startswith(cls.ID)

    def __init__(self, **kwargs):
        pass

    def compress(self, data):
        # add ID bytes
        return self.ID + data

    def decompress(self, data):
        # strip ID bytes
        return data[2:]


class CNULL(CompressorBase):
    """
    null compression, just pass through data
    """
    ID = b'\x00\x00'
    name = 'null'
    # base class does all we need


cdef class LZ4(CompressorBase):
    """
    raw LZ4 compression / decompression (liblz4).

    Features:
        - lz4 is super fast
        - wrapper releases CPython's GIL to support multithreaded code
        - buffer given by caller, avoiding frequent reallocation and buffer duplication
        - uses safe lz4 methods that never go beyond the end of the output buffer

    But beware:
        - this is not very generic, the given buffer MUST be large enough to
          handle all compression or decompression output (or it will fail).
        - you must not do method calls to the same LZ4 instance from different
          threads at the same time - create one LZ4 instance per thread!
    """
    ID = b'\x01\x00'
    name = 'lz4'

    cdef char *buffer  # helper buffer for (de)compression output
    cdef int bufsize  # size of this buffer

    def __cinit__(self, **kwargs):
        buffer = kwargs['buffer']
        self.buffer = buffer
        self.bufsize = len(buffer)

    def compress(self, idata):
        cdef int isize = len(idata)
        cdef int osize = self.bufsize
        cdef char *source = idata
        cdef char *dest = self.buffer
        with nogil:
            osize = LZ4_compress_limitedOutput(source, dest, isize, osize)
        if not osize:
            raise Exception('lz4 compress failed')
        return super().compress(dest[:osize])

    def decompress(self, idata):
        idata = super().decompress(idata)
        cdef int isize = len(idata)
        cdef int osize = self.bufsize
        cdef char *source = idata
        cdef char *dest = self.buffer
        with nogil:
            osize = LZ4_decompress_safe(source, dest, isize, osize)
        if osize < 0:
            # malformed input data, buffer too small, ...
            raise Exception('lz4 decompress failed')
        return dest[:osize]


class ZLIB(CompressorBase):
    """
    zlib compression / decompression (python stdlib)
    """
    ID = b'\x08\x00'  # not used here, see detect()
                      # avoid all 0x.8.. IDs elsewhere!
    name = 'zlib'

    @classmethod
    def detect(cls, data):
        # matches misc. patterns 0x.8.. used by zlib
        cmf, flg = data[:2]
        is_deflate = cmf & 0x0f == 8
        check_ok = (cmf * 256 + flg) % 31 == 0
        return check_ok and is_deflate

    def __init__(self, level=6, **kwargs):
        super().__init__(**kwargs)
        self.level = level

    def compress(self, data):
        # note: for compatibility no super call, do not add ID bytes
        return zlib.compress(data, self.level)

    def decompress(self, data):
        # note: for compatibility no super call, do not strip ID bytes
        return zlib.decompress(data)


COMPRESSOR_TABLE = {
    CNULL.name: CNULL,
    LZ4.name: LZ4,
    ZLIB.name: ZLIB,
}
COMPRESSOR_LIST = [LZ4, CNULL, ZLIB, ]  # check fast stuff first

def get_compressor(name, **kwargs):
    cls = COMPRESSOR_TABLE[name]
    return cls(**kwargs)


class Compressor:
    """
    compresses using a compressor with given name and parameters
    decompresses everything we can handle (autodetect)
    """
    def __init__(self, name='zlib', **kwargs):
        self.params = kwargs
        self.compressor = get_compressor(name, **self.params)

    def compress(self, data):
        return self.compressor.compress(data)

    def decompress(self, data):
        for cls in COMPRESSOR_LIST:
            if cls.detect(data):
                return cls(**self.params).decompress(data)
        else:
            raise ValueError('No decompressor for this data found: %r.', data[:2])
