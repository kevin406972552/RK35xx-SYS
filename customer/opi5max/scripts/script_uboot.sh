#!/bin/bash
set -e

SCRIPT_DIR=$(dirname "$(realpath "$0")")
CUST_DIR=$(dirname "$SCRIPT_DIR")
SOURCE_DIR=$(dirname "$(pwd)")

ACTION=${1:-generic}

if [[ $ACTION == build ]]; then
    cp -f "$CUST_DIR/uboot/config/opi5max_defconfig" "$SOURCE_DIR/u-boot-orangepi/configs"
    cp -f "$CUST_DIR/uboot/dts/rk3588-opi5max.dts" "$SOURCE_DIR/u-boot-orangepi/arch/arm/dts"
elif [[ $ACTION == "clean" || $ACTION == "distclean" ]]; then
    rm -f "$SOURCE_DIR/u-boot-orangepi/configs/opi5max_defconfig"
    rm -f "$SOURCE_DIR/u-boot-orangepi/arch/arm/dts/rk3588-opi5max.dts"
else
     echo "nothing to do!"
fi