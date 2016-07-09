import unittest
import random
import string
from cityhash import CityHash32, CityHash64WithSeed, CityHash128WithSeed


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
