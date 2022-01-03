#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
import struct
from os.path import join, dirname

from setuptools import setup
from setuptools.dist import Distribution
from setuptools.extension import Extension

try:
    from cpuinfo import get_cpu_info

    CPU_FLAGS = get_cpu_info()["flags"]
except Exception as exc:
    print("exception loading cpuinfo", exc)
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


def get_system_bits():
    """Return 32 for 32-bit systems and 64 for 64-bit"""
    return struct.calcsize("P") * 8


SYSTEM = os.name
BITS = get_system_bits()
HAVE_SSE42 = "sse4_2" in CPU_FLAGS

CXXFLAGS = []

print("system: %s-%d" % (SYSTEM, BITS))
print("available CPU flags:", CPU_FLAGS)
print("environment:", ", ".join(["%s=%s" % (k, v) for k, v in os.environ.items()]))

if SYSTEM == "nt":
    CXXFLAGS.extend(["/O2"])
else:
    CXXFLAGS.extend(
        [
            "-O3",
            "-Wno-unused-value",
            "-Wno-unused-function",
        ]
    )

# The "cibuildwheel" tool sets the variable below to
# something like x86_64, aarch64, i686, and so on.
TARGET_ARCH = os.environ.get("AUDITWHEEL_ARCH")

if HAVE_SSE42 and (TARGET_ARCH in [None, "x86_64"]) and (BITS == 64):
    # Note: Only -msse4.2 has significant effect on performance;
    # so not using other flags such as -maes and -mavx
    print("enabling SSE4.2 on compile")
    if SYSTEM == "nt":
        CXXFLAGS.append("/D__SSE4_2__")
    else:
        CXXFLAGS.append("-msse4.2")


if USE_CYTHON:
    print("building extension using Cython")
    CMDCLASS = {"build_ext": build_ext}
    SRC_EXT = ".pyx"
else:
    print("building extension w/o Cython")
    CMDCLASS = {}
    SRC_EXT = ".cpp"


EXT_MODULES = [
    Extension(
        "cityhash",
        ["src/city.cc", "src/cityhash" + SRC_EXT],
        depends=["src/city.h"],
        language="c++",
        extra_compile_args=CXXFLAGS,
        include_dirs=["src"],
    ),
    Extension(
        "farmhash",
        ["src/farm.cc", "src/farmhash" + SRC_EXT],
        depends=["src/farm.h"],
        language="c++",
        extra_compile_args=CXXFLAGS,
        include_dirs=["src"],
    ),
]

if HAVE_SSE42 and (TARGET_ARCH in [None, "x86_64"]) and (BITS == 64):
    EXT_MODULES.append(
        Extension(
            "cityhashcrc",
            ["src/city.cc", "src/cityhashcrc" + SRC_EXT],
            depends=[
                "src/city.h",
                "src/citycrc.h",
            ],
            language="c++",
            extra_compile_args=CXXFLAGS,
            include_dirs=["src"],
        )
    )


VERSION = "0.3.6"
URL = "https://github.com/escherba/python-cityhash"


def get_long_description(relpath, encoding="utf-8"):
    _long_desc = """

    """
    fname = join(dirname(__file__), relpath)
    try:
        with open(fname, "rb") as fh:
            return fh.read().decode(encoding)
    except Exception:
        return _long_desc


setup(
    version=VERSION,
    description="Python bindings for CityHash and FarmHash",
    author="Eugene Scherba",
    author_email="escherba+cityhash@gmail.com",
    url=URL,
    download_url=URL + "/tarball/master/" + VERSION,
    name="cityhash",
    license="MIT",
    zip_safe=False,
    cmdclass=CMDCLASS,
    ext_modules=EXT_MODULES,
    package_dir={"": "src"},
    keywords=[
        "google",
        "hash",
        "hashing",
        "cityhash",
        "farmhash",
        "murmurhash",
        "cython",
    ],
    classifiers=[
        "Development Status :: 5 - Production/Stable",
        "Intended Audience :: Developers",
        "Intended Audience :: Science/Research",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
        "Programming Language :: C++",
        "Programming Language :: Cython",
        "Programming Language :: Python :: 3.6",
        "Programming Language :: Python :: 3.7",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Topic :: Scientific/Engineering :: Information Analysis",
        "Topic :: Software Development :: Libraries",
        "Topic :: System :: Distributed Computing",
    ],
    long_description=get_long_description("README.md"),
    long_description_content_type="text/markdown",
    tests_require=["pytest"],
    distclass=BinaryDistribution,
)
