CityHash
========

A Python wrapper around `CityHash <https://github.com/google/cityhash>`__

.. image:: https://travis-ci.org/escherba/python-cityhash.svg
    :target: https://travis-ci.org/escherba/python-cityhash


Installation
------------

To get started, clone this repo and run ``make env`` or, alternatively,
install it into your environment of choice (below). Note that you
will need to have Cython installed before you install this package.

.. code-block:: bash

    pip install -U cython
    pip install cityhash


Example Usage
-------------

The package contains 64- and 128-bit implementations of CityHash algorithm.

.. code-block:: python

    >>> from cityhash import CityHash64, CityHash128
    >>> CityHash64("abc")
    2640714258260161385L
    >>> CityHash128("abc")
    76434233956484675513733017140465933893L

