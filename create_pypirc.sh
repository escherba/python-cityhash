#!/bin/bash

cat <<- EOF > ~/.pypirc
[distutils]
index-servers =
    pypi

[pypi]
repository: https://pypi.python.org/pypi
username: $PYPI_USERNAME
password: $PYPI_PASSWORD
EOF
