"""
Python-based tests for cityhash extension
"""
import unittest
import random
import string
import sys

from cityhash import CityHash32
from cityhash import CityHash64
from cityhash import CityHash64WithSeed
from cityhash import CityHash64WithSeeds
from cityhash import CityHash128
from cityhash import CityHash128WithSeed


EMPTY_STRING = ""
EMPTY_UNICODE = u""  # pylint: disable=redundant-u-string-prefix


if sys.version_info[0] >= 3:
    long = int


def random_string(n, alphabet=string.ascii_lowercase):
    """generate a random string"""
    return ''.join(random.choice(alphabet) for _ in range(n))


def random_splits(s, n, nsplits=2):
    """split string in random places"""
    splits = sorted([random.randint(0, n) for _ in range(nsplits - 1)])
    splits = [0] + splits + [n]
    for begin, end in zip(splits, splits[1:]):
        yield s[begin:end]


class TestStateless(unittest.TestCase):

    """test stateless hashing"""

    def test_string_unicode_32(self):
        """Empty Python string has same hash value as empty Unicode string
        """
        self.assertEqual(CityHash32(EMPTY_STRING), CityHash32(EMPTY_UNICODE))

    def test_string_unicode_64(self):
        """Empty Python string has same hash value as empty Unicode string
        """
        self.assertEqual(CityHash64WithSeed(EMPTY_STRING), CityHash64WithSeed(EMPTY_UNICODE))

    def test_string_unicode_128(self):
        """Empty Python string has same hash value as empty Unicode string
        """
        self.assertEqual(CityHash128WithSeed(EMPTY_STRING), CityHash128WithSeed(EMPTY_UNICODE))

    def test_consistent_encoding_32(self):
        """ASCII-range Unicode strings have the same hash values as ASCII strings
        """
        text = u"abracadabra"  # pylint: disable=redundant-u-string-prefix
        self.assertEqual(CityHash32(text), CityHash32(text.encode("utf-8")))

    def test_consistent_encoding_64(self):
        """ASCII-range Unicode strings have the same hash values as ASCII strings
        """
        text = u"abracadabra"  # pylint: disable=redundant-u-string-prefix
        self.assertEqual(CityHash64WithSeed(text), CityHash64WithSeed(text.encode("utf-8")))

    def test_consistent_encoding_128(self):
        """ASCII-range Unicode strings have the same hash values as ASCII strings
        """
        text = u"abracadabra"  # pylint: disable=redundant-u-string-prefix
        self.assertEqual(CityHash128WithSeed(text), CityHash128WithSeed(text.encode("utf-8")))

    def test_unicode_1_32(self):
        """Accepts Unicode input"""
        test_case = u"abc"  # pylint: disable=redundant-u-string-prefix
        self.assertTrue(isinstance(CityHash32(test_case), int))

    def test_unicode_1_64(self):
        """Accepts Unicode input"""
        test_case = u"abc"  # pylint: disable=redundant-u-string-prefix
        self.assertTrue(isinstance(CityHash64WithSeed(test_case), long))

    def test_unicode_1_128(self):
        """Accepts Unicode input"""
        test_case = u"abc"  # pylint: disable=redundant-u-string-prefix
        self.assertTrue(isinstance(CityHash128WithSeed(test_case), long))

    def test_unicode_2_32(self):
        """Accepts Unicode input outside of ASCII range"""
        test_case = u'\u2661'  # pylint: disable=redundant-u-string-prefix
        self.assertTrue(isinstance(CityHash32(test_case), int))

    def test_unicode_2_64(self):
        """Accepts Unicode input outside of ASCII range"""
        test_case = u'\u2661'  # pylint: disable=redundant-u-string-prefix
        self.assertTrue(isinstance(CityHash64WithSeed(test_case), long))

    def test_unicode_2_128(self):
        """Accepts Unicode input outside of ASCII range"""
        test_case = u'\u2661'  # pylint: disable=redundant-u-string-prefix
        self.assertTrue(isinstance(CityHash128WithSeed(test_case), long))

    def test_unicode_2_128_seed(self):
        """Accepts Unicode input outside of ASCII range"""
        test_case = u'\u2661'  # pylint: disable=redundant-u-string-prefix
        result = CityHash128WithSeed(test_case, seed=CityHash128WithSeed(test_case))
        self.assertTrue(isinstance(result, long))

    def test_argument_types(self):
        """Accepts different kinds of buffer-compatible objects"""
        funcs = [CityHash32, CityHash64, CityHash128,
                 CityHash64WithSeed, CityHash64WithSeeds,
                 CityHash128WithSeed]
        args = [b'ab\x00c', bytearray(b'ab\x00c'), memoryview(b'ab\x00c')]
        for func in funcs:
            values = set(func(arg) for arg in args)
            self.assertEqual(len(values), 1, values)

    def test_refcounts(self):
        """Doesn't leak references to its argument"""
        funcs = [CityHash32, CityHash64, CityHash128,
                 CityHash64WithSeed, CityHash64WithSeeds,
                 CityHash128WithSeed]
        args = ['abc', b'abc', bytearray(b'def'), memoryview(b'ghi')]
        for func in funcs:
            for arg in args:
                old_refcount = sys.getrefcount(arg)
                func(arg)
                self.assertEqual(sys.getrefcount(arg), old_refcount)

    def test_different_seeds(self):
        """Ensure we get different results with different seeds"""

        test_string = 'just a string'

        self.assertNotEqual(CityHash64WithSeed(test_string, 0),
                            CityHash64WithSeed(test_string, 1))

        self.assertNotEqual(CityHash64WithSeeds(test_string, 0, 0),
                            CityHash64WithSeeds(test_string, 0, 1))

        self.assertNotEqual(CityHash128WithSeed(test_string, 0),
                            CityHash128WithSeed(test_string, 1))

    def test_func_raises_type_error(self):
        """Check that functions raise type error"""
        funcs = [CityHash32, CityHash64, CityHash128,
                 CityHash64WithSeed, CityHash64WithSeeds,
                 CityHash128WithSeed]
        for func in funcs:
            with self.assertRaises(TypeError):
                func([])
