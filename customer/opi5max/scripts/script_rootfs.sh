#!/bin/bash
set -e
SCRIPT_DIR=$(dirname "$(realpath "$0")")
SOURCE_DIR=$(dirname "$(pwd)")

CUST=${1:-generic}

# 添加需要打包到rootfs里面的文件
