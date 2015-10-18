CityHash
========

This is a Python wrapper around a C implementation of CityHash, a fast non-cryptographic hashing algorithm.

To get started, clone this repo and run the setup.py script, or, alternatively

.. code-block:: bash

    pip install -U cython
    pip install git+https://github.com/escherba/python-cityhash


Example Usage
-------------

The package contains 64- and 128-bit implementations of CityHash algorithm

.. code-block:: python

    >>> from cityhash import CityHash64, CityHash128
    >>> CityHash64("abc")
    2640714258260161385L
    >>> CityHash128("abc")
    76434233956484675513733017140465933893L

