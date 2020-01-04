#!/bin/bash
set -e -x

# Install a system package required by our library
yum install -y atlas-devel
PYBIN=/opt/python/$1/bin
PLAT=$2
# Compile wheels
"${PYBIN}/pip" install -r /io/dev-requirements.txt
"${PYBIN}/python" setup.py test
"${PYBIN}/pip" wheel /io/ -w wheelhouse/

# Bundle external shared libraries into the wheels
for whl in wheelhouse/*.whl; do
    auditwheel repair "$whl" --plat $PLAT -w /io/wheelhouse/
done

## Install packages and test
#for PYBIN in ${PYS}; do
#    "${PYBIN}/pip" install quicksectx --no-index -f /io/wheelhouse
#    (cd "$HOME"; "${PYBIN}/nosetests" quicksectx)
#done