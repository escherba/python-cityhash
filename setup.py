#!/usr/bin/env python

"""
Copyright (c) 2011 Alexander [Amper] Marshalov <alone.amper@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
"""

__author__  = "Alexander [Amper] Marshalov"
__email__   = "alone.amper+cityhash@gmail.com"
__icq__     = "87-555-3"
__jabber__  = "alone.amper@gmail.com"
__twitter__ = "amper"
__url__     = "http://amper.github.com/cityhash"

from setuptools import setup
from distutils.command.build_ext import build_ext
from distutils.extension import Extension


class build_ext_subclass(build_ext):
    """
    This fixes a problem with building packages when environmental variable
    CXX consists of compiler name + arguments with spaces in the middle.
    build_ext instead expects an array where each element is a CLI token, and
    so normally compilation would fail with error "unable to execute
    `cxx[0]`: No such file or directory. This subclass of build_ext extracts
    the compiler name and places remaining arguments back into the array
    """
    def build_extensions(self):
        ccm = self.compiler.compiler
        if ' ' in ccm:
            self.compiler.compiler = ccm[0].split(' ') + ccm[1:]
        cxx = self.compiler.compiler_cxx
        if ' ' in cxx[0]:
            self.compiler.compiler_cxx = cxx[0].split(' ') + cxx[1:]
        build_ext.build_extensions(self)


setup(
    version="0.0.3",
    description="Python-bindings for CityHash",
    author="Alexander [Amper] Marshalov",
    author_email="alone.amper+cityhash@gmail.com",
    url="https://github.com/Amper/cityhash",
    name='cityhash',
    license='MIT',
    cmdclass={'build_ext': build_ext_subclass},
    ext_modules=[Extension("cityhash", ["city.cc", "cityhash.cpp"])]
)
