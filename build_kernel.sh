#!/bin/bash
set -e
SDK_DIR=$(dirname "$(realpath "$0")")
TOOLCHAIN_SUBDIR="toolchain/gcc-arm-11.2-2022.02-x86_64-aarch64-none-linux-gnu/bin"
TOOLCHAIN="$SDK_DIR/$TOOLCHAIN_SUBDIR/aarch64-none-linux-gnu-"

CUST=${1:-generic}
ACTION=${2:-build}; 

KERNEL_DIR="$SDK_DIR/linux-orangepi"
OUTPUT_DIR="$SDK_DIR/output"
#DEFCONFIG="linux-rockchip-rk3588-${CUST}_defconfig"

cd "$KERNEL_DIR"

if [[ $ACTION == build ]]; then
    mkdir -p "$OUTPUT_DIR"
    mkdir -p boot/extlinux

    cp -f "$SDK_DIR/customer/$CUST/kernel/config/$KERNEL_CFG" \
        "$KERNEL_DIR/arch/arm64/configs/$KERNEL_CFG"  
    cp -f "$SDK_DIR/customer/$CUST/kernel/dts/$KERNEL_DTS"* \
        "$KERNEL_DIR/arch/arm64/boot/dts/rockchip"

    make ARCH=arm64 CROSS_COMPILE="$TOOLCHAIN" $KERNEL_CFG
    make ARCH=arm64 CROSS_COMPILE="$TOOLCHAIN" -j$(nproc) Image
    IMAGE_SIZE=$("$SDK_DIR/customer/$CUST/scripts/script_kernel.sh" $ACTION | sed -n 's/^IMAGE_SIZE://p')
    make ARCH=arm64 CROSS_COMPILE="$TOOLCHAIN" -j$(nproc) dtbs

    cp -f "arch/arm64/boot/dts/rockchip/$KERNEL_DTS.dtb" boot/rk3588.dtb
    cp -f arch/arm64/boot/Image boot/
    cp -f "$SDK_DIR/customer/$CUST/kernel/extlinux.conf" boot/extlinux
    genext2fs -b $IMAGE_SIZE -B $((1024)) -d boot/ -i 8192 -U "kernel_${CUST}.img"
    cp -f "kernel_${CUST}.img" "$OUTPUT_DIR"
elif [[ $ACTION == clean ]]; then
    rm -rf boot
    rm -f "$OUTPUT_DIR/kernel_${CUST}.img"
    make ARCH=arm64 CROSS_COMPILE="$TOOLCHAIN" clean
    rm -f "$KERNEL_DIR/arch/arm64/configs/$KERNEL_CFG"
    rm -f "$KERNEL_DIR/arch/arm64/boot/dts/rockchip/$KERNEL_DTS"*
    "$SDK_DIR/customer/$CUST/scripts/script_kernel.sh" $ACTION
elif [[ $ACTION == distclean ]]; then
    rm -rf boot
    rm -f "$OUTPUT_DIR/kernel_${CUST}.img"
    make ARCH=arm64 CROSS_COMPILE="$TOOLCHAIN" distclean
    rm -f "$KERNEL_DIR/arch/arm64/configs/$KERNEL_CFG"
    rm -f "$KERNEL_DIR/arch/arm64/boot/dts/rockchip/$KERNEL_DTS"*
    "$SDK_DIR/customer/$CUST/scripts/script_kernel.sh" $ACTION
else
      echo "kernel nothing to do!"
fi