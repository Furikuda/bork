# -*- coding: utf-8 -*-
from collections import namedtuple
import locale
import os

cimport cython
from libc.stdint cimport uint32_t, UINT32_MAX, uint64_t
from libc.errno cimport errno
from cpython.exc cimport PyErr_SetFromErrnoWithFilename

API_VERSION = '1.1_02'


cdef extern from "_hashindex.c":
    ctypedef struct HashIndex:
        pass

    HashIndex *hashindex_read(object file_py) except *
    HashIndex *hashindex_init(int capacity, int key_size, int value_size)
    void hashindex_free(HashIndex *index)
    int hashindex_len(HashIndex *index)
    int hashindex_size(HashIndex *index)
    void hashindex_write(HashIndex *index, object file_py) except *
    void *hashindex_get(HashIndex *index, void *key)
    void *hashindex_next_key(HashIndex *index, void *key)
    int hashindex_delete(HashIndex *index, void *key)
    int hashindex_set(HashIndex *index, void *key, void *value)
    uint32_t _htole32(uint32_t v)
    uint32_t _le32toh(uint32_t v)

    double HASH_MAX_LOAD


cdef extern from "cache_sync/cache_sync.c":
    ctypedef struct CacheSyncCtx:
        pass

    CacheSyncCtx *cache_sync_init(HashIndex *chunks)
    const char *cache_sync_error(CacheSyncCtx *ctx)
    int cache_sync_feed(CacheSyncCtx *ctx, void *data, uint32_t length)
    void cache_sync_free(CacheSyncCtx *ctx)

    uint32_t _MAX_VALUE


cdef _NoDefault = object()

"""
The HashIndex is *not* a general purpose data structure. The value size must be at least 4 bytes, and these
first bytes are used for in-band signalling in the data structure itself.

The constant MAX_VALUE defines the valid range for these 4 bytes when interpreted as an uint32_t from 0
to MAX_VALUE (inclusive). The following reserved values beyond MAX_VALUE are currently in use
(byte order is LE)::

    0xffffffff marks empty entries in the hashtable
    0xfffffffe marks deleted entries in the hashtable

None of the publicly available classes in this module will accept nor return a reserved value;
AssertionError is raised instead.
"""

assert UINT32_MAX == 2**32-1

assert _MAX_VALUE % 2 == 1


@cython.internal
cdef class IndexBase:
    cdef HashIndex *index
    cdef int key_size

    MAX_LOAD_FACTOR = HASH_MAX_LOAD
    MAX_VALUE = _MAX_VALUE

    def __cinit__(self, capacity=0, path=None, key_size=32):
        self.key_size = key_size
        if path:
            if isinstance(path, (str, bytes)):
                with open(path, 'rb') as fd:
                    self.index = hashindex_read(fd)
            else:
                self.index = hashindex_read(path)
            assert self.index, 'hashindex_read() returned NULL with no exception set'
        else:
            self.index = hashindex_init(capacity, self.key_size, self.value_size)
            if not self.index:
                raise Exception('hashindex_init failed')

    def __dealloc__(self):
        if self.index:
            hashindex_free(self.index)

    @classmethod
    def read(cls, path):
        return cls(path=path)

    def write(self, path):
        if isinstance(path, (str, bytes)):
            with open(path, 'wb') as fd:
                hashindex_write(self.index, fd)
        else:
            hashindex_write(self.index, path)

    def clear(self):
        hashindex_free(self.index)
        self.index = hashindex_init(0, self.key_size, self.value_size)
        if not self.index:
            raise Exception('hashindex_init failed')

    def setdefault(self, key, value):
        if not key in self:
            self[key] = value

    def __delitem__(self, key):
        assert len(key) == self.key_size
        if not hashindex_delete(self.index, <char *>key):
            raise Exception('hashindex_delete failed')

    def get(self, key, default=None):
        try:
            return self[key]
        except KeyError:
            return default

    def pop(self, key, default=_NoDefault):
        try:
            value = self[key]
            del self[key]
            return value
        except KeyError:
            if default != _NoDefault:
                return default
            raise

    def __len__(self):
        return hashindex_len(self.index)

    def size(self):
        """Return size (bytes) of hash table."""
        return hashindex_size(self.index)


cdef class NSIndex(IndexBase):

    value_size = 8

    def __getitem__(self, key):
        assert len(key) == self.key_size
        data = <uint32_t *>hashindex_get(self.index, <char *>key)
        if not data:
            raise KeyError(key)
        cdef uint32_t segment = _le32toh(data[0])
        assert segment <= _MAX_VALUE, "maximum number of segments reached"
        return segment, _le32toh(data[1])

    def __setitem__(self, key, value):
        assert len(key) == self.key_size
        cdef uint32_t[2] data
        cdef uint32_t segment = value[0]
        assert segment <= _MAX_VALUE, "maximum number of segments reached"
        data[0] = _htole32(segment)
        data[1] = _htole32(value[1])
        if not hashindex_set(self.index, <char *>key, data):
            raise Exception('hashindex_set failed')

    def __contains__(self, key):
        cdef uint32_t segment
        assert len(key) == self.key_size
        data = <uint32_t *>hashindex_get(self.index, <char *>key)
        if data != NULL:
            segment = _le32toh(data[0])
            assert segment <= _MAX_VALUE, "maximum number of segments reached"
        return data != NULL

    def iteritems(self, marker=None):
        cdef const void *key
        iter = NSKeyIterator(self.key_size)
        iter.idx = self
        iter.index = self.index
        if marker:
            key = hashindex_get(self.index, <char *>marker)
            if marker is None:
                raise IndexError
            iter.key = key - self.key_size
        return iter


cdef class NSKeyIterator:
    cdef NSIndex idx
    cdef HashIndex *index
    cdef const void *key
    cdef int key_size
    cdef int exhausted

    def __cinit__(self, key_size):
        self.key = NULL
        self.key_size = key_size
        self.exhausted = 0

    def __iter__(self):
        return self

    def __next__(self):
        if self.exhausted:
            raise StopIteration
        self.key = hashindex_next_key(self.index, <char *>self.key)
        if not self.key:
            self.exhausted = 1
            raise StopIteration
        cdef uint32_t *value = <uint32_t *>(self.key + self.key_size)
        cdef uint32_t segment = _le32toh(value[0])
        assert segment <= _MAX_VALUE, "maximum number of segments reached"
        return (<char *>self.key)[:self.key_size], (segment, _le32toh(value[1]))


ChunkIndexEntry = namedtuple('ChunkIndexEntry', 'refcount size csize')


cdef class ChunkIndex(IndexBase):
    """
    Mapping of 32 byte keys to (refcount, size, csize), which are all 32-bit unsigned.

    The reference count cannot overflow. If an overflow would occur, the refcount
    is fixed to MAX_VALUE and will neither increase nor decrease by incref(), decref()
    or add().

    Prior signed 32-bit overflow is handled correctly for most cases: All values
    from UINT32_MAX (2**32-1, inclusive) to MAX_VALUE (exclusive) are reserved and either
    cause silent data loss (-1, -2) or will raise an AssertionError when accessed.
    Other values are handled correctly. Note that previously the refcount could also reach
    0 by *increasing* it.

    Assigning refcounts in this reserved range is an invalid operation and raises AssertionError.
    """

    value_size = 12

    def __getitem__(self, key):
        assert len(key) == self.key_size
        data = <uint32_t *>hashindex_get(self.index, <char *>key)
        if not data:
            raise KeyError(key)
        cdef uint32_t refcount = _le32toh(data[0])
        assert refcount <= _MAX_VALUE, "invalid reference count"
        return ChunkIndexEntry(refcount, _le32toh(data[1]), _le32toh(data[2]))

    def __setitem__(self, key, value):
        assert len(key) == self.key_size
        cdef uint32_t[3] data
        cdef uint32_t refcount = value[0]
        assert refcount <= _MAX_VALUE, "invalid reference count"
        data[0] = _htole32(refcount)
        data[1] = _htole32(value[1])
        data[2] = _htole32(value[2])
        if not hashindex_set(self.index, <char *>key, data):
            raise Exception('hashindex_set failed')

    def __contains__(self, key):
        assert len(key) == self.key_size
        data = <uint32_t *>hashindex_get(self.index, <char *>key)
        if data != NULL:
            assert _le32toh(data[0]) <= _MAX_VALUE, "invalid reference count"
        return data != NULL

    def incref(self, key):
        """Increase refcount for 'key', return (refcount, size, csize)"""
        assert len(key) == self.key_size
        data = <uint32_t *>hashindex_get(self.index, <char *>key)
        if not data:
            raise KeyError(key)
        cdef uint32_t refcount = _le32toh(data[0])
        assert refcount <= _MAX_VALUE, "invalid reference count"
        if refcount != _MAX_VALUE:
            refcount += 1
        data[0] = _htole32(refcount)
        return refcount, _le32toh(data[1]), _le32toh(data[2])

    def decref(self, key):
        """Decrease refcount for 'key', return (refcount, size, csize)"""
        assert len(key) == self.key_size
        data = <uint32_t *>hashindex_get(self.index, <char *>key)
        if not data:
            raise KeyError(key)
        cdef uint32_t refcount = _le32toh(data[0])
        # Never decrease a reference count of zero
        assert 0 < refcount <= _MAX_VALUE, "invalid reference count"
        if refcount != _MAX_VALUE:
            refcount -= 1
        data[0] = _htole32(refcount)
        return refcount, _le32toh(data[1]), _le32toh(data[2])

    def iteritems(self, marker=None):
        cdef const void *key
        iter = ChunkKeyIterator(self.key_size)
        iter.idx = self
        iter.index = self.index
        if marker:
            key = hashindex_get(self.index, <char *>marker)
            if marker is None:
                raise IndexError
            iter.key = key - self.key_size
        return iter

    def summarize(self):
        cdef uint64_t size = 0, csize = 0, unique_size = 0, unique_csize = 0, chunks = 0, unique_chunks = 0
        cdef uint32_t *values
        cdef uint32_t refcount
        cdef void *key = NULL

        while True:
            key = hashindex_next_key(self.index, key)
            if not key:
                break
            unique_chunks += 1
            values = <uint32_t*> (key + self.key_size)
            refcount = _le32toh(values[0])
            assert refcount <= _MAX_VALUE, "invalid reference count"
            chunks += refcount
            unique_size += _le32toh(values[1])
            unique_csize += _le32toh(values[2])
            size += <uint64_t> _le32toh(values[1]) * _le32toh(values[0])
            csize += <uint64_t> _le32toh(values[2]) * _le32toh(values[0])

        return size, csize, unique_size, unique_csize, unique_chunks, chunks

    def add(self, key, refs, size, csize):
        assert len(key) == self.key_size
        cdef uint32_t[3] data
        data[0] = _htole32(refs)
        data[1] = _htole32(size)
        data[2] = _htole32(csize)
        self._add(<char*> key, data)

    cdef _add(self, void *key, uint32_t *data):
        cdef uint64_t refcount1, refcount2, result64
        values = <uint32_t*> hashindex_get(self.index, key)
        if values:
            refcount1 = _le32toh(values[0])
            refcount2 = _le32toh(data[0])
            assert refcount1 <= _MAX_VALUE, "invalid reference count"
            assert refcount2 <= _MAX_VALUE, "invalid reference count"
            result64 = refcount1 + refcount2
            values[0] = _htole32(min(result64, _MAX_VALUE))
            values[1] = data[1]
            values[2] = data[2]
        else:
            if not hashindex_set(self.index, key, data):
                raise Exception('hashindex_set failed')

    def merge(self, ChunkIndex other):
        cdef void *key = NULL

        while True:
            key = hashindex_next_key(other.index, key)
            if not key:
                break
            self._add(key, <uint32_t*> (key + self.key_size))


cdef class ChunkKeyIterator:
    cdef ChunkIndex idx
    cdef HashIndex *index
    cdef const void *key
    cdef int key_size
    cdef int exhausted

    def __cinit__(self, key_size):
        self.key = NULL
        self.key_size = key_size
        self.exhausted = 0

    def __iter__(self):
        return self

    def __next__(self):
        if self.exhausted:
            raise StopIteration
        self.key = hashindex_next_key(self.index, <char *>self.key)
        if not self.key:
            self.exhausted = 1
            raise StopIteration
        cdef uint32_t *value = <uint32_t *>(self.key + self.key_size)
        cdef uint32_t refcount = _le32toh(value[0])
        assert refcount <= _MAX_VALUE, "invalid reference count"
        return (<char *>self.key)[:self.key_size], ChunkIndexEntry(refcount, _le32toh(value[1]), _le32toh(value[2]))


cdef class CacheSynchronizer:
    cdef ChunkIndex chunks
    cdef CacheSyncCtx *sync

    def __cinit__(self, chunks):
        self.chunks = chunks
        self.sync = cache_sync_init(self.chunks.index)
        if not self.sync:
            raise Exception('cache_sync_init failed')

    def __dealloc__(self):
        if self.sync:
            cache_sync_free(self.sync)

    def feed(self, chunk):
        if not cache_sync_feed(self.sync, <char *>chunk, len(chunk)):
            error = cache_sync_error(self.sync)
            if error != NULL:
                raise ValueError('cache_sync_feed failed: ' + error.decode('ascii'))
