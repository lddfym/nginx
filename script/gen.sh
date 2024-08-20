#!/bin/bash

# 配置文件(便于调试) nginx.conf
# daemon off;  前台启动
# master_process off;

BASE_DIR=$(cd $(dirname $0) && pwd)
WORK_DIR=${BASE_DIR}/..

OBJS_DIR=${WORK_DIR}/objs
OUTPUT_DIR=${WORK_DIR}/output

delete() {
    for name in "$@"; do
        if [[ -d "$name" ]]; then
            rm -rf "$name" || { echo "[ERROR] Failed to delete directory $name." && exit 1; }
        elif [[ -f "$name" ]]; then
            rm -f "$name" || { echo "[ERROR] Failed to delete file $name." && exit 1; }
        else
            echo "[WARNNING] Director or File $name does not exist."
        fi
    done
}

delete_build() {
    delete ${OBJS_DIR} ${WORK_DIR}/Makefile
}

delete_install() {
    delete ${OUTPUT_DIR}
}

configure() {
    delete_build
    delete_install

    # --without-http_rewrite_module 避免依赖 pcre 库
    cd ${WORK_DIR} &&
        ./auto/configure --prefix=${OUTPUT_DIR} \
            --without-http_rewrite_module \
            --with-debug \
            --with-cc-opt="-O0 -g" && echo "[INFO] Configure successful" || {
        echo "[ERROR] Configure failed"
        exit 1
    }
}

build() {
    delete_install

    cd ${WORK_DIR} &&
        make -j 8 && echo "[INFO] Build successful" || { echo "[ERROR] Build failed" && exit 1; }

}

install() {
    delete_install

    cd ${WORK_DIR} &&
        make install && echo "[INFO] Install successful" || { echo "[ERROR] Install failed" && exit 1; }
}

case "$1" in
all)
    configure
    build
    install
    ;;
build_install)
    build
    install
    ;;
configure)
    configure
    ;;
build)
    build
    ;;
install)
    install
    ;;
help)
    echo "Usage: $0 {all|build_install|configure|build|install|help}"
    ;;
*)
    echo "Invalid argument: $1"
    echo "Usage: $0 {all|build_install|configure|build|install|help}"
    exit 1
    ;;
esac
