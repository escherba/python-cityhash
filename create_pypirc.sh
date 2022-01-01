#!/bin/bash

cat <<- EOF > ~/.pypirc
[distutils]
index-servers =
    pypi

[pypi]
repository: https://upload.pypi.org/legacy/
username: $PYPI_USERNAME
password: $PYPI_PASSWORD
EOF
