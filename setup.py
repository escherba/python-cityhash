from os.path import join, dirname
from setuptools import setup
from setuptools.extension import Extension
from setuptools.dist import Distribution

try:
    from cpuinfo import get_cpu_info
    cpu_info = get_cpu_info()
    have_sse42 = 'sse4.2' in cpu_info['flags']
except Exception:
    have_sse42 = False

try:
    from Cython.Distutils import build_ext
except ImportError:
    build_ext = None

USE_CYTHON = build_ext is not None


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

if have_sse42:
    CXXFLAGS.append('-msse4.2')


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

if USE_CYTHON:
    EXT_MODULES.append(
        Extension(
            "cityhash",
            CXXSOURCES + ["src/cityhash.pyx"],
            depends=CXXHEADERS,
            language="c++",
            extra_compile_args=CXXFLAGS,
            include_dirs=INCLUDE_DIRS)
        )
    CMDCLASS['build_ext'] = build_ext
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


VERSION = '0.2.4.post8'
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
    author="Eugene Scherba, Alexander [Amper] Marshalov",
    author_email="escherba+cityhash@gmail.com",
    url=URL,
    download_url=URL + "/tarball/master/" + VERSION,
    name='cityhash',
    license='MIT',
    zip_safe=False,
    cmdclass=CMDCLASS,
    ext_modules=EXT_MODULES,
    keywords=['hash', 'hashing', 'cityhash'],
    classifiers=[
        'Development Status :: 4 - Beta',
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
        'Topic :: Internet',
        'Topic :: Scientific/Engineering',
        'Topic :: Scientific/Engineering :: Information Analysis',
        'Topic :: Software Development',
        'Topic :: Software Development :: Libraries :: Python Modules',
        'Topic :: Utilities'
    ],
    long_description=get_long_description(),
    tests_require=['pytest'],
    distclass=BinaryDistribution,
)
