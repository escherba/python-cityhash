#cython: infer_types=True

"""
Copyright (c) 2011 Alexander [Amper] Marshalov <alone.amper@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
"""

__author__      = "Alexander [Amper] Marshalov"
__email__       = "alone.amper+cityhash@gmail.com"
__all__         = ["CityHash64",
                   "CityHash64WithSeed",
                   "CityHash64WithSeeds",
                   "CityHash128",
                   "CityHash128WithSeed",
                   "Hash128to64",
                   "ch64",
                   "ch128",
                  ]

cdef extern from * nogil:
    ctypedef unsigned long int uint32_t
    ctypedef unsigned long long int uint64_t

cdef extern from "city.h" nogil:
    ctypedef uint32_t uint32
    ctypedef uint64_t uint64

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
    ctypedef pair uint128
    cdef uint64  c_Uint128Low64 "Uint128Low64" (uint128& x)
    cdef uint64  c_Uint128High64 "Uint128High64" (uint128& x)
    cdef uint64  c_CityHash64 "CityHash64" (char *buf, size_t len)
    cdef uint64  c_CityHash64WithSeed "CityHash64WithSeed" (char *buf, size_t len, uint64 seed)
    cdef uint64  c_CityHash64WithSeeds "CityHash64WithSeeds" (char *buf, size_t len, uint64 seed0, uint64 seed1)
    cdef uint64  c_Hash128to64 "Hash128to64" (uint128[uint64,uint64]& x)
    cdef uint128[uint64,uint64] c_CityHash128 "CityHash128" (char *s, size_t len)
    cdef uint128[uint64,uint64] c_CityHash128WithSeed "CityHash128WithSeed" (char *s, size_t len, uint128[uint64,uint64] seed)

cpdef CityHash64(bytes buf):
    """
        Description: Hash function for a byte array.
    """
    return c_CityHash64(buf, len(buf))

cpdef CityHash64WithSeed(bytes buf, uint64 seed):
    """
        Description: Hash function for a byte array. For convenience, a 64-bit seed is also
                     hashed into the result.
    """
    return c_CityHash64WithSeed(buf, len(buf), seed)

cpdef CityHash64WithSeeds(bytes buf, uint64 seed0, uint64 seed1):
    """
        Description: Hash function for a byte array.  For convenience, two seeds are also
                     hashed into the result.
    """
    return c_CityHash64WithSeeds(buf, len(buf), seed0, seed1)

cpdef CityHash128(bytes buf):
    """
        Description: Hash function for a byte array.
    """
    cdef pair[uint64,uint64] result = c_CityHash128(buf, len(buf))
    return (result.first, result.second)

cpdef CityHash128WithSeed(bytes buf, tuple seed):
    """
        Description: Hash function for a byte array.  For convenience, a 128-bit seed is also
                     hashed into the result.
    """
    cdef pair[uint64,uint64] tseed
    tseed.first, tseed.second = seed[0], seed[1]
    cdef pair[uint64,uint64] result = c_CityHash128WithSeed(buf, len(buf), tseed)
    return (result.first, result.second)

cpdef Hash128to64(tuple x):
    """
        Description: Hash 128 input bits down to 64 bits of output.
                     This is intended to be a reasonably good hash function.
    """
    cdef pair[uint64,uint64] xx
    xx.first, xx.second = x[0], x[1]
    return c_Hash128to64(xx)

cdef class ch64:
    cdef uint64 __value
    cdef public bytes name
    def __cinit__(self, bytes value=str("")):
        self.name = str("CityHash64")
        self.update(value)
    cpdef update(self, bytes value):
        if self.__value:
            self.__value = c_CityHash64WithSeed(value, len(value), self.__value)
        else:
            self.__value = c_CityHash64(value, len(value))
    cpdef digest(self):
        return self.__value

cdef class ch128:
    cdef tuple __value
    cdef public bytes name
    def __cinit__(self, bytes value=str("")):
        self.name = str("CityHash128")
        self.update(value)
    cpdef update(self, bytes value):
        if self.__value:
            self.__value = CityHash128WithSeed(value, self.__value)
        else:
            self.__value = CityHash128(value)
    cpdef digest(self):
        return self.__value
