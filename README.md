# CityHash/FarmHash

Python wrapper for [FarmHash](https://github.com/google/farmhash) and
[CityHash](https://github.com/google/cityhash), a family of fast
non-cryptographic hash functions.

[![Build Status](https://img.shields.io/github/actions/workflow/status/escherba/python-cityhash/build.yml?branch=master)](https://github.com/escherba/python-cityhash/actions/workflows/build.yml)
[![PyPI Version](https://img.shields.io/pypi/v/cityhash.svg)](https://pypi.python.org/pypi/cityhash)
[![Conda-Forge Version](https://anaconda.org/conda-forge/python-cityhash/badges/version.svg)](https://anaconda.org/conda-forge/python-cityhash)
[![Downloads](https://img.shields.io/pypi/dm/cityhash.svg)](https://pypistats.org/packages/cityhash)
[![License](https://img.shields.io/pypi/l/cityhash.svg)](https://opensource.org/licenses/mit-license)
[![Supported Python Versions](https://img.shields.io/pypi/pyversions/cityhash.svg)](https://pypi.python.org/pypi/cityhash)

## Getting Started

To install from PyPI:

``` bash
pip install cityhash
```

To install in a Conda environment:

``` bash
conda install -c conda-forge python-cityhash
```

The package exposes Python APIs for CityHash and FarmHash under `cityhash` and
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

Fingerprints are seedless hashes that are guaranteed to be hardware- and
platform-independent. This can be useful for networking applications that
persist hashed values.

``` python
>>> from farmhash import Fingerprint128
>>> Fingerprint128("abc")
76434233956484675513733017140465933893

```

### Incremental hashing

CityHash and FarmHash do not support incremental hashing and thus are not ideal
for hashing of long character streams. If you require incremental hashing,
consider another hashing library, such as
[MetroHash](https://github.com/escherba/python-metrohash) or
[xxHash](https://github.com/ifduyue/python-xxhash).

### Fast hashing of NumPy arrays

The [Buffer Protocol](https://docs.python.org/3/c-api/buffer.html) allows
Python objects to expose their data as raw byte arrays for fast access without
having to copy to a separate location in memory. NumPy is one well-known
library that extensively uses this protocol.

All hashing functions in this package will read byte arrays from objects that
expose them via the buffer protocol. Here is an example showing hashing of a
four-dimensional NumPy array:

``` python
>>> import numpy as np
>>> from farmhash import FarmHash64
>>> arr = np.zeros((256, 256, 4))
>>> FarmHash64(arr)
1550282412043536862

```

The NumPy arrays need to be contiguous for this to work. To convert a
non-contiguous array, use NumPy's `ascontiguousarray()` function.

## SSE4.2 support

For x86-64 platforms, the PyPI repository for this package includes wheels
compiled with SSE4.2 support.  The 32- and 64-bit (but not the 128-bit)
variants of FarmHash significantly benefit from SSE4.2 instructions.

The vanilla CityHash functions (under `cityhash` module) do not take advantage
of SSE4.2. Instead, one can use the `cityhashcrc` module provided with this
package which exposes 128- and 256-bit CRC functions that do harness SSE4.2.
These functions are very fast, and even beat `FarmHash128` on speed (FarmHash
does not include a 256-bit function). Before using the CityHash-CRC functions,
however, you may want to check that they provide sufficient randomness for your
intended application.

## Development

### Local workflow

For those wanting to contribute, here is a quick start using Make commands:

``` bash
git clone https://github.com/escherba/python-cityhash.git
cd python-cityhash
make env           # create a virtual environment
make test          # run Python tests
make cpp-test      # run C++ tests
make shell         # enter IPython shell
```

To find out which Make targets are available, run:

``` bash
make help
```

### Distribution

The package wheels are built using
[cibuildwheel](https://cibuildwheel.readthedocs.io/) and are distributed to
PyPI using GitHub actions. The wheels contain compiled binaries and are
available for the following platforms: windows-amd64, ubuntu-x86,
linux-x86\_64, linux-aarch64, and macosx-x86\_64.

## See Also

For other fast non-cryptographic hash functions available as Python extensions,
see [MetroHash](https://github.com/escherba/python-metrohash),
[MurmurHash](https://github.com/hajimes/mmh3), and
[xxHash](https://github.com/ifduyue/python-xxhash).

## Authors

The original CityHash Python bindings are due to Alexander \[Amper\] Marshalov.
They were rewritten in Cython by Eugene Scherba, who also added the FarmHash
bindings. The CityHash and FarmHash algorithms and their C++ implementation are
by Google.

## License

This software is licensed under the [MIT
License](http://www.opensource.org/licenses/mit-license). See the included
LICENSE file for details.
