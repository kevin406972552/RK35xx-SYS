#!/bin/bash
set -e
SCRIPT_DIR=$(dirname "$(realpath "$0")")
CUST_DIR=$(dirname "$SCRIPT_DIR")
SOURCE_DIR=$(dirname "$(pwd)")
TOOLCHAIN_SUBDIR="toolchain/gcc-arm-11.2-2022.02-x86_64-aarch64-none-linux-gnu/bin"
TOOLCHAIN="$SOURCE_DIR/$TOOLCHAIN_SUBDIR/aarch64-none-linux-gnu-"

ACTION=${1:-generic}

IMAGE_SIZE=51200
echo "IMAGE_SIZE:$IMAGE_SIZE"

move_bk() { [ -e "$1" ] && mv -f "$1" "$2" || true; }

if [[ $ACTION == build ]]; then
    [ ! -e "$SOURCE_DIR/linux-orangepi/arch/arm64/boot/dts/rockchip/Makefile_bk" ] && \
    move_bk "$SOURCE_DIR/linux-orangepi/arch/arm64/boot/dts/rockchip/Makefile" \
            "$SOURCE_DIR/linux-orangepi/arch/arm64/boot/dts/rockchip/Makefile_bk"

    cp -f "$CUST_DIR/kernel/dts/Makefile" "$SOURCE_DIR/linux-orangepi/arch/arm64/boot/dts/rockchip"

    make ARCH=arm64 CROSS_COMPILE="$TOOLCHAIN" -j$(nproc) modules >&2
    make ARCH=arm64 CROSS_COMPILE="$TOOLCHAIN" INSTALL_MOD_PATH="$SOURCE_DIR/buildroot/output/target"  modules modules_install

elif [[ $ACTION == clean ]]; then
    move_bk "$SOURCE_DIR/linux-orangepi/arch/arm64/boot/dts/rockchip/Makefile_bk" "$SOURCE_DIR/linux-orangepi/arch/arm64/boot/dts/rockchip/Makefile"
elif [[ $ACTION == distclean ]]; then
    move_bk "$SOURCE_DIR/linux-orangepi/arch/arm64/boot/dts/rockchip/Makefile_bk" "$SOURCE_DIR/linux-orangepi/arch/arm64/boot/dts/rockchip/Makefile"
else
      echo "nothing to do!"
fi
