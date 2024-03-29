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
    return "".join(random.choice(alphabet) for _ in range(n))


def random_splits(s, n, nsplits=2):
    """split string in random places"""
    splits = sorted([random.randint(0, n) for _ in range(nsplits - 1)])
    splits = [0] + splits + [n]
    for begin, end in zip(splits, splits[1:]):
        yield s[begin:end]


class TestUnicode(unittest.TestCase):

    """test unicode-related properties (deprecated in Python 3)"""

    def test_string_unicode_32(self):
        """Empty Python string has same hash value as empty Unicode string"""
        self.assertEqual(FarmHash32(EMPTY_STRING), FarmHash32(EMPTY_UNICODE))

    def test_string_unicode_64(self):
        """Empty Python string has same hash value as empty Unicode string"""
        self.assertEqual(
            FarmHash64WithSeed(EMPTY_STRING), FarmHash64WithSeed(EMPTY_UNICODE)
        )

    def test_string_unicode_128(self):
        """Empty Python string has same hash value as empty Unicode string"""
        self.assertEqual(
            FarmHash128WithSeed(EMPTY_STRING), FarmHash128WithSeed(EMPTY_UNICODE)
        )

    def test_consistent_encoding_32(self):
        """ASCII-range Unicode strings have the same hash values as ASCII strings"""
        text = u"abracadabra"  # pylint: disable=redundant-u-string-prefix
        self.assertEqual(FarmHash32(text), FarmHash32(text.encode("utf-8")))

    def test_consistent_encoding_64(self):
        """ASCII-range Unicode strings have the same hash values as ASCII strings"""
        text = u"abracadabra"  # pylint: disable=redundant-u-string-prefix
        self.assertEqual(
            FarmHash64WithSeed(text), FarmHash64WithSeed(text.encode("utf-8"))
        )

    def test_consistent_encoding_128(self):
        """ASCII-range Unicode strings have the same hash values as ASCII strings"""
        text = u"abracadabra"  # pylint: disable=redundant-u-string-prefix
        self.assertEqual(
            FarmHash128WithSeed(text), FarmHash128WithSeed(text.encode("utf-8"))
        )

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
        test_case = u"\u2661"  # pylint: disable=redundant-u-string-prefix
        self.assertTrue(isinstance(FarmHash32(test_case), int))

    def test_unicode_2_64(self):
        """Accepts Unicode input outside of ASCII range"""
        test_case = u"\u2661"  # pylint: disable=redundant-u-string-prefix
        self.assertTrue(isinstance(FarmHash64WithSeed(test_case), long))

    def test_unicode_2_128(self):
        """Accepts Unicode input outside of ASCII range"""
        test_case = u"\u2661"  # pylint: disable=redundant-u-string-prefix
        self.assertTrue(isinstance(FarmHash128WithSeed(test_case), long))

    def test_unicode_2_128_seed(self):
        """Accepts Unicode input outside of ASCII range"""
        test_case = u"\u2661"  # pylint: disable=redundant-u-string-prefix
        result = FarmHash128WithSeed(test_case, seed=FarmHash128WithSeed(test_case))
        self.assertTrue(isinstance(result, long))


class TestFingerprints(unittest.TestCase):

    """Fingerprints should be the same across platforms"""

    def test_fingerprint32(self):
        """test 32-bit fingerprint"""
        test_string = "abc"
        self.assertEqual(Fingerprint32(test_string), 795041479)

    def test_fingerprint64(self):
        """test 64-bit fingerprint"""
        test_string = "abc"
        self.assertEqual(Fingerprint64(test_string), 2640714258260161385)

    def test_fingerprint128(self):
        """test 128-bit fingerprint"""
        test_string = "abc"
        self.assertEqual(
            Fingerprint128(test_string), 76434233956484675513733017140465933893
        )


class TestProperties(unittest.TestCase):

    """test various properties"""

    def test_argument_types(self):
        """Should accept byte arrays and buffers"""
        funcs = [
            FarmHash32,
            FarmHash64,
            FarmHash128,
            FarmHash32WithSeed,
            FarmHash64WithSeed,
            FarmHash64WithSeeds,
            FarmHash128WithSeed,
            Fingerprint32,
            Fingerprint64,
            Fingerprint128,
        ]
        args = [b"ab\x00c", bytearray(b"ab\x00c"), memoryview(b"ab\x00c")]
        for func in funcs:
            values = set(func(arg) for arg in args)
            self.assertEqual(len(values), 1, values)

    def test_refcounts(self):
        """Argument reference count should not change"""
        funcs = [
            FarmHash32,
            FarmHash64,
            FarmHash128,
            FarmHash32WithSeed,
            FarmHash64WithSeed,
            FarmHash64WithSeeds,
            FarmHash128WithSeed,
            Fingerprint32,
            Fingerprint64,
            Fingerprint128,
        ]
        args = ["abc", b"abc", bytearray(b"def"), memoryview(b"ghi")]
        for func in funcs:
            for arg in args:
                old_refcount = sys.getrefcount(arg)
                func(arg)
                self.assertEqual(sys.getrefcount(arg), old_refcount)

    def test_different_seeds(self):
        """Different seeds should produce different results"""

        test_string = "just a string"

        funcs = [
            FarmHash32WithSeed,
            FarmHash64WithSeed,
            FarmHash64WithSeeds,
            FarmHash128WithSeed,
        ]

        for func in funcs:
            self.assertNotEqual(func(test_string, 0), func(test_string, 1))

    def test_func_raises_type_error(self):
        """Raises type error on bad argument type"""
        funcs = [
            FarmHash32,
            FarmHash32WithSeed,
            FarmHash64,
            FarmHash128,
            FarmHash64WithSeed,
            FarmHash64WithSeeds,
            FarmHash128WithSeed,
            Fingerprint32,
            Fingerprint64,
            Fingerprint128,
        ]
        for func in funcs:
            with self.assertRaises(TypeError):
                func([])
