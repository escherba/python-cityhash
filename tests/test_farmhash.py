"""
Python-based tests for farmhash extension
"""
import random
import string
import sys
import unittest

from farmhash import (
    FarmHash32,
    FarmHash32WithSeed,
    FarmHash64,
    FarmHash64WithSeed,
    FarmHash64WithSeeds,
    FarmHash128,
    FarmHash128WithSeed,
    Fingerprint32,
    Fingerprint64,
    Fingerprint128,
)


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
        self.assertEqual(FarmHash32(EMPTY_STRING), FarmHash32(EMPTY_UNICODE))

    def test_string_unicode_64(self):
        """Empty Python string has same hash value as empty Unicode string
        """
        self.assertEqual(FarmHash64WithSeed(EMPTY_STRING), FarmHash64WithSeed(EMPTY_UNICODE))

    def test_string_unicode_128(self):
        """Empty Python string has same hash value as empty Unicode string
        """
        self.assertEqual(FarmHash128WithSeed(EMPTY_STRING), FarmHash128WithSeed(EMPTY_UNICODE))

    def test_consistent_encoding_32(self):
        """ASCII-range Unicode strings have the same hash values as ASCII strings
        """
        text = u"abracadabra"  # pylint: disable=redundant-u-string-prefix
        self.assertEqual(FarmHash32(text), FarmHash32(text.encode("utf-8")))

    def test_consistent_encoding_64(self):
        """ASCII-range Unicode strings have the same hash values as ASCII strings
        """
        text = u"abracadabra"  # pylint: disable=redundant-u-string-prefix
        self.assertEqual(FarmHash64WithSeed(text), FarmHash64WithSeed(text.encode("utf-8")))

    def test_consistent_encoding_128(self):
        """ASCII-range Unicode strings have the same hash values as ASCII strings
        """
        text = u"abracadabra"  # pylint: disable=redundant-u-string-prefix
        self.assertEqual(FarmHash128WithSeed(text), FarmHash128WithSeed(text.encode("utf-8")))

    def test_unicode_1_32(self):
        """Accepts Unicode input"""
        test_case = u"abc"  # pylint: disable=redundant-u-string-prefix
        self.assertTrue(isinstance(FarmHash32(test_case), int))

    def test_unicode_1_64(self):
        """Accepts Unicode input"""
        test_case = u"abc"  # pylint: disable=redundant-u-string-prefix
        self.assertTrue(isinstance(FarmHash64WithSeed(test_case), long))

    def test_unicode_1_128(self):
        """Accepts Unicode input"""
        test_case = u"abc"  # pylint: disable=redundant-u-string-prefix
        self.assertTrue(isinstance(FarmHash128WithSeed(test_case), long))

    def test_unicode_2_32(self):
        """Accepts Unicode input outside of ASCII range"""
        test_case = u'\u2661'  # pylint: disable=redundant-u-string-prefix
        self.assertTrue(isinstance(FarmHash32(test_case), int))

    def test_unicode_2_64(self):
        """Accepts Unicode input outside of ASCII range"""
        test_case = u'\u2661'  # pylint: disable=redundant-u-string-prefix
        self.assertTrue(isinstance(FarmHash64WithSeed(test_case), long))

    def test_unicode_2_128(self):
        """Accepts Unicode input outside of ASCII range"""
        test_case = u'\u2661'  # pylint: disable=redundant-u-string-prefix
        self.assertTrue(isinstance(FarmHash128WithSeed(test_case), long))

    def test_unicode_2_128_seed(self):
        """Accepts Unicode input outside of ASCII range"""
        test_case = u'\u2661'  # pylint: disable=redundant-u-string-prefix
        result = FarmHash128WithSeed(test_case, seed=FarmHash128WithSeed(test_case))
        self.assertTrue(isinstance(result, long))

    def test_argument_types(self):
        """Accepts different kinds of buffer-compatible objects"""
        funcs = [FarmHash32, FarmHash64, FarmHash128,
                 FarmHash32WithSeed, FarmHash64WithSeed, FarmHash64WithSeeds,
                 FarmHash128WithSeed, Fingerprint32, Fingerprint64,
                 Fingerprint128]
        args = [b'ab\x00c', bytearray(b'ab\x00c'), memoryview(b'ab\x00c')]
        for func in funcs:
            values = set(func(arg) for arg in args)
            self.assertEqual(len(values), 1, values)

    def test_refcounts(self):
        """Doesn't leak references to its argument"""
        funcs = [FarmHash32, FarmHash64, FarmHash128,
                 FarmHash32WithSeed, FarmHash64WithSeed, FarmHash64WithSeeds,
                 FarmHash128WithSeed, Fingerprint32, Fingerprint64,
                 Fingerprint128]
        args = ['abc', b'abc', bytearray(b'def'), memoryview(b'ghi')]
        for func in funcs:
            for arg in args:
                old_refcount = sys.getrefcount(arg)
                func(arg)
                self.assertEqual(sys.getrefcount(arg), old_refcount)

    def test_different_seeds(self):
        """Ensure we get different results with different seeds"""

        test_string = 'just a string'

        self.assertNotEqual(FarmHash32WithSeed(test_string, 0),
                            FarmHash32WithSeed(test_string, 1))

        self.assertNotEqual(FarmHash64WithSeed(test_string, 0),
                            FarmHash64WithSeed(test_string, 1))

        self.assertNotEqual(FarmHash64WithSeeds(test_string, 0, 0),
                            FarmHash64WithSeeds(test_string, 0, 1))

        self.assertNotEqual(FarmHash128WithSeed(test_string, 0),
                            FarmHash128WithSeed(test_string, 1))

    def test_func_raises_type_error(self):
        """Check that functions raise type error"""
        funcs = [FarmHash32, FarmHash32WithSeed, FarmHash64, FarmHash128,
                 FarmHash64WithSeed, FarmHash64WithSeeds,
                 FarmHash128WithSeed, Fingerprint32, Fingerprint64,
                 Fingerprint128]
        for func in funcs:
            with self.assertRaises(TypeError):
                func([])
