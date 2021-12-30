#!/usr/bin/env python
# -*- coding: utf-8 -*-
import warnings
from os.path import join, dirname
from setuptools import setup
from setuptools.extension import Extension
from setuptools.dist import Distribution

try:
    from cpuinfo import get_cpu_info
    cpu_info = get_cpu_info()
    HAVE_SSE42 = 'sse4_2' in cpu_info['flags']
except Exception as exc:
    HAVE_SSE42 = False

try:
    from Cython.Distutils import build_ext
except ImportError:
    build_ext = None


class BinaryDistribution(Distribution):
    """
    Subclass the setuptools Distribution to flip the purity flag to false.
    See https://lucumr.pocoo.org/2014/1/27/python-on-wheels/
    """
    def is_pure(self):
        """Returns purity flag"""
        return False


CXXFLAGS = """
-O3
-Wno-unused-value
-Wno-unused-function
""".split()

if HAVE_SSE42:
    warnings.warn("Compiling with SSE4.2 enabled")
    CXXFLAGS.append('-msse4.2')
else:
    warnings.warn("compiling without SSE4.2 support")


INCLUDE_DIRS = ['include']
CXXHEADERS = [
    "include/citycrc.h",
    "include/city.h",
    "include/config.h",
]
CXXSOURCES = [
    "src/city.cc",
]

CMDCLASS = {}
EXT_MODULES = []

if build_ext is not None:
    CMDCLASS['build_ext'] = build_ext
    EXT_MODULES.append(
        Extension(
            "cityhash",
            CXXSOURCES + ["src/cityhash.pyx"],
            depends=CXXHEADERS,
            language="c++",
            extra_compile_args=CXXFLAGS,
            include_dirs=INCLUDE_DIRS)
        )
else:
    EXT_MODULES.append(
        Extension(
            "cityhash",
            CXXSOURCES + ["src/cityhash.cpp"],
            depends=CXXHEADERS,
            language="c++",
            extra_compile_args=CXXFLAGS,
            include_dirs=INCLUDE_DIRS)
        )


VERSION = '0.2.4.post11'
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
    description="Python bindings for CityHash, a fast non-cryptographic hash algorithm",
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
    keywords=['hash', 'hashing', 'cityhash', 'murmurhash'],
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
