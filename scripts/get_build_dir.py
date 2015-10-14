import sys
from sysconfig import get_platform


def run():
    """
    code here mostly borrowed from Python-2.7.3/Lib/site.py
    """
    s = "build/temp.%s-%.3s" % (get_platform(), sys.version)
    if hasattr(sys, 'gettotalrefcount'):
        s += '-pydebug'
    print s


if __name__ == "__main__":
    run()
