import array
import unittest
import random
import string
import sys

from cityhash import (
    CityHash32, CityHash64, CityHash64WithSeed, CityHash64WithSeeds,
    CityHash128, CityHash128WithSeed,
    )


if sys.version_info[0] >= 3:
    long = int


def random_string(n, alphabet=string.ascii_lowercase):
    return ''.join(random.choice(alphabet) for _ in range(n))


def random_splits(string, n, nsplits=2):
    splits = sorted([random.randint(0, n) for _ in range(nsplits - 1)])
    splits = [0] + splits + [n]
    for a, b in zip(splits, splits[1:]):
        yield string[a:b]


class TestStandalone(unittest.TestCase):

    def test_string_unicode_32(self):
        """Empty Python string has same hash value as empty Unicode string
        """
        self.assertEqual(CityHash32(""), CityHash32(u""))

    def test_string_unicode_64(self):
        """Empty Python string has same hash value as empty Unicode string
        """
        self.assertEqual(CityHash64WithSeed(""), CityHash64WithSeed(u""))

    def test_string_unicode_128(self):
        """Empty Python string has same hash value as empty Unicode string
        """
        self.assertEqual(CityHash128WithSeed(""), CityHash128WithSeed(u""))

    def test_consistent_encoding_32(self):
        """ASCII-range Unicode strings have the same hash values as ASCII strings
        """
        text = u"abracadabra"
        self.assertEqual(CityHash32(text), CityHash32(text.encode("utf-8")))

    def test_consistent_encoding_64(self):
        """ASCII-range Unicode strings have the same hash values as ASCII strings
        """
        text = u"abracadabra"
        self.assertEqual(CityHash64WithSeed(text), CityHash64WithSeed(text.encode("utf-8")))

    def test_consistent_encoding_128(self):
        """ASCII-range Unicode strings have the same hash values as ASCII strings
        """
        text = u"abracadabra"
        self.assertEqual(CityHash128WithSeed(text), CityHash128WithSeed(text.encode("utf-8")))

    def test_unicode_1_32(self):
        """Accepts Unicode input"""
        test_case = u"abc"
        self.assertTrue(isinstance(CityHash32(test_case), int))

    def test_unicode_1_64(self):
        """Accepts Unicode input"""
        test_case = u"abc"
        self.assertTrue(isinstance(CityHash64WithSeed(test_case), long))

    def test_unicode_1_128(self):
        """Accepts Unicode input"""
        test_case = u"abc"
        self.assertTrue(isinstance(CityHash128WithSeed(test_case), long))

    def test_unicode_2_32(self):
        """Accepts Unicode input outside of ASCII range"""
        test_case = u'\u2661'
        self.assertTrue(isinstance(CityHash32(test_case), int))

    def test_unicode_2_64(self):
        """Accepts Unicode input outside of ASCII range"""
        test_case = u'\u2661'
        self.assertTrue(isinstance(CityHash64WithSeed(test_case), long))

    def test_unicode_2_128(self):
        """Accepts Unicode input outside of ASCII range"""
        test_case = u'\u2661'
        self.assertTrue(isinstance(CityHash128WithSeed(test_case), long))

    def test_unicode_2_128_seed(self):
        """Accepts Unicode input outside of ASCII range"""
        test_case = u'\u2661'
        self.assertTrue(isinstance(CityHash128WithSeed(test_case, seed=CityHash128WithSeed(test_case)), long))

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
