# CityHash/FarmHash

Python wrapper for [FarmHash](https://github.com/google/farmhash) and
[CityHash](https://github.com/google/cityhash), a family of fast
non-cryptographic hash functions.

[![Build
Status](https://github.com/escherba/python-cityhash/actions/workflows/build.yml/badge.svg?branch=master)](https://github.com/escherba/python-cityhash/actions/workflows/build.yml)
[![Latest
Version](https://img.shields.io/pypi/v/cityhash.svg)](https://pypi.python.org/pypi/cityhash)
[![Downloads](https://img.shields.io/pypi/dm/cityhash.svg)](https://pypi.python.org/pypi/cityhash)
[![License](https://img.shields.io/pypi/l/cityhash.svg)](https://opensource.org/licenses/mit-license)
[![Supported Python
versions](https://img.shields.io/pypi/pyversions/cityhash.svg)](https://pypi.python.org/pypi/cityhash)

## Getting Started

To use this package in your program, simply type

``` bash
pip install cityhash
```

This package exposes Python APIs for CityHash and FarmHash under `cityhash` and
`farmhash` namespaces, respectively. Each provides 32-, 64- and 128-bit
implementations.

## Usage Examples

### Stateless hashing

Usage example for FarmHash:

``` python
>>> from farmhash import FarmHash32, FarmHash64, FarmHash128
>>> FarmHash32("abc")
1961358185
>>> FarmHash64("abc")
2640714258260161385
>>> FarmHash128("abc")
76434233956484675513733017140465933893

```

### Hardware-independent fingerprints

Fingerprints are seedless hashes which are guaranteed to be hardware- and
platform-independent. This can be useful for networking applications which
require persisting hashed values.

``` python
>>> from farmhash import Fingerprint128
>>> Fingerprint128("abc")
76434233956484675513733017140465933893

```

### Incremental hashing

CityHash and FarmHash do not support incremental hashing and thus are not ideal
for hashing of streams. If you require incremental hashing feature, use
[MetroHash](https://github.com/escherba/python-metrohash) or
[xxHash](https://github.com/ifduyue/python-xxhash) instead, which do support
it.

### Fast hashing of NumPy arrays

The Python [Buffer Protocol](https://docs.python.org/3/c-api/buffer.html)
allows Python objects to expose their data as raw byte arrays to other objects,
for fast access without copying to a separate location in memory. Among others,
NumPy is a major framework that supports this protocol.

All hashing functions in this packege will read byte arrays from objects that
expose them via the buffer protocol. Here is an example showing hashing of a 4D
NumPy array:

``` python
>>> import numpy as np
>>> from farmhash import FarmHash64
>>> arr = np.zeros((256, 256, 4))
>>> FarmHash64(arr)
1550282412043536862

```

The arrays need to be contiguous for this to work. To convert a non-contiguous
array, use NumPy's `ascontiguousarray()` function.

## SSE4.2 support

The 32-bit FarmHash variants benefit tremendously from SSE4.2 optimization,
resulting in arguably the fastest non-cryptographic funtions in the 32-bit
category. The 64-bit FarmHash version also benefits from SSE4.2 being enabled,
but not as much as the 32-bit version does. It is still among the fastest
64-bit hash functions.

The vanilla CityHash fucntions (under `cityhash` module) do not take advantage
of SSE4.2. Instead, the `cityhashcrc` module (provided with this package for
x86-64 Mac and Linux platforms) exposes 128- and 256-bit CRC functions that
were specifically built take advantage from microprocessor-specific
instructions and which do harness SSE4.2, These functions are very fast, and in
fact beat FarmHash128 on speed (though please verify for yourself whether they
provide sufficient randomness).

For most use cases, I would recommend FarmHash over CityHash as it handles
SSE4.2 optimizations more transparently and includes a bunch of other
improvements.

## Development

### Local workflow

For those who want to contribute, here is a quick start using some makefile
commands:

``` bash
git clone https://github.com/escherba/python-cityhash.git
cd python-cityhash
make env           # create a Python virtualenv
make test          # run Python tests
make cpp-test      # run C++ tests
make shell         # enter IPython shell
```

The Makefiles provided have self-documenting targets. To find out which targets
are available, type:

``` bash
make help
```

### Distribution

The wheels are built using [cibuildwheel](https://cibuildwheel.readthedocs.io/)
and are distributed to PyPI using GitHub actions using [this
workflow](.github/workflows/publish.yml). The wheels contain compiled binaries
and are available for the following platforms: windows-amd64, ubuntu-x86,
linux-x86\_64, linux-aarch64, and macosx-x86\_64.

## See Also

For other fast non-cryptographic hash functions available as Python extensions,
see [MetroHash](https://github.com/escherba/python-metrohash),
[MurmurHash](https://github.com/hajimes/mmh3), and
[xxHash](https://github.com/ifduyue/python-xxhash).

## Authors

The original CityHash Python bindings are due to Alexander \[Amper\] Marshalov.
These were rewritten in Cython by Eugene Scherba, who also added the FarmHash
bindings. The CityHash and FarmHash algorithms and their C++ implementation are
by Google.

## License

This software is licensed under the [MIT
License](http://www.opensource.org/licenses/mit-license). See the included
LICENSE file for details.
