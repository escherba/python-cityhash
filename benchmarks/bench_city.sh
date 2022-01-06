#!/bin/bash

# Note: this benchamr script is based on a similar one for xxHash:
# https://github.com/ifduyue/python-xxhash

PYTHON=${PYTHON-`which python`}

echo Benchmarking CityHash...

echo -n "    64WithSeed      1000B: "
$PYTHON -mtimeit -s 'from cityhash import CityHash64WithSeed as hasher' \
                 -s 'import os'  \
                 -s 'import random' \
                 -s 'seed = random.randint(0, 0xffffffffffffffff)' \
                 -s 'data = os.urandom(1000)' \
                 'hasher(data, seed=seed)'

echo -n "    64WithSeed     10000B: "
$PYTHON -mtimeit -s 'from cityhash import CityHash64WithSeed as hasher' \
                 -s 'import os'  \
                 -s 'import random' \
                 -s 'seed = random.randint(0, 0xffffffffffffffff)' \
                 -s 'data = os.urandom(10000)' \
                 'hasher(data, seed=seed)'

echo -n "    128WithSeed     1000B: "
$PYTHON -mtimeit -s 'from cityhash import CityHash128WithSeed as hasher' \
                 -s 'import os'  \
                 -s 'import random' \
                 -s 'seed = random.randint(0, 0xffffffffffffffff)' \
                 -s 'data = os.urandom(1000)' \
                 'hasher(data, seed=seed)'

echo -n "    128WithSeed    10000B: "
$PYTHON -mtimeit -s 'from cityhash import CityHash128WithSeed as hasher' \
                 -s 'import os'  \
                 -s 'import random' \
                 -s 'seed = random.randint(0, 0xffffffffffffffff)' \
                 -s 'data = os.urandom(10000)' \
                 'hasher(data, seed=seed)'

echo -n "    Crc128WithSeed  1000B: "
$PYTHON -mtimeit -s 'from cityhashcrc import CityHashCrc128WithSeed as hasher' \
                 -s 'import os'  \
                 -s 'import random' \
                 -s 'seed = random.randint(0, 0xffffffffffffffff)' \
                 -s 'data = os.urandom(1000)' \
                 'hasher(data, seed=seed)'

echo -n "    Crc128WithSeed 10000B: "
$PYTHON -mtimeit -s 'from cityhashcrc import CityHashCrc128WithSeed as hasher' \
                 -s 'import os'  \
                 -s 'import random' \
                 -s 'seed = random.randint(0, 0xffffffffffffffff)' \
                 -s 'data = os.urandom(10000)' \
                 'hasher(data, seed=seed)'
