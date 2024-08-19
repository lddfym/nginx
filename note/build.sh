#!/bin/bash

BASE_DIR=$(cd $(dirname $0) && pwd)
WORK_DIR=${BASE_DIR}/..

OUTPUT_DIR=${WORK_DIR}/output

cd ${WORK_DIR} && ./auto/configure --prefix=${OUTPUT_DIR} && make -j 8 && make install
