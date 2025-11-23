#!/bin/bash
set -e
SDK_DIR=$(dirname "$(realpath "$0")")
TOOLCHAIN_SUBDIR="toolchain/gcc-arm-11.2-2022.02-x86_64-aarch64-none-linux-gnu/bin"
TOOLCHAIN="$SDK_DIR/$TOOLCHAIN_SUBDIR/aarch64-none-linux-gnu-"

CUST=${1:-generic}
ACTION=${2:-build}; 

UBOOT_DIR="$SDK_DIR/u-boot-orangepi"
OUTPUT_DIR="$SDK_DIR/output"

cd "$UBOOT_DIR"
if [[ $ACTION == build ]]; then
    mkdir -p "$OUTPUT_DIR"
    "$SDK_DIR/customer/$CUST/scripts/script_uboot.sh" $ACTION
    ./make.sh CROSS_COMPILE="$TOOLCHAIN" $CUST
    install -D -m 644 uboot.img "$OUTPUT_DIR/uboot.img"
    install -D -m 644 rk3588_spl_loader_v1.18.113.bin "$OUTPUT_DIR/rk3588_spl_loader_v1.18.113.bin"
elif [[ $ACTION == clean ]]; then
    make clean
    rm -f "$OUTPUT_DIR/uboot.img"
    rm -f "$OUTPUT_DIR/rk3588_spl_loader_v1.18.113.bin"
    "$SDK_DIR/customer/$CUST/scripts/script_uboot.sh" $ACTION
elif [[ $ACTION == distclean ]]; then
    make distclean
    rm -f "$OUTPUT_DIR/uboot.img"
    rm -f "$OUTPUT_DIR/rk3588_spl_loader_v1.18.113.bin"
    "$SDK_DIR/customer/$CUST/scripts/script_uboot.sh" $ACTION
else
     echo "uboot nothing to do!"
fi