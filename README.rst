CityHash
========

A Python wrapper around `FarmHash <https://github.com/google/farmhash>`__ and
`CityHash <https://github.com/google/cityhash>`__

.. image:: https://img.shields.io/pypi/v/cityhash.svg
    :target: https://pypi.python.org/pypi/cityhash
    :alt: Latest Version

.. image:: https://img.shields.io/pypi/dm/cityhash.svg
    :target: https://pypi.python.org/pypi/cityhash
    :alt: Downloads

.. image:: https://circleci.com/gh/escherba/python-cityhash.svg?style=shield
    :target: https://circleci.com/gh/escherba/python-cityhash
    :alt: Tests Status

.. image:: https://img.shields.io/pypi/pyversions/cityhash.svg
    :target: https://pypi.python.org/pypi/cityhash
    :alt: Supported Python versions

.. image:: https://img.shields.io/pypi/l/cityhash.svg
    :target: https://pypi.python.org/pypi/cityhash
    :alt: License

Getting Started
---------------

To use this package in your program, simply type

.. code-block:: bash

    pip install cityhash


After that, you should be able to import the module and do things with it (see
usage example below).

Usage Examples
--------------

Stateless hashing
~~~~~~~~~~~~~~~~~

This package exposes Python APIs for CityHash and FarmHash under ``cityhash``
and ``farmhash`` namespaces, respectively.  Each provides 32-, 64- and 128-bit
implementations. Usage example for `cityhash`:

.. code-block:: python

    >>> from cityhash import CityHash32, CityHash64, CityHash128
    >>> print(CityHash32("abc"))
    795041479
    >>> print(CityHash64("abc"))
    2640714258260161385
    >>> print(CityHash128("abc"))
    76434233956484675513733017140465933893

Hardware-independent fingerprints
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Fingerprints are seedless hashes which are guaranteed to be hardware- and
platform- independent.

.. code-block:: python

    >>> from farmhash import Fingerprint128
    >>> print(Fingerprint128("abc"))
    76434233956484675513733017140465933893

Incremental hashing
~~~~~~~~~~~~~~~~~~~

CityHash and FarmHash do not support incremental hashing. If you require this
feature, use `MetroHash <https://github.com/escherba/python-metrohash>`__
instead, which does support it.

Fast hashing of NumPy arrays
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The Python `Buffer Protocol <https://docs.python.org/3/c-api/buffer.html>`__
allows Python objects to expose their data as raw byte arrays to other objects,
for fast access without copying to a separate location in memory.  Notably,
NumPy is a major framework that supports this protocol.

The functions in these packages will read byt arrays from objects that expose
them via buffer protocol. Here is an example showing hashing of a 4D NumPy
array:

.. code-block:: python

    >>> import numpy as np
    >>> from farmhash import FarmHash64
    >>> arr = np.zeros((256, 256, 4))
    >>> FarmHash64(arr)
    1550282412043536862

Note that arrays need to be contiguous for this to work. To convert a
non-contiguous array, use NumPy's ``ascontiguousarray()`` function.

SSE4.2 support
~~~~~~~~~~~~~~

On CPUs that support SSE4.2 instruction set, FarmHash-64 has an advantage over
its non-optimized version and over vanilla CityHash-64, as can be seen below.
The numbers below were recoreded on a 2.4 GHz Intel Xeon CPU (E5-2620), and the
task was to hash a 512x512x3 NumPy array.

+----------------------+-------------------+-------------------+
| Method               | Time (64-bit)     | Time (128-bit)    |
+======================+===================+===================+
| FarmHash / SSE4.2    | 373 µs ± 48.3 µs  | 480 µs ± 15.3 µs  |
+----------------------+-------------------+-------------------+
| FarmHash             | 464 µs ± 19.2 µs  | 490 µs ± 23.0 µs  |
+----------------------+-------------------+-------------------+
| CityHashCrc / SSE4.2 |        N/A        | 377 µs ± 21.7 µs  |
+----------------------+-------------------+-------------------+
| CityHash             | 492 µs ± 16.7 µs  | 487 µs ± 22.0 µs  |
+----------------------+-------------------+-------------------+

The SSE4 support in CityHash is available under ``cityhashcrc`` module.  To use
SSE4.2-optimized CityHash in a platform-independent way, you can use the
following:

.. code-block:: python

    try:
        from cityhashcrc import CityHashCrc128 as CityHash128
    except Exception:
        from cityhash import CityHash128

Development
-----------

For those who want to contribute, here is a quick start using some makefile
commands:

.. code-block:: bash

    git clone https://github.com/escherba/python-cityhash.git
    cd python-cityhash
    make env           # create a Python virtualenv
    make test          # run Python tests
    make cpp-test      # run C++ tests

The Makefiles provided have self-documenting targets. To find out which targets
are available, type:

.. code-block:: bash

    make help

See Also
--------
For other fast non-cryptographic hashing implementations available as Python
extensions, see `MetroHash <https://github.com/escherba/python-metrohash>`__
and `MurmurHash <https://github.com/hajimes/mmh3>`__.

Authors
-------
The original Python bindings were written by Alexander [Amper] Marshalov, then
were largely rewritten for more flexibility by Eugene Scherba. The CityHash and
FarmHash algorithms and their C++ implementation are by Google.

License
-------
This software is licensed under the `MIT License
<http://www.opensource.org/licenses/mit-license>`_.  See the included LICENSE
file for details.
