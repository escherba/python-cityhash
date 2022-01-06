#cython: infer_types=True
#cython: embedsignature=True
#cython: binding=False
#cython: language_level=2
#distutils: language=c++

"""
Python wrapper for CityHash
"""

__author__      = "Eugene Scherba"
__email__       = "escherba+cityhash@gmail.com"
__version__     = '0.3.8'
__all__         = [
    "CityHash32",
    "CityHash64",
    "CityHash64WithSeed",
    "CityHash64WithSeeds",
    "CityHash128",
    "CityHash128WithSeed",
]


cdef extern from * nogil:
    ctypedef unsigned long int uint32_t
    ctypedef unsigned long long int uint64_t


cdef extern from "<utility>" namespace "std" nogil:
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
    ctypedef pair[uint64, uint64] uint128
    cdef uint32 c_CityHash32 "CityHash32" (const char *buff, size_t length)
    cdef uint64 c_CityHash64 "CityHash64" (const char *buff, size_t length)
    cdef uint64 c_CityHash64WithSeed "CityHash64WithSeed" (const char *buff, size_t length, uint64 seed)
    cdef uint64 c_CityHash64WithSeeds "CityHash64WithSeeds" (const char *buff, size_t length, uint64 seed0, uint64 seed1)
    cdef uint128 c_CityHash128 "CityHash128" (const char *s, size_t length)
    cdef uint128 c_CityHash128WithSeed "CityHash128WithSeed" (const char *s, size_t length, uint128 seed)


from cpython cimport long

from cpython.buffer cimport PyObject_CheckBuffer
from cpython.buffer cimport PyObject_GetBuffer
from cpython.buffer cimport PyBuffer_Release
from cpython.buffer cimport PyBUF_SIMPLE

from cpython.unicode cimport PyUnicode_Check
from cpython.unicode cimport PyUnicode_AsUTF8String

from cpython.bytes cimport PyBytes_Check
from cpython.bytes cimport PyBytes_GET_SIZE
from cpython.bytes cimport PyBytes_AS_STRING


cdef object _type_error(argname: str, expected: object, value: object):
    return TypeError(
        "Argument '%s' has incorrect type: expected %s, got '%s' instead" %
        (argname, expected, type(value).__name__)
    )


def CityHash32(data) -> int:
    """
Obtain a 32-bit hash from input data.

Args:
    data (str, buffer): input data (either string or buffer type)
Returns:
    int: a 32-bit hash of the input data
Raises:
    TypeError: if input data is not a string or a buffer
    ValueError: if input buffer is not C-contiguous
    """
    cdef Py_buffer buf
    cdef bytes obj
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


def CityHash64(data) -> int:
    """
Obtain a 64-bit hash from input data.

Args:
    data (str, buffer): input data (either string or buffer type)
Returns:
    int: a 64-bit hash of the input data
Raises:
    TypeError: if input data is not a string or a buffer
    ValueError: if input buffer is not C-contiguous
    """
    cdef Py_buffer buf
    cdef bytes obj
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


def CityHash64WithSeed(data, uint64 seed=0ULL) -> int:
    """
Obtain a 64-bit hash from input data given a seed.

Args:
    data (str, buffer): input data (either string or buffer type)
    seed (int, default=0): seed for random number generator
Returns:
    int: a 64-bit hash of the input data
Raises:
    TypeError: if input data is not a string or a buffer
    ValueError: if input buffer is not C-contiguous
    OverflowError: if seed cannot be converted to unsigned int64
    """
    cdef Py_buffer buf
    cdef bytes obj
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


def CityHash64WithSeeds(data, uint64 seed0=0LL, uint64 seed1=0LL) -> int:
    """
Obtain a 64-bit hash from input data given two seeds.

Args:
    data (str, buffer): input data (either string or buffer type)
    seed0 (int): seed for random number generator
    seed1 (int): seed for random number generator
Returns:
    int: a 64-bit hash of the input data
Raises:
    TypeError: if input data is not a string or a buffer
    ValueError: if input buffer is not C-contiguous
    OverflowError: if seed cannot be converted to unsigned int64
    """
    cdef Py_buffer buf
    cdef bytes obj
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


def CityHash128(data) -> int:
    """
Obtain a 128-bit hash from input data.

Args:
    data (str, buffer): input data (either string or buffer type)
Returns:
    int: a 128-bit hash of the input data
Raises:
    ValueError: if input buffer is not C-contiguous
    TypeError: if input data is not a string or a buffer
    """
    cdef Py_buffer buf
    cdef bytes obj
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
    return (long(result.first) << 64ULL) + long(result.second)


def CityHash128WithSeed(data, seed: int = 0L) -> int:
    """
Obtain a 128-bit hash from input data given a seed.

Args:
    data (str, buffer): input data (either string or buffer type)
    seed (int, default=0): seed for random number generator
Returns:
    int: a 128-bit hash of the input data
Raises:
    TypeError: if input data is not a string or a buffer
    ValueError: if input buffer is not C-contiguous
    OverflowError: if seed cannot be converted to unsigned int64
    """
    cdef Py_buffer buf
    cdef bytes obj
    cdef pair[uint64, uint64] result
    cdef pair[uint64, uint64] tseed

    tseed.first = seed >> 64ULL
    tseed.second = seed & ((1ULL << 64ULL) - 1ULL)

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
    return (long(result.first) << 64ULL) + long(result.second)
