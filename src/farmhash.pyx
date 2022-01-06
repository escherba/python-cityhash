#cython: infer_types=True
#cython: embedsignature=True
#cython: binding=False
#cython: language_level=2
#distutils: language=c++

"""
Python wrapper for FarmHash
"""

__author__      = "Eugene Scherba"
__email__       = "escherba+cityhash@gmail.com"
__version__     = '0.3.8'
__all__         = [
    "FarmHash32",
    "FarmHash32WithSeed",
    "Fingerprint32",
    "FarmHash64",
    "FarmHash64WithSeed",
    "FarmHash64WithSeeds",
    "Fingerprint64",
    "FarmHash128",
    "FarmHash128WithSeed",
    "Fingerprint128",
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


cdef extern from "farm.h" nogil:
    ctypedef pair[uint64_t, uint64_t] uint128_t
    cdef uint32_t c_Hash32 "util::Hash32" (const char *buff, size_t length)
    cdef uint32_t c_Fingerprint32 "util::Fingerprint32" (const char *buff, size_t length)
    cdef uint32_t c_Hash32WithSeed "util::Hash32WithSeed" (const char *buff, size_t length, uint32_t seed)
    cdef uint64_t c_Hash64 "util::Hash64" (const char *buff, size_t length)
    cdef uint64_t c_Fingerprint64 "util::Fingerprint64" (const char *buff, size_t length)
    cdef uint64_t c_Hash64WithSeed "util::Hash64WithSeed" (const char *buff, size_t length, uint64_t seed)
    cdef uint64_t c_Hash64WithSeeds "util::Hash64WithSeeds" (const char *buff, size_t length, uint64_t seed0, uint64_t seed1)
    cdef uint128_t c_Hash128 "util::Hash128" (const char *s, size_t length)
    cdef uint128_t c_Fingerprint128 "util::Fingerprint128" (const char *s, size_t length)
    cdef uint128_t c_Hash128WithSeed "util::Hash128WithSeed" (const char *s, size_t length, uint128_t seed)


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


def FarmHash32(data) -> int:
    """
Obtain a 32-bit hash from input data.

Args:
    data (str, buffer): input data (either string or buffer type)
Returns:
    int: a 32-bit hash of the input data
Raises:
    TypeError
    """
    cdef Py_buffer buf
    cdef bytes obj
    cdef uint32_t result
    if PyUnicode_Check(data):
        obj = PyUnicode_AsUTF8String(data)
        PyObject_GetBuffer(obj, &buf, PyBUF_SIMPLE)
        result = c_Hash32(<const char*>buf.buf, buf.len)
        PyBuffer_Release(&buf)
    elif PyBytes_Check(data):
        result = c_Hash32(<const char*>PyBytes_AS_STRING(data),
                              PyBytes_GET_SIZE(data))
    elif PyObject_CheckBuffer(data):
        PyObject_GetBuffer(data, &buf, PyBUF_SIMPLE)
        result = c_Hash32(<const char*>buf.buf, buf.len)
        PyBuffer_Release(&buf)
    else:
        raise _type_error("data", ["basestring", "buffer"], data)
    return result


def Fingerprint32(data) -> int:
    """
Obtain a 32-bit fingerprint (hardware-independent) from input data.

Args:
    data (str, buffer): input data (either string or buffer type)
Returns:
    int: a 32-bit hash of the input data
Raises:
    TypeError
    """
    cdef Py_buffer buf
    cdef bytes obj
    cdef uint32_t result
    if PyUnicode_Check(data):
        obj = PyUnicode_AsUTF8String(data)
        PyObject_GetBuffer(obj, &buf, PyBUF_SIMPLE)
        result = c_Fingerprint32(<const char*>buf.buf, buf.len)
        PyBuffer_Release(&buf)
    elif PyBytes_Check(data):
        result = c_Fingerprint32(<const char*>PyBytes_AS_STRING(data),
                              PyBytes_GET_SIZE(data))
    elif PyObject_CheckBuffer(data):
        PyObject_GetBuffer(data, &buf, PyBUF_SIMPLE)
        result = c_Fingerprint32(<const char*>buf.buf, buf.len)
        PyBuffer_Release(&buf)
    else:
        raise _type_error("data", ["basestring", "buffer"], data)
    return result


def FarmHash32WithSeed(data, uint32_t seed=0U) -> int:
    """
Obtain a 32-bit hash from input data.

Args:
    data (str, buffer): input data (either string or buffer type)
    seed (int, default=0): seed for random generator
Returns:
    int: a 32-bit hash of the input data
Raises:
    TypeError
    """
    cdef Py_buffer buf
    cdef bytes obj
    cdef uint32_t result
    if PyUnicode_Check(data):
        obj = PyUnicode_AsUTF8String(data)
        PyObject_GetBuffer(obj, &buf, PyBUF_SIMPLE)
        result = c_Hash32WithSeed(<const char*>buf.buf, buf.len, seed)
        PyBuffer_Release(&buf)
    elif PyBytes_Check(data):
        result = c_Hash32WithSeed(<const char*>PyBytes_AS_STRING(data),
                                  PyBytes_GET_SIZE(data), seed)
    elif PyObject_CheckBuffer(data):
        PyObject_GetBuffer(data, &buf, PyBUF_SIMPLE)
        result = c_Hash32WithSeed(<const char*>buf.buf, buf.len, seed)
        PyBuffer_Release(&buf)
    else:
        raise _type_error("data", ["basestring", "buffer"], data)
    return result


def FarmHash64(data) -> int:
    """
Obtain a 64-bit hash from input data.

Args:
    data (str, buffer): input data (either string or buffer type)
Returns:
    int: a 64-bit hash of the input data
Raises:
    TypeError
    """
    cdef Py_buffer buf
    cdef bytes obj
    cdef uint64_t result
    if PyUnicode_Check(data):
        obj = PyUnicode_AsUTF8String(data)
        PyObject_GetBuffer(obj, &buf, PyBUF_SIMPLE)
        result = c_Hash64(<const char*>buf.buf, buf.len)
        PyBuffer_Release(&buf)
    elif PyBytes_Check(data):
        result = c_Hash64(<const char*>PyBytes_AS_STRING(data),
                              PyBytes_GET_SIZE(data))
    elif PyObject_CheckBuffer(data):
        PyObject_GetBuffer(data, &buf, PyBUF_SIMPLE)
        result = c_Hash64(<const char*>buf.buf, buf.len)
        PyBuffer_Release(&buf)
    else:
        raise _type_error("data", ["basestring", "buffer"], data)
    return result


def Fingerprint64(data) -> int:
    """
Obtain a 64-bit fingerprint (hardware-independent) from input data.

Args:
    data (str, buffer): input data (either string or buffer type)
Returns:
    int: a 64-bit hash of the input data
Raises:
    TypeError
    """
    cdef Py_buffer buf
    cdef bytes obj
    cdef uint64_t result
    if PyUnicode_Check(data):
        obj = PyUnicode_AsUTF8String(data)
        PyObject_GetBuffer(obj, &buf, PyBUF_SIMPLE)
        result = c_Fingerprint64(<const char*>buf.buf, buf.len)
        PyBuffer_Release(&buf)
    elif PyBytes_Check(data):
        result = c_Fingerprint64(<const char*>PyBytes_AS_STRING(data),
                              PyBytes_GET_SIZE(data))
    elif PyObject_CheckBuffer(data):
        PyObject_GetBuffer(data, &buf, PyBUF_SIMPLE)
        result = c_Fingerprint64(<const char*>buf.buf, buf.len)
        PyBuffer_Release(&buf)
    else:
        raise _type_error("data", ["basestring", "buffer"], data)
    return result


def FarmHash64WithSeed(data, uint64_t seed=0ULL) -> int:
    """
Obtain a 64-bit hash from input data given a seed.

Args:
    data (str, buffer): input data (either string or buffer type)
    seed (int, default=0): seed for random number generator
Returns:
    int: a 64-bit hash of the input data
Raises:
    TypeError, OverflowError
    """
    cdef Py_buffer buf
    cdef bytes obj
    cdef uint64_t result
    if PyUnicode_Check(data):
        obj = PyUnicode_AsUTF8String(data)
        PyObject_GetBuffer(obj, &buf, PyBUF_SIMPLE)
        result = c_Hash64WithSeed(<const char*>buf.buf, buf.len, seed)
        PyBuffer_Release(&buf)
    elif PyBytes_Check(data):
        result = c_Hash64WithSeed(<const char*>PyBytes_AS_STRING(data),
                                      PyBytes_GET_SIZE(data), seed)
    elif PyObject_CheckBuffer(data):
        PyObject_GetBuffer(data, &buf, PyBUF_SIMPLE)
        result = c_Hash64WithSeed(<const char*>buf.buf, buf.len, seed)
        PyBuffer_Release(&buf)
    else:
        raise _type_error("data", ["basestring", "buffer"], data)
    return result


def FarmHash64WithSeeds(data, uint64_t seed0=0LL, uint64_t seed1=0LL) -> int:
    """
Obtain a 64-bit hash from input data given two seeds.

Args:
    data (str, buffer): input data (either string or buffer type)
    seed0 (int): seed for random number generator
    seed1 (int): seed for random number generator
Returns:
    int: a 64-bit hash of the input data
Raises:
    TypeError, OverflowError
    """
    cdef Py_buffer buf
    cdef bytes obj
    cdef uint64_t result
    if PyUnicode_Check(data):
        obj = PyUnicode_AsUTF8String(data)
        PyObject_GetBuffer(obj, &buf, PyBUF_SIMPLE)
        result = c_Hash64WithSeeds(<const char*>buf.buf, buf.len, seed0, seed1)
        PyBuffer_Release(&buf)
    elif PyBytes_Check(data):
        result = c_Hash64WithSeeds(<const char*>PyBytes_AS_STRING(data),
                                       PyBytes_GET_SIZE(data), seed0, seed1)
    elif PyObject_CheckBuffer(data):
        PyObject_GetBuffer(data, &buf, PyBUF_SIMPLE)
        result = c_Hash64WithSeeds(<const char*>buf.buf, buf.len, seed0, seed1)
        PyBuffer_Release(&buf)
    else:
        raise _type_error("data", ["basestring", "buffer"], data)
    return result


def FarmHash128(data) -> int:
    """
Obtain a 128-bit hash from input data.

Args:
    data (str, buffer): input data (either string or buffer type)
Returns:
    int: a 128-bit hash of the input data
Raises:
    TypeError
    """
    cdef Py_buffer buf
    cdef bytes obj
    cdef pair[uint64_t, uint64_t] result
    if PyUnicode_Check(data):
        obj = PyUnicode_AsUTF8String(data)
        PyObject_GetBuffer(obj, &buf, PyBUF_SIMPLE)
        result = c_Hash128(<const char*>buf.buf, buf.len)
        PyBuffer_Release(&buf)
    elif PyBytes_Check(data):
        result = c_Hash128(<const char*>PyBytes_AS_STRING(data),
                               PyBytes_GET_SIZE(data))
    elif PyObject_CheckBuffer(data):
        PyObject_GetBuffer(data, &buf, PyBUF_SIMPLE)
        result = c_Hash128(<const char*>buf.buf, buf.len)
        PyBuffer_Release(&buf)
    else:
        raise _type_error("data", ["basestring", "buffer"], data)
    return (long(result.first) << 64ULL) + long(result.second)


def Fingerprint128(data) -> int:
    """
Obtain a 128-bit hash from input data.

Args:
    data (str, buffer): input data (either string or buffer type)
Returns:
    int: a 128-bit hash of the input data
Raises:
    TypeError
    """
    cdef Py_buffer buf
    cdef bytes obj
    cdef pair[uint64_t, uint64_t] result
    if PyUnicode_Check(data):
        obj = PyUnicode_AsUTF8String(data)
        PyObject_GetBuffer(obj, &buf, PyBUF_SIMPLE)
        result = c_Fingerprint128(<const char*>buf.buf, buf.len)
        PyBuffer_Release(&buf)
    elif PyBytes_Check(data):
        result = c_Fingerprint128(<const char*>PyBytes_AS_STRING(data),
                               PyBytes_GET_SIZE(data))
    elif PyObject_CheckBuffer(data):
        PyObject_GetBuffer(data, &buf, PyBUF_SIMPLE)
        result = c_Fingerprint128(<const char*>buf.buf, buf.len)
        PyBuffer_Release(&buf)
    else:
        raise _type_error("data", ["basestring", "buffer"], data)
    return (long(result.first) << 64ULL) + long(result.second)


def FarmHash128WithSeed(data, seed: int = 0L) -> int:
    """
Obtain a 128-bit hash from input data given a seed.

Args:
    data (str, buffer): input data (either string or buffer type)
    seed (int, default=0): seed for random number generator
Returns:
    int: a 128-bit hash of the input data
Raises:
    TypeError, OverflowError
    """
    cdef Py_buffer buf
    cdef bytes obj
    cdef pair[uint64_t, uint64_t] result
    cdef pair[uint64_t, uint64_t] tseed

    tseed.first = seed >> 64ULL
    tseed.second = seed & ((1ULL << 64ULL) - 1ULL)

    if PyUnicode_Check(data):
        obj = PyUnicode_AsUTF8String(data)
        PyObject_GetBuffer(obj, &buf, PyBUF_SIMPLE)
        result = c_Hash128WithSeed(<const char*>buf.buf, buf.len, tseed)
        PyBuffer_Release(&buf)
    elif PyBytes_Check(data):
        result = c_Hash128WithSeed(<const char*>PyBytes_AS_STRING(data),
                                       PyBytes_GET_SIZE(data), tseed)
    elif PyObject_CheckBuffer(data):
        PyObject_GetBuffer(data, &buf, PyBUF_SIMPLE)
        result = c_Hash128WithSeed(<const char*>buf.buf, buf.len, tseed)
        PyBuffer_Release(&buf)
    else:
        raise _type_error("data", ["basestring", "buffer"], data)
    return (long(result.first) << 64ULL) + long(result.second)
