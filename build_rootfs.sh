#!/bin/bash
set -e
SDK_DIR=$(dirname "$(realpath "$0")")
TOOLCHAIN_SUBDIR="toolchain/gcc-arm-11.2-2022.02-x86_64-aarch64-none-linux-gnu"
TOOLCHAIN_PATH="$SDK_DIR/$TOOLCHAIN_SUBDIR"

CUST=${1:-generic}
ACTION=${2:-build}; 

ROOTFS_DIR="$SDK_DIR/buildroot"
OUTPUT_DIR="$SDK_DIR/output"
DEFCONFIG="rk3588_${CUST}_defconfig"

cd "$ROOTFS_DIR"

if [[ $ACTION == build ]]; then
     cp -f "$SDK_DIR/customer/$CUST/buildroot/config/$DEFCONFIG" \
          "$ROOTFS_DIR/configs/$DEFCONFIG"
     mkdir -p "$OUTPUT_DIR"
     make BR2_TOOLCHAIN_EXTERNAL_PATH="$TOOLCHAIN_PATH" \
          BR2_TOOLCHAIN_EXTERNAL_PREFIX="aarch64-none-linux-gnu" \
          "$DEFCONFIG"
     make BR2_TOOLCHAIN_EXTERNAL_PATH="$TOOLCHAIN_PATH" \
          BR2_TOOLCHAIN_EXTERNAL_PREFIX="aarch64-none-linux-gnu" \
          -j$(nproc) 
          
     # 拷贝需要打包到rootfs里面的文件
     # "$SDK_DIR/customer/$CUST/scripts/script_rootfs.sh" $CUST

     # make BR2_TOOLCHAIN_EXTERNAL_PATH="$TOOLCHAIN_PATH" \
     #      BR2_TOOLCHAIN_EXTERNAL_PREFIX="aarch64-none-linux-gnu" \
     #      -j$(nproc) rootfs-ext4

     install -D -m 644 output/images/rootfs.ext4 "$OUTPUT_DIR/rootfs.ext4"

elif [[ $ACTION == pack ]]; then
     # 拷贝需要打包到rootfs里面的文件
     # "$SDK_DIR/customer/$CUST/scripts/script_rootfs.sh" $CUST
     make BR2_TOOLCHAIN_EXTERNAL_PATH="$TOOLCHAIN_PATH" \
          BR2_TOOLCHAIN_EXTERNAL_PREFIX="aarch64-none-linux-gnu" \
          -j$(nproc) rootfs-ext4
elif [[ $ACTION == clean ]]; then
     make BR2_TOOLCHAIN_EXTERNAL_PATH="$TOOLCHAIN_PATH" \
          BR2_TOOLCHAIN_EXTERNAL_PREFIX="aarch64-none-linux-gnu" \
          clean
     rm -f "$OUTPUT_DIR/rootfs.ext4"
     rm -f "$ROOTFS_DIR/configs/$DEFCONFIG"
elif [[ $ACTION == distclean ]]; then
     make BR2_TOOLCHAIN_EXTERNAL_PATH="$TOOLCHAIN_PATH" \
          BR2_TOOLCHAIN_EXTERNAL_PREFIX="aarch64-none-linux-gnu" \
          distclean
     rm -f "$OUTPUT_DIR/rootfs.ext4"
     rm -f "$ROOTFS_DIR/configs/$DEFCONFIG"
else
     echo "rootfs nothing to do!"
fi