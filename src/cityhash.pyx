#cython: infer_types=True

"""
A Python wrapper around CityHash, a fast non-cryptographic hashing algorithm
"""

__author__      = "Alexander [Amper] Marshalov"
__email__       = "alone.amper+cityhash@gmail.com"
__version__     = '0.2.3.post9'
__all__         = ["CityHash32",
                   "CityHash64",
                   "CityHash64WithSeed",
                   "CityHash64WithSeeds",
                   "CityHash128",
                   "CityHash128WithSeed",
                  ]

cdef extern from * nogil:
    ctypedef unsigned long int uint32_t
    ctypedef unsigned long long int uint64_t

cdef extern from "<utility>" namespace "std":
    cdef cppclass pair[T, U]:
        T first
        U second
        pair()
        pair(pair&)
        pair(T&, U&)
        bint operator == (pair&, pair&)
        bint operator != (pair&, pair&)
        bint operator <  (pair&, pair&)
        bint operator >  (pair&, pair&)
        bint operator <= (pair&, pair&)
        bint operator >= (pair&, pair&)

cdef extern from "city.h" nogil:
    ctypedef uint32_t uint32
    ctypedef uint64_t uint64
    ctypedef pair uint128
    cdef uint64  c_Uint128Low64 "Uint128Low64" (uint128& x)
    cdef uint64  c_Uint128High64 "Uint128High64" (uint128& x)
    cdef uint32  c_CityHash32 "CityHash32" (char *buff, size_t len)
    cdef uint64  c_CityHash64 "CityHash64" (char *buff, size_t len)
    cdef uint64  c_CityHash64WithSeed "CityHash64WithSeed" (char *buff, size_t len, uint64 seed)
    cdef uint64  c_CityHash64WithSeeds "CityHash64WithSeeds" (char *buff, size_t len, uint64 seed0, uint64 seed1)
    cdef uint128[uint64,uint64] c_CityHash128 "CityHash128" (char *s, size_t len)
    cdef uint128[uint64,uint64] c_CityHash128WithSeed "CityHash128WithSeed" (char *s, size_t len, uint128[uint64,uint64] seed)


from cpython.buffer cimport PyObject_CheckBuffer
from cpython.buffer cimport PyBUF_SIMPLE
from cpython.buffer cimport Py_buffer
from cpython.buffer cimport PyObject_GetBuffer
from cpython.buffer cimport PyBuffer_Release

from cpython.unicode cimport PyUnicode_Check
from cpython.unicode cimport PyUnicode_AsUTF8String

from cpython.bytes cimport PyBytes_Check 
from cpython.bytes cimport PyBytes_GET_SIZE 
from cpython.bytes cimport PyBytes_AS_STRING 

from cpython cimport Py_DECREF


cdef object _type_error(str argname, expected, value):
    return TypeError(
        "Argument '%s' has incorrect type (expected %s, got %s)" %
        (argname, expected, type(value))
    )


cpdef CityHash32(data):
    """32-bit hash function for a basestring or buffer type
    """
    cdef Py_buffer buf
    cdef object obj
    cdef uint32 result
    if PyUnicode_Check(data):
        obj = PyUnicode_AsUTF8String(data)
        PyObject_GetBuffer(obj, &buf, PyBUF_SIMPLE)
        result = c_CityHash32(<const char*>buf.buf, buf.len)
        PyBuffer_Release(&buf)
    elif PyBytes_Check(data):
        result = c_CityHash32(<const char*>PyBytes_AS_STRING(data),
                              PyBytes_GET_SIZE(data))
    elif PyObject_CheckBuffer(data):
        PyObject_GetBuffer(data, &buf, PyBUF_SIMPLE)
        result = c_CityHash32(<const char*>buf.buf, buf.len)
        PyBuffer_Release(&buf)
    else:
        raise _type_error("data", ["basestring", "buffer"], data)
    return result


cpdef CityHash64(data):
    """64-bit hash function for a basestring or buffer type
    """
    cdef Py_buffer buf
    cdef object obj
    cdef uint64 result
    if PyUnicode_Check(data):
        obj = PyUnicode_AsUTF8String(data)
        PyObject_GetBuffer(obj, &buf, PyBUF_SIMPLE)
        result = c_CityHash64(<const char*>buf.buf, buf.len)
        PyBuffer_Release(&buf)
    elif PyBytes_Check(data):
        result = c_CityHash64(<const char*>PyBytes_AS_STRING(data),
                              PyBytes_GET_SIZE(data))
    elif PyObject_CheckBuffer(data):
        PyObject_GetBuffer(data, &buf, PyBUF_SIMPLE)
        result = c_CityHash64(<const char*>buf.buf, buf.len)
        PyBuffer_Release(&buf)
    else:
        raise _type_error("data", ["basestring", "buffer"], data)
    return result


cpdef CityHash64WithSeed(data, uint64 seed=0ULL):
    """64-bit hash function for a basestring or buffer type.
    For convenience, a 64-bit seed is also hashed into the result.
    """
    cdef Py_buffer buf
    cdef object obj
    cdef uint64 result
    if PyUnicode_Check(data):
        obj = PyUnicode_AsUTF8String(data)
        PyObject_GetBuffer(obj, &buf, PyBUF_SIMPLE)
        result = c_CityHash64WithSeed(<const char*>buf.buf, buf.len, seed)
        PyBuffer_Release(&buf)
    elif PyBytes_Check(data):
        result = c_CityHash64WithSeed(<const char*>PyBytes_AS_STRING(data),
                                      PyBytes_GET_SIZE(data), seed)
    elif PyObject_CheckBuffer(data):
        PyObject_GetBuffer(data, &buf, PyBUF_SIMPLE)
        result = c_CityHash64WithSeed(<const char*>buf.buf, buf.len, seed)
        PyBuffer_Release(&buf)
    else:
        raise _type_error("data", ["basestring", "buffer"], data)
    return result

cpdef CityHash64WithSeeds(data, uint64 seed0=0LL, uint64 seed1=0LL):
    """64-bit hash function for a basestring or buffer type.
    For convenience, two seeds are also hashed into the result.
    """
    cdef Py_buffer buf
    cdef object obj
    cdef uint64 result
    if PyUnicode_Check(data):
        obj = PyUnicode_AsUTF8String(data)
        PyObject_GetBuffer(obj, &buf, PyBUF_SIMPLE)
        result = c_CityHash64WithSeeds(<const char*>buf.buf, buf.len, seed0, seed1)
        PyBuffer_Release(&buf)
    elif PyBytes_Check(data):
        result = c_CityHash64WithSeeds(<const char*>PyBytes_AS_STRING(data),
                                       PyBytes_GET_SIZE(data), seed0, seed1)
    elif PyObject_CheckBuffer(data):
        PyObject_GetBuffer(data, &buf, PyBUF_SIMPLE)
        result = c_CityHash64WithSeeds(<const char*>buf.buf, buf.len, seed0, seed1)
        PyBuffer_Release(&buf)
    else:
        raise _type_error("data", ["basestring", "buffer"], data)
    return result

cpdef CityHash128(data):
    """128-bit hash function for a basestring or buffer type
    """
    cdef Py_buffer buf
    cdef object obj
    cdef pair[uint64, uint64] result
    if PyUnicode_Check(data):
        obj = PyUnicode_AsUTF8String(data)
        PyObject_GetBuffer(obj, &buf, PyBUF_SIMPLE)
        result = c_CityHash128(<const char*>buf.buf, buf.len)
        PyBuffer_Release(&buf)
    elif PyBytes_Check(data):
        result = c_CityHash128(<const char*>PyBytes_AS_STRING(data),
                               PyBytes_GET_SIZE(data))
    elif PyObject_CheckBuffer(data):
        PyObject_GetBuffer(data, &buf, PyBUF_SIMPLE)
        result = c_CityHash128(<const char*>buf.buf, buf.len)
        PyBuffer_Release(&buf)
    else:
        raise _type_error("data", ["basestring", "buffer"], data)
    final = 0x10000000000000000L * long(result.first) + long(result.second)
    return final

cpdef CityHash128WithSeed(data, seed=0L):
    """128-bit ash function for a basestring or buffer type.
    For convenience, a 128-bit seed is also hashed into the result.
    """
    cdef Py_buffer buf
    cdef object obj
    cdef pair[uint64, uint64] result
    cdef pair[uint64, uint64] tseed

    cdef uint64 seed_0 = seed >> 64ULL
    cdef uint64 seed_1 = seed & ((1ULL << 64ULL) - 1ULL)

    if PyUnicode_Check(data):
        obj = PyUnicode_AsUTF8String(data)
        PyObject_GetBuffer(obj, &buf, PyBUF_SIMPLE)
        result = c_CityHash128WithSeed(<const char*>buf.buf, buf.len, tseed)
        PyBuffer_Release(&buf)
    elif PyBytes_Check(data):
        result = c_CityHash128WithSeed(<const char*>PyBytes_AS_STRING(data),
                                       PyBytes_GET_SIZE(data), tseed)
    elif PyObject_CheckBuffer(data):
        PyObject_GetBuffer(data, &buf, PyBUF_SIMPLE)
        result = c_CityHash128WithSeed(<const char*>buf.buf, buf.len, tseed)
        PyBuffer_Release(&buf)
    else:
        raise _type_error("data", ["basestring", "buffer"], data)
    final = 0x10000000000000000L * long(result.first) + long(result.second)
    return final
