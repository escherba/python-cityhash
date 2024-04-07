/*
 * =====================================================================================
 *
 *       Filename:  test_cityhash64.cc
 *
 *    Description:  C++-based tests for CityHash
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

TEST_CASE( "CityHash32: basic test", "[basic]" )
{
    const char test_string[] = "abracadabra";
    uint32 hash = CityHash32(test_string, STRLEN(test_string));
    REQUIRE(hash != 0);
}


TEST_CASE( "CityHash32: test different inputs", "[diff_inputs]" )
{
    const char test_string1[] = "abracadabr";
    const char test_string2[] = "abracaaabra";
    uint32 hash1 = CityHash32(test_string1, STRLEN(test_string1));
    uint32 hash2 = CityHash32(test_string2, STRLEN(test_string2));
    REQUIRE(hash1 != hash2);
}

TEST_CASE( "CityHash64: basic test", "[basic]" )
{
    const char test_string[] = "abracadabra";
    uint64 hash = CityHash64(test_string, STRLEN(test_string));
    REQUIRE(hash != 0);
}

// TEST_CASE( "CityHash64: match Rust", "[basic]" )
// {
//     const char test_string[] = "hello";
//     uint64 hash = CityHash64(test_string, STRLEN(test_string));
//     REQUIRE(hash == 2578220239953316063);
// }

TEST_CASE( "CityHash64: test different inputs", "[diff_inputs]" )
{
    const char test_string1[] = "abracadabr";
    const char test_string2[] = "abracaaabra";
    uint64 hash1 = CityHash64(test_string1, STRLEN(test_string1));
    uint64 hash2 = CityHash64(test_string2, STRLEN(test_string2));
    REQUIRE(hash1 != hash2);
}

TEST_CASE( "CityHash128: basic test", "[basic]" )
{
    const char test_string[] = "abracadabra";
    uint128 hash = CityHash128(test_string, STRLEN(test_string));
    uint128 outcome_shouldnt_be = std::make_pair(0,0);
    REQUIRE(hash != outcome_shouldnt_be);
}

TEST_CASE( "CityHash128: test different inputs", "[diff_inputs]" )
{
    const char test_string1[] = "abracadabr";
    const char test_string2[] = "abracaaabra";
    uint128 hash1 = CityHash128(test_string1, STRLEN(test_string1));
    uint128 hash2 = CityHash128(test_string2, STRLEN(test_string2));
    REQUIRE(hash1 != hash2);
}

TEST_CASE( "CityHash64WithSeed: basic test", "[basic]" )
{
    const char test_string[] = "abracadabra";
    uint64 hash = CityHash64WithSeed(test_string, STRLEN(test_string), 0);
    REQUIRE(hash != 0);
}

TEST_CASE( "CityHash64WithSeed: test different seeds", "[diff_seeds]" )
{
    const char test_string[] = "abracadabra";
    uint64 hash1 = CityHash64WithSeed(test_string, STRLEN(test_string), 0);
    uint64 hash2 = CityHash64WithSeed(test_string, STRLEN(test_string), 1);
    REQUIRE(hash1 != hash2);
}

TEST_CASE( "CityHash64WithSeed: test different inputs", "[diff_inputs]" )
{
    const char test_string1[] = "abracadabr";
    const char test_string2[] = "abracaaabra";
    uint64 hash1 = CityHash64WithSeed(test_string1, STRLEN(test_string1), 0);
    uint64 hash2 = CityHash64WithSeed(test_string2, STRLEN(test_string2), 0);
    REQUIRE(hash1 != hash2);
}

TEST_CASE( "CityHash64WithSeed: different outcome than CityHash64", "[compare]" )
{
    const char test_string[] = "abracadabra";
    uint64 hash1 = CityHash64(test_string, STRLEN(test_string));
    uint64 hash2 = CityHash64WithSeed(test_string, STRLEN(test_string), 0);
    REQUIRE(hash1 != hash2);
}

TEST_CASE( "CityHash64WithSeeds: basic test", "[basic]" )
{
    const char test_string[] = "abracadabra";
    uint64 hash = CityHash64WithSeeds(test_string, STRLEN(test_string), 0, 0);
    REQUIRE(hash != 0);
}

TEST_CASE( "CityHash64WithSeeds: test different seeds", "[diff_seeds]" )
{
    const char test_string[] = "abracadabra";
    uint64 hash1 = CityHash64WithSeeds(test_string, STRLEN(test_string), 0, 0);
    uint64 hash2 = CityHash64WithSeeds(test_string, STRLEN(test_string), 0, 1);
    REQUIRE(hash1 != hash2);
}

TEST_CASE( "CityHash64WithSeeds: test different inputs", "[diff_inputs]" )
{
    const char test_string1[] = "abracadabr";
    const char test_string2[] = "abracaaabra";
    uint64 hash1 = CityHash64WithSeeds(test_string1, STRLEN(test_string1), 0, 0);
    uint64 hash2 = CityHash64WithSeeds(test_string2, STRLEN(test_string2), 0, 0);
    REQUIRE(hash1 != hash2);
}

TEST_CASE( "CityHash64WithSeeds: different outcome than CityHash64WithSeed", "[compare]" )
{
    const char test_string[] = "abracadabra";
    uint64 hash1 = CityHash64WithSeed(test_string, STRLEN(test_string), 0);
    uint64 hash2 = CityHash64WithSeeds(test_string, STRLEN(test_string), 0, 0);
    REQUIRE(hash1 != hash2);
}

TEST_CASE( "CityHash128WithSeed: basic test", "[basic]" )
{
    const char test_string[] = "abracadabra";
    uint128 seed = std::make_pair(0,0);
    uint128 hash = CityHash128WithSeed(test_string, STRLEN(test_string), seed);
    REQUIRE(hash.second != 0);
}

TEST_CASE( "CityHash128WithSeed: test different inputs", "[diff_inputs]" )
{
    const char test_string1[] = "abracadabr";
    const char test_string2[] = "abracaaabra";
    uint128 seed = std::make_pair(0,0); 
    uint128 hash1 = CityHash128WithSeed(test_string1, STRLEN(test_string1), seed);
    uint128 hash2 = CityHash128WithSeed(test_string2, STRLEN(test_string2), seed);
    REQUIRE(hash1 != hash2);
}

TEST_CASE( "CityHash128WithSeed: test different seeds", "[diff_seeds]" )
{
    const char test_string[] = "abracadabra";
    uint128 seed1 = std::make_pair(0,0); 
    uint128 seed2 = std::make_pair(0,1); 
    uint128 hash1 = CityHash128WithSeed(test_string, STRLEN(test_string), seed1);
    uint128 hash2 = CityHash128WithSeed(test_string, STRLEN(test_string), seed2);
    REQUIRE(hash1 != hash2);
}

TEST_CASE( "CityHash128WithSeed: different outcome than CityHash128", "[compare]" )
{
    const char test_string[] = "abracadabr";
    uint128 seed = std::make_pair(0,0);
    uint128 hash1 = CityHash128WithSeed(test_string, STRLEN(test_string), seed);
    uint128 hash2 = CityHash128(test_string, STRLEN(test_string));
    REQUIRE(hash1 != hash2);
}
