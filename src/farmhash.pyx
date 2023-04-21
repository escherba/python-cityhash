#cython: infer_types=True
#cython: embedsignature=True
#cython: binding=False
#cython: language_level=3
#distutils: language=c++

"""
Python wrapper for FarmHash
"""

__author__      = "Eugene Scherba"
__email__       = "escherba+cityhash@gmail.com"
__version__     = '0.4.7'
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


cdef extern from "Python.h":
    # Note that following functions can potentially raise an exception,
    # thus they cannot be declared 'nogil'. Also, PyUnicode_AsUTF8AndSize() can
    # potentially allocate memory inside in unlikely case of when underlying
    # unicode object was stored as non-utf8 and utf8 wasn't requested before.
    const char* PyUnicode_AsUTF8AndSize(object obj, Py_ssize_t* length) except NULL


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

from cpython.bytes cimport PyBytes_Check
from cpython.bytes cimport PyBytes_GET_SIZE
from cpython.bytes cimport PyBytes_AS_STRING



cdef object _type_error(argname: str, expected: object, value: object):
    return TypeError(
        "Argument '%s' has incorrect type: expected %s, got '%s' instead" %
        (argname, expected, type(value).__name__)
    )


def FarmHash32(data) -> int:
    """Obtain a 32-bit hash from input data.

    :param data: input data (string, bytes, or buffer object)
    :return: an integer representing a 32-bit hash of the input
    :raises TypeError: if data is not of one of input types
    :raises ValueError: if input buffer is not C-contiguous
    """
    cdef Py_buffer buf
    cdef uint32_t result
    cdef const char* encoding
    cdef Py_ssize_t encoding_size = 0

    if PyUnicode_Check(data):
        encoding = PyUnicode_AsUTF8AndSize(data, &encoding_size)
        result = c_Hash32(encoding, encoding_size)
    elif PyBytes_Check(data):
        result = c_Hash32(
            <const char*>PyBytes_AS_STRING(data),
            PyBytes_GET_SIZE(data))
    elif PyObject_CheckBuffer(data):
        PyObject_GetBuffer(data, &buf, PyBUF_SIMPLE)
        result = c_Hash32(<const char*>buf.buf, buf.len)
        PyBuffer_Release(&buf)
    else:
        raise _type_error("data", ["basestring", "buffer"], data)
    return result


def Fingerprint32(data) -> int:
    """Obtain a 32-bit hardware-independent fingerprint.

    :param data: input data (string, bytes, or buffer object)
    :return: an integer representing a 32-bit hash of the input
    :raises TypeError: if data is not of one of input types
    :raises ValueError: if input buffer is not C-contiguous
    """
    cdef Py_buffer buf
    cdef uint32_t result
    cdef const char* encoding
    cdef Py_ssize_t encoding_size = 0

    if PyUnicode_Check(data):
        encoding = PyUnicode_AsUTF8AndSize(data, &encoding_size)
        result = c_Fingerprint32(encoding, encoding_size)
    elif PyBytes_Check(data):
        result = c_Fingerprint32(
            <const char*>PyBytes_AS_STRING(data),
            PyBytes_GET_SIZE(data))
    elif PyObject_CheckBuffer(data):
        PyObject_GetBuffer(data, &buf, PyBUF_SIMPLE)
        result = c_Fingerprint32(<const char*>buf.buf, buf.len)
        PyBuffer_Release(&buf)
    else:
        raise _type_error("data", ["basestring", "buffer"], data)
    return result


def FarmHash32WithSeed(data, uint32_t seed=0U) -> int:
    """Obtain a 32-bit hash using a seed.

    :param data: input data (string, bytes, or buffer object)
    :param seed: seed value (a 32-bit integer, defaults to 0)
    :return: an integer representing a 32-bit hash of the input
    :raises TypeError: if data is not of one of input types
    :raises ValueError: if input buffer is not C-contiguous
    :raises OverflowError: if seed cannot be converted to unsigned int32
    """

    cdef Py_buffer buf
    cdef uint32_t result
    cdef const char* encoding
    cdef Py_ssize_t encoding_size = 0

    if PyUnicode_Check(data):
        encoding = PyUnicode_AsUTF8AndSize(data, &encoding_size)
        result = c_Hash32WithSeed(encoding, encoding_size, seed)
    elif PyBytes_Check(data):
        result = c_Hash32WithSeed(
            <const char*>PyBytes_AS_STRING(data),
            PyBytes_GET_SIZE(data), seed)
    elif PyObject_CheckBuffer(data):
        PyObject_GetBuffer(data, &buf, PyBUF_SIMPLE)
        result = c_Hash32WithSeed(<const char*>buf.buf, buf.len, seed)
        PyBuffer_Release(&buf)
    else:
        raise _type_error("data", ["basestring", "buffer"], data)
    return result


def FarmHash64(data) -> int:
    """Obtain a 64-bit hash from input data.

    :param data: input data (string, bytes, or buffer object)
    :return: an integer representing a 64-bit hash of the input
    :raises TypeError: if data is not of one of input types
    :raises ValueError: if input buffer is not C-contiguous
    """
    cdef Py_buffer buf
    cdef uint64_t result
    cdef const char* encoding
    cdef Py_ssize_t encoding_size = 0

    if PyUnicode_Check(data):
        encoding = PyUnicode_AsUTF8AndSize(data, &encoding_size)
        result = c_Hash64(encoding, encoding_size)
    elif PyBytes_Check(data):
        result = c_Hash64(
            <const char*>PyBytes_AS_STRING(data),
            PyBytes_GET_SIZE(data))
    elif PyObject_CheckBuffer(data):
        PyObject_GetBuffer(data, &buf, PyBUF_SIMPLE)
        result = c_Hash64(<const char*>buf.buf, buf.len)
        PyBuffer_Release(&buf)
    else:
        raise _type_error("data", ["basestring", "buffer"], data)
    return result


def Fingerprint64(data) -> int:
    """Obtain a 64-bit hardware-independent fingerprint.

    :param data: input data (string, bytes, or buffer object)
    :return: an integer representing a 64-bit hash of the input
    :raises TypeError: if data is not of one of input types
    :raises ValueError: if input buffer is not C-contiguous
    """
    cdef Py_buffer buf
    cdef uint64_t result
    cdef const char* encoding
    cdef Py_ssize_t encoding_size = 0

    if PyUnicode_Check(data):
        encoding = PyUnicode_AsUTF8AndSize(data, &encoding_size)
        result = c_Fingerprint64(encoding, encoding_size)
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
    """Obtain a 64-bit hash using a seed.

    :param data: input data (string, bytes, or buffer object)
    :param seed: seed value (a 64-bit integer, defaults to 0)
    :return: an integer representing a 64-bit hash of the input
    :raises TypeError: if data is not of one of input types
    :raises ValueError: if input buffer is not C-contiguous
    :raises OverflowError: if seed cannot be converted to unsigned int64
    """
    cdef Py_buffer buf
    cdef uint64_t result
    cdef const char* encoding
    cdef Py_ssize_t encoding_size = 0

    if PyUnicode_Check(data):
        encoding = PyUnicode_AsUTF8AndSize(data, &encoding_size)
        result = c_Hash64WithSeed(encoding, encoding_size, seed)
    elif PyBytes_Check(data):
        result = c_Hash64WithSeed(
            <const char*>PyBytes_AS_STRING(data),
            PyBytes_GET_SIZE(data), seed)
    elif PyObject_CheckBuffer(data):
        PyObject_GetBuffer(data, &buf, PyBUF_SIMPLE)
        result = c_Hash64WithSeed(<const char*>buf.buf, buf.len, seed)
        PyBuffer_Release(&buf)
    else:
        raise _type_error("data", ["basestring", "buffer"], data)
    return result


def FarmHash64WithSeeds(data, uint64_t seed0=0LL, uint64_t seed1=0LL) -> int:
    """Obtain a 64-bit hash using two seeds.

    :param data: input data (string, bytes, or buffer object)
    :param seed0: first seed (a 64-bit integer, defaults to 0)
    :param seed1: second seed (a 64-bit integer, defaults to 0)
    :return: an integer representing a 64-bit hash of the input
    :raises TypeError: if data is not of one of input types
    :raises ValueError: if input buffer is not C-contiguous
    :raises OverflowError: if seed cannot be converted to unsigned int64
    """
    cdef Py_buffer buf
    cdef uint64_t result
    cdef const char* encoding
    cdef Py_ssize_t encoding_size = 0

    if PyUnicode_Check(data):
        encoding = PyUnicode_AsUTF8AndSize(data, &encoding_size)
        result = c_Hash64WithSeeds(encoding, encoding_size, seed0, seed1)
    elif PyBytes_Check(data):
        result = c_Hash64WithSeeds(
            <const char*>PyBytes_AS_STRING(data),
            PyBytes_GET_SIZE(data), seed0, seed1)
    elif PyObject_CheckBuffer(data):
        PyObject_GetBuffer(data, &buf, PyBUF_SIMPLE)
        result = c_Hash64WithSeeds(<const char*>buf.buf, buf.len, seed0, seed1)
        PyBuffer_Release(&buf)
    else:
        raise _type_error("data", ["basestring", "buffer"], data)
    return result


def FarmHash128(data) -> int:
    """Obtain a 128-bit hash from input data.

    :param data: input data (string, bytes, or buffer object)
    :return: an integer representing a 128-bit hash of the input
    :raises TypeError: if data is not of one of input types
    :raises ValueError: if input buffer is not C-contiguous
    """
    cdef Py_buffer buf
    cdef pair[uint64_t, uint64_t] result
    cdef const char* encoding
    cdef Py_ssize_t encoding_size = 0

    if PyUnicode_Check(data):
        encoding = PyUnicode_AsUTF8AndSize(data, &encoding_size)
        result = c_Hash128(encoding, encoding_size)
    elif PyBytes_Check(data):
        result = c_Hash128(
            <const char*>PyBytes_AS_STRING(data),
            PyBytes_GET_SIZE(data))
    elif PyObject_CheckBuffer(data):
        PyObject_GetBuffer(data, &buf, PyBUF_SIMPLE)
        result = c_Hash128(<const char*>buf.buf, buf.len)
        PyBuffer_Release(&buf)
    else:
        raise _type_error("data", ["basestring", "buffer"], data)
    return (long(result.first) << 64ULL) + long(result.second)


def Fingerprint128(data) -> int:
    """Obtain a 128-bit hardware-independent fingerprint.

    :param data: input data (string, bytes, or buffer object)
    :return: an integer representing a 128-bit hash of the input
    :raises TypeError: if data is not of one of input types
    :raises ValueError: if input buffer is not C-contiguous
    """
    cdef Py_buffer buf
    cdef pair[uint64_t, uint64_t] result
    cdef const char* encoding
    cdef Py_ssize_t encoding_size = 0

    if PyUnicode_Check(data):
        encoding = PyUnicode_AsUTF8AndSize(data, &encoding_size)
        result = c_Fingerprint128(encoding, encoding_size)
    elif PyBytes_Check(data):
        result = c_Fingerprint128(
            <const char*>PyBytes_AS_STRING(data),
            PyBytes_GET_SIZE(data))
    elif PyObject_CheckBuffer(data):
        PyObject_GetBuffer(data, &buf, PyBUF_SIMPLE)
        result = c_Fingerprint128(<const char*>buf.buf, buf.len)
        PyBuffer_Release(&buf)
    else:
        raise _type_error("data", ["basestring", "buffer"], data)
    return (long(result.first) << 64ULL) + long(result.second)


def FarmHash128WithSeed(data, seed: int = 0L) -> int:
    """Obtain a 128-bit hash using a seed.

    :param data: input data (string, bytes, or buffer object)
    :param seed: seed value (defaults to 0)
    :return: an integer representing a 128-bit hash of the input
    :raises TypeError: if data is not of one of input types
    :raises ValueError: if input buffer is not C-contiguous
    """
    cdef Py_buffer buf
    cdef pair[uint64_t, uint64_t] result
    cdef pair[uint64_t, uint64_t] tseed
    cdef const char* encoding
    cdef Py_ssize_t encoding_size = 0

    tseed.first = seed >> 64ULL
    tseed.second = seed & ((1ULL << 64ULL) - 1ULL)

    if PyUnicode_Check(data):
        encoding = PyUnicode_AsUTF8AndSize(data, &encoding_size)
        result = c_Hash128WithSeed(encoding, encoding_size, tseed)
    elif PyBytes_Check(data):
        result = c_Hash128WithSeed(
            <const char*>PyBytes_AS_STRING(data),
            PyBytes_GET_SIZE(data), tseed)
    elif PyObject_CheckBuffer(data):
        PyObject_GetBuffer(data, &buf, PyBUF_SIMPLE)
        result = c_Hash128WithSeed(<const char*>buf.buf, buf.len, tseed)
        PyBuffer_Release(&buf)
    else:
        raise _type_error("data", ["basestring", "buffer"], data)
    return (long(result.first) << 64ULL) + long(result.second)
