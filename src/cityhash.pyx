#cython: infer_types=True

"""
A Python wrapper around CityHash, a fast non-cryptographic hashing algorithm
"""

__author__      = "Alexander [Amper] Marshalov"
__email__       = "alone.amper+cityhash@gmail.com"
__version__     = '0.1.0'
__all__         = ["CityHash64",
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
    cdef uint64  c_CityHash64 "CityHash64" (char *buff, size_t len)
    cdef uint64  c_CityHash64WithSeed "CityHash64WithSeed" (char *buff, size_t len, uint64 seed)
    cdef uint64  c_CityHash64WithSeeds "CityHash64WithSeeds" (char *buff, size_t len, uint64 seed0, uint64 seed1)
    cdef uint128[uint64,uint64] c_CityHash128 "CityHash128" (char *s, size_t len)
    cdef uint128[uint64,uint64] c_CityHash128WithSeed "CityHash128WithSeed" (char *s, size_t len, uint128[uint64,uint64] seed)


cdef const char* _chars(basestring s):
    if isinstance(s, unicode):
        s = s.encode('utf8')
    return s


cpdef CityHash64(basestring buff):
    """
        Description: Hash function for a byte array.
    """
    cdef const char* array = _chars(buff)
    return c_CityHash64(array, len(array))

cpdef CityHash64WithSeed(basestring buff, uint64 seed=0L):
    """
        Description: Hash function for a byte array. For convenience, a 64-bit seed is also
                     hashed into the result.
    """
    cdef const char* array = _chars(buff)
    return c_CityHash64WithSeed(array, len(array), seed)

cpdef CityHash64WithSeeds(basestring buff, uint64 seed0=0L, uint64 seed1=0L):
    """
        Description: Hash function for a byte array.  For convenience, two seeds are also
                     hashed into the result.
    """
    cdef const char* array = _chars(buff)
    return c_CityHash64WithSeeds(array, len(array), seed0, seed1)

cpdef CityHash128(basestring buff):
    """
        Description: Hash function for a byte array.
    """
    cdef const char* array = _chars(buff)
    cdef pair[uint64,uint64] result = c_CityHash128(array, len(array))
    return 0x10000000000000000L * long(result.first) + long(result.second)


cpdef CityHash128WithSeed(basestring buff, seed=0L):
    """
        Description: Hash function for a byte array.  For convenience, a 128-bit seed is also
                     hashed into the result.
    """
    cdef uint64 seed_0 = seed >> 64
    cdef uint64 seed_1 = seed & ((1 << 64) - 1)
    cdef const char* array = _chars(buff)
    cdef pair[uint64,uint64] tseed
    tseed.first, tseed.second = seed_0, seed_1
    cdef pair[uint64,uint64] result = c_CityHash128WithSeed(array, len(array), tseed)
    return 0x10000000000000000L * long(result.first) + long(result.second)
