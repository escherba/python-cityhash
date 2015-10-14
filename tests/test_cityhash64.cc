/*
 * =====================================================================================
 *
 *       Filename:  test_cityhash64.cc
 *
 *    Description:  Some basic tests for 64-based CityHash
 *
 *        Version:  1.0
 *        Created:  10/12/2015 16:30:58
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  Eugene Scherba (es)
 *   Organization:  -
 *
 * =====================================================================================
 */
#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <numeric>

#define CATCH_CONFIG_MAIN  // This tells Catch to provide a main() - only do this in one cpp file
#include "catch.hpp"
#include "city.h"

#define STRLEN(s) (sizeof(s)/sizeof(s[0]))
#define HASH64_SZ 8


TEST_CASE( "basic test", "[basic]" ) {
    const char test_string[] = "abracadabra";
    uint64 hash = CityHash64WithSeed(test_string, STRLEN(test_string), 0);
    REQUIRE(hash != 0);
}

TEST_CASE( "test different seeds", "[diff_seeds]" ) {
    const char test_string[] = "abracadabra";
    uint64 hash1 = CityHash64WithSeed(test_string, STRLEN(test_string), 0);
    uint64 hash2 = CityHash64WithSeed(test_string, STRLEN(test_string), 1);
    REQUIRE(hash1 != hash2);
}

TEST_CASE( "test different inputs", "[diff_inputs]" ) {
    const char test_string1[] = "abracadabr";
    const char test_string2[] = "abracaaabra";
    uint64 hash1 = CityHash64WithSeed(test_string1, STRLEN(test_string1), 0);
    uint64 hash2 = CityHash64WithSeed(test_string2, STRLEN(test_string2), 0);
    REQUIRE(hash1 != hash2);
}
