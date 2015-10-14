CityHash
========

This is a Python wrapper around a C implementation of CityHash, a fast non-cryptographic hashing algorithm.

To get started, clone this repo and run the setup.py script, or, alternatively

.. code-block:: bash

    pip install -U cython
    pip install git+https://github.com/escherba/cityhash#egg=cityhash-0.0.4


CityHash64
----------

64-bit implementation of CityHash algorithm

.. code-block:: python

    >>> from cityhash import CityHash64
    >>> CityHash64("abc")
    4220206313085259313L

