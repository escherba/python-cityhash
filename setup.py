#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
from os.path import join, dirname
from setuptools import setup
from setuptools.extension import Extension
from setuptools.dist import Distribution

try:
    from cpuinfo import get_cpu_info
    CPU_FLAGS = get_cpu_info()['flags']
except Exception as exc:
    CPU_FLAGS = {}

try:
    from Cython.Distutils import build_ext
    USE_CYTHON = True
except ImportError:
    USE_CYTHON = False


class BinaryDistribution(Distribution):
    """
    Subclass the setuptools Distribution to flip the purity flag to false.
    See https://lucumr.pocoo.org/2014/1/27/python-on-wheels/
    """
    def is_pure(self):
        """Returns purity flag"""
        return False


CXXFLAGS = []

print(f"building for platform: {os.name}")
if os.name == "nt":
    CXXFLAGS.extend(["/O2"])
else:
    CXXFLAGS.extend([
        "-O3",
        "-Wno-unused-value",
        "-Wno-unused-function",
    ])


# Note: Only -msse4.2 has significant effect on performance;
# so not using other flags such as -maes and -mavx
if 'sse4_2' in CPU_FLAGS:
    print("Compiling with SSE4.2 enabled")
    CXXFLAGS.append('-msse4.2')
else:
    print("compiling without SSE4.2 support")


if USE_CYTHON:
    print("building extension using Cython")
    CMDCLASS = {'build_ext': build_ext}
    SRC_EXT = ".pyx"
else:
    print("building extension w/o Cython")
    CMDCLASS = {}
    SRC_EXT = ".cpp"


EXT_MODULES = [
    Extension(
        "cityhash",
        ["src/city.cc", "src/cityhash" + SRC_EXT],
        depends=["include/city.h"],
        language="c++",
        extra_compile_args=CXXFLAGS,
        include_dirs=['include'],
    ),
    Extension(
        "cityhashcrc",
        ["src/city.cc", "src/cityhashcrc" + SRC_EXT],
        depends=[
            "include/city.h",
            "include/citycrc.h",
        ],
        language="c++",
        extra_compile_args=CXXFLAGS,
        include_dirs=['include'],
    ),
    Extension(
        "farmhash",
        ["src/farm.cc", "src/farmhash" + SRC_EXT],
        depends=["include/farm.h"],
        language="c++",
        extra_compile_args=CXXFLAGS,
        include_dirs=['include'],
    )
]


VERSION = '0.3.0.post3'
URL = "https://github.com/escherba/python-cityhash"


LONG_DESCRIPTION = """

"""


def get_long_description():
    fname = join(dirname(__file__), 'README.rst')
    try:
        with open(fname, 'rb') as fh:
            return fh.read().decode('utf-8')
    except Exception:
        return LONG_DESCRIPTION


setup(
    version=VERSION,
    description="Python bindings for CityHash and FarmHash",
    author="Alexander [Amper] Marshalov",
    author_email="alone.amper+cityhash@gmail.com",
    maintainer="Eugene Scherba",
    maintainer_email="escherba+cityhash@gmail.com",
    url=URL,
    download_url=URL + "/tarball/master/" + VERSION,
    name='cityhash',
    license='MIT',
    zip_safe=False,
    cmdclass=CMDCLASS,
    ext_modules=EXT_MODULES,
    keywords=['google', 'hash', 'hashing', 'cityhash', 'farmhash', 'murmurhash'],
    classifiers=[
        'Development Status :: 5 - Production/Stable',
        'Intended Audience :: Developers',
        'Intended Audience :: Science/Research',
        'License :: OSI Approved :: MIT License',
        'Operating System :: OS Independent',
        'Programming Language :: C++',
        'Programming Language :: Cython',
        'Programming Language :: Python :: 2.7',
        'Programming Language :: Python :: 3.4',
        'Programming Language :: Python :: 3.5',
        'Programming Language :: Python :: 3.6',
        'Programming Language :: Python :: 3.7',
        'Programming Language :: Python :: 3.8',
        'Programming Language :: Python :: 3.9',
        'Topic :: Scientific/Engineering :: Information Analysis',
        'Topic :: Software Development :: Libraries',
        'Topic :: Utilities'
    ],
    long_description=get_long_description(),
    long_description_content_type='text/x-rst',
    tests_require=['pytest'],
    distclass=BinaryDistribution,
)
