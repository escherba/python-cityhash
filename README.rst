CityHash
========

A Python wrapper around `CityHash <https://github.com/google/cityhash>`__

.. image:: https://img.shields.io/pypi/v/cityhash.svg
    :target: https://pypi.python.org/pypi/cityhash
    :alt: Latest Version

.. image:: https://img.shields.io/pypi/dm/cityhash.svg
    :target: https://pypi.python.org/pypi/cityhash
    :alt: Downloads

.. image:: https://circleci.com/gh/escherba/python-cityhash.png?style=shield
    :target: https://circleci.com/gh/escherba/python-cityhash
    :alt: Tests Status

Getting Started
---------------

To use this package in your program, simply type

.. code-block:: bash

    pip install cityhash


After that, you should be able to import the module and do things with it (see Example Usage below).

Example Usage
-------------

The package contains 64- and 128-bit implementations of the CityHash algorithm,
named as follows:

.. code-block:: python

    >>> from cityhash import CityHash32, CityHash64, CityHash128
    >>> print(CityHash32("abc"))
    795041479
    >>> print(CityHash64("abc"))
    2640714258260161385
    >>> print(CityHash128("abc"))
    76434233956484675513733017140465933893

Development
-----------
For those who want to contribute, here is a quick start using some makefile
commands:

.. code-block:: bash

    git clone https://github.com/escherba/python-cityhash.git
    cd python-cityhash
    make env           # creates a Python virtualenv
    make test          # runs both Python and C++ tests

See Also
--------
For other fast non-cryptographic hashing implementations available as Python
extensions, see `MetroHash <https://github.com/escherba/python-metrohash>`__
and `xxHash <https://github.com/lebedov/xxh>`__.

Authors
-------
The Python bindings were originally written by Alexander [Amper] Marshalov,
then repackaged for PyPI (with minor improvements) by Eugene Scherba. The
original CityHash algorithm is by Google.

License
-------
This software is licensed under the `MIT License
<http://www.opensource.org/licenses/mit-license>`_.  See the included LICENSE
file for more information.
