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

The package contains 64- and 128-bit implementations of CityHash algorithm that
are named as such:

.. code-block:: python

    >>> from cityhash import CityHash64, CityHash128
    >>> print(CityHash64("abc"))
    4220206313085259313
    >>> print(CityHash128("abc"))
    191491615738686005514802259311635598718

Development
-----------
If you want to contribute to this package by developing, the included Makefile
provides some useful commands to help you with that task:

.. code-block:: bash

    git clone https://github.com/escherba/python-cityhash.git
    cd python-cityhash
    make env           # creates a Python virtualenv
    make test          # runs both Python and C++ tests

See Also
--------
For other fast non-cryptographic hashing implementations available as Python
extensions, see `MetroHash <https://github.com/escherba/python-metrohash>`__
and `xxh <https://github.com/lebedov/xxh>`__.

Authors
-------
The Python bindings were originally written by Alexander [Amper] Marshalov and
were subsequently edited for more speed/versatility and packaged for PyPI by
Eugene Scherba. The original CityHash algorithm is by Google.

License
-------
This software is licensed under the `MIT License
<http://www.opensource.org/licenses/mit-license>`_.  See the included LICENSE
file for more information.
