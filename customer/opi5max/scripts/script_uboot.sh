#!/bin/bash
set -e

SCRIPT_DIR=$(dirname "$(realpath "$0")")
CUST_DIR=$(dirname "$SCRIPT_DIR")
SOURCE_DIR=$(dirname "$(pwd)")

ACTION=${1:-generic}

if [[ $ACTION == build ]]; then
    cp -f "$CUST_DIR/uboot/config/${UBOOT_CONFIG}_defconfig" "$SOURCE_DIR/u-boot-orangepi/configs"
    cp -f "$CUST_DIR/uboot/dts/${UBOOT_DTS}.dts" "$SOURCE_DIR/u-boot-orangepi/arch/arm/dts"
elif [[ $ACTION == "clean" || $ACTION == "distclean" ]]; then
    rm -f "$SOURCE_DIR/u-boot-orangepi/configs/${UBOOT_CONFIG}_defconfig"
    rm -f "$SOURCE_DIR/u-boot-orangepi/arch/arm/dts/${UBOOT_DTS}.dts"
else
     echo "nothing to do!"
fi