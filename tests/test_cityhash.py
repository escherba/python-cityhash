import unittest
import random
import string
from cityhash import CityHash64WithSeed, CityHash128WithSeed


def random_string(n, alphabet=string.ascii_lowercase):
    return ''.join(random.choice(alphabet) for _ in range(n))


def random_splits(string, n, nsplits=2):
    splits = sorted([random.randint(0, n) for _ in range(nsplits - 1)])
    splits = [0] + splits + [n]
    for a, b in zip(splits, splits[1:]):
        yield string[a:b]


class TestStandalone(unittest.TestCase):

    def test_unicode_64_1(self):
        """Must accept Unicode input"""
        test_case = u"abc"
        self.assertEqual(6234256295332240817L,
                         CityHash64WithSeed(test_case))

    def test_unicode_64_2(self):
        """Must accept Unicode input"""
        test_case = u'\u2661'
        self.assertEqual(9639749241433308564L,
                         CityHash64WithSeed(test_case))

    def test_unicode_128_1(self):
        """Must accept Unicode input"""
        test_case = u"abc"
        self.assertEqual(164655989659061527156339546049943539076L,
                         CityHash128WithSeed(test_case))

    def test_unicode_128_2(self):
        """Must accept Unicode input"""
        test_case = u'\u2661'
        self.assertEqual(177922507742382362025855314734089733878L,
                         CityHash128WithSeed(test_case))
