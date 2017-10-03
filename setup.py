__author__  = "Alexander [Amper] Marshalov"
__email__   = "alone.amper+cityhash@gmail.com"
__icq__     = "87-555-3"
__jabber__  = "alone.amper@gmail.com"
__twitter__ = "amper"
__url__     = "http://amper.github.com/cityhash"

from setuptools import setup
from setuptools.extension import Extension
from setuptools.dist import Distribution

try:
    from Cython.Distutils import build_ext
except ImportError:
    USE_CYTHON = False
else:
    USE_CYTHON = True


class BinaryDistribution(Distribution):
    """
    Subclass the setuptools Distribution to flip the purity flag to false.
    See http://lucumr.pocoo.org/2014/1/27/python-on-wheels/
    """
    def is_pure(self):
        # TODO: check if this is still necessary with Python v2.7
        return False


CXXFLAGS = """
-O3
-msse4.2
-Wno-unused-value
-Wno-unused-function
""".split()

INCLUDE_DIRS = ['include']

CMDCLASS = {}
EXT_MODULES = []

if USE_CYTHON:
    EXT_MODULES.append(
        Extension("clickhouse_cityhash.cityhash", ["src/city.cc", "src/cityhash.pyx"],
                  language="c++",
                  extra_compile_args=CXXFLAGS,
                  include_dirs=INCLUDE_DIRS)
    )
    CMDCLASS['build_ext'] = build_ext
else:
    EXT_MODULES.append(
        Extension("clickhouse_cityhash.cityhash", ["src/city.cc", "src/cityhash.cpp"],
                  language="c++",
                  extra_compile_args=CXXFLAGS,
                  include_dirs=INCLUDE_DIRS)
    )


VERSION = '1.0.2.1'
URL = "https://github.com/xzkostyan/python-cityhash"

with open('README.rst', 'rb') as fd:
    LONG_DESCRIPTION = fd.read().decode('utf-8')


setup(
    version=VERSION,
    description="Python-bindings for CityHash, a fast non-cryptographic hash algorithm",
    author="Alexander [Amper] Marshalov",
    author_email="alone.amper+cityhash@gmail.com",
    url=URL,
    download_url=URL + "/tarball/master/" + VERSION,
    name='clickhouse-cityhash',
    license='MIT',
    cmdclass=CMDCLASS,
    ext_modules=EXT_MODULES,
    keywords=['hash', 'hashing', 'cityhash'],
    packages=['clickhouse_cityhash'],
    classifiers=[
        'Development Status :: 4 - Beta',
        'Operating System :: OS Independent',
        'Intended Audience :: Developers',
        'Intended Audience :: Science/Research',
        'License :: OSI Approved :: MIT License',
        'Programming Language :: C++',
        'Programming Language :: Cython',
        'Programming Language :: Python :: 2.7',
        'Programming Language :: Python :: 3.6',
        'Topic :: Internet',
        'Topic :: Scientific/Engineering',
        'Topic :: Scientific/Engineering :: Information Analysis',
        'Topic :: Software Development',
        'Topic :: Software Development :: Libraries :: Python Modules',
        'Topic :: Utilities'
    ],
    long_description=LONG_DESCRIPTION,
    distclass=BinaryDistribution,
)
