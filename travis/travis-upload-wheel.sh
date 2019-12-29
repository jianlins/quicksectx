#!/bin/bash
#
set -ex

export CLOUD_CONTAINER_NAME=travis-dev-wheels

if [[ ( ${USE_WHEEL} == 1 ) \
      && ( "${TRAVIS_BRANCH}" == "master" ) \
      && ( "${TRAVIS_PULL_REQUEST}" == "false" ) ]]; then
  /opt/python/${PY36}/bin/pip install wheelhouse_uploader
  /opt/python/${PY36}/bin/python -m wheelhouse_uploader upload --local-folder \
    ${TRAVIS_BUILD_DIR}/wheelhouse/ ${CLOUD_CONTAINER_NAME}
fi
