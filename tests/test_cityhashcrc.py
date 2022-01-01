"""
Python-based tests for cityhash extension
"""
import random
import string
import sys
import unittest

try:
    from cityhashcrc import (
        CityHashCrc128,
        CityHashCrc128WithSeed,
        CityHashCrc256,
    )

    HAVE_CRC_MODULE = True
except:
    HAVE_CRC_MODULE = False


def random_string(n, alphabet=string.ascii_lowercase):
    """generate a random string"""
    return "".join(random.choice(alphabet) for _ in range(n))


def random_splits(s, n, nsplits=2):
    """split string in random places"""
    splits = sorted([random.randint(0, n) for _ in range(nsplits - 1)])
    splits = [0] + splits + [n]
    for begin, end in zip(splits, splits[1:]):
        yield s[begin:end]


class TestStateless(unittest.TestCase):

    """test stateless hashing"""

    @classmethod
    def setUpClass(cls):
        if not HAVE_CRC_MODULE:
            raise unittest.SkipTest("no CRC module")

    def test_argument_types(self):
        """Accepts different kinds of buffer-compatible objects"""
        funcs = [
            CityHashCrc128,
            CityHashCrc128WithSeed,
            CityHashCrc256
        ]
        args = [b"ab\x00c", bytearray(b"ab\x00c"), memoryview(b"ab\x00c")]
        for func in funcs:
            values = set(func(arg) for arg in args)
            self.assertEqual(len(values), 1, values)

    def test_refcounts(self):
        """Doesn't leak references to its argument"""
        funcs = [
            CityHashCrc128,
            CityHashCrc128WithSeed,
            CityHashCrc256
        ]
        args = ["abc", b"abc", bytearray(b"def"), memoryview(b"ghi")]
        for func in funcs:
            for arg in args:
                old_refcount = sys.getrefcount(arg)
                func(arg)
                self.assertEqual(sys.getrefcount(arg), old_refcount)

    def test_different_seeds(self):
        """Ensure we get different results with different seeds"""

        test_string = "just a string"

        funcs = [
            CityHashCrc128WithSeed,
        ]

        for func in funcs:
            self.assertNotEqual(
                func(test_string, 0),
                func(test_string, 1)
            )

    def test_func_raises_type_error(self):
        """Check that functions raise type error"""
        funcs = [
            CityHashCrc128,
            CityHashCrc128WithSeed,
            CityHashCrc256
        ]
        for func in funcs:
            with self.assertRaises(TypeError):
                func([])
