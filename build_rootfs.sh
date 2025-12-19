#!/bin/bash
set -e
SDK_DIR=$(dirname "$(realpath "$0")")
TOOLCHAIN_SUBDIR="toolchain/gcc-arm-11.2-2022.02-x86_64-aarch64-none-linux-gnu"
TOOLCHAIN_PATH="$SDK_DIR/$TOOLCHAIN_SUBDIR"

CUST=${1:-generic}
ACTION=${2:-build}; 

ROOTFS_DIR="$SDK_DIR/buildroot"
OUTPUT_DIR="$SDK_DIR/output"
#DEFCONFIG="rk3588_${CUST}_defconfig"

cd "$ROOTFS_DIR"
mkdir -p "$OUTPUT_DIR"

if [[ $ACTION == build ]]; then
     cp -f "$SDK_DIR/customer/$CUST/buildroot/config/$BUILDROOT_CONFIG_FILE" \
          "$ROOTFS_DIR/configs/$BUILDROOT_CONFIG_FILE"
     cp -rf "$SDK_DIR/customer/$CUST/device/parameter.txt" "$OUTPUT_DIR"

     make BR2_TOOLCHAIN_EXTERNAL_PATH="$TOOLCHAIN_PATH" \
          BR2_TOOLCHAIN_EXTERNAL_PREFIX="aarch64-none-linux-gnu" \
          "$BUILDROOT_CONFIG_FILE"
     make BR2_TOOLCHAIN_EXTERNAL_PATH="$TOOLCHAIN_PATH" \
          BR2_TOOLCHAIN_EXTERNAL_PREFIX="aarch64-none-linux-gnu" \
          -j$(nproc) 
          
     # 拷贝需要打包到rootfs里面的文件
     "$SDK_DIR/customer/$CUST/scripts/script_rootfs.sh" $CUST

     make BR2_TOOLCHAIN_EXTERNAL_PATH="$TOOLCHAIN_PATH" \
          BR2_TOOLCHAIN_EXTERNAL_PREFIX="aarch64-none-linux-gnu" \
          -j$(nproc) rootfs-ext2

     install -D -m 644 output/images/rootfs.ext4 "$OUTPUT_DIR/rootfs.ext4"

elif [[ $ACTION == pack ]]; then
     # 拷贝需要打包到rootfs里面的文件
     "$SDK_DIR/customer/$CUST/scripts/script_rootfs.sh" $CUST
     cp -rf "$SDK_DIR/customer/$CUST/device/parameter.txt" "$OUTPUT_DIR"
     make BR2_TOOLCHAIN_EXTERNAL_PATH="$TOOLCHAIN_PATH" \
          BR2_TOOLCHAIN_EXTERNAL_PREFIX="aarch64-none-linux-gnu" \
          -j$(nproc) rootfs-ext2

     install -D -m 644 output/images/rootfs.ext4 "$OUTPUT_DIR/rootfs.ext4"
elif [[ $ACTION == clean ]]; then
     make BR2_TOOLCHAIN_EXTERNAL_PATH="$TOOLCHAIN_PATH" \
          BR2_TOOLCHAIN_EXTERNAL_PREFIX="aarch64-none-linux-gnu" \
          clean
     rm -f "$OUTPUT_DIR/rootfs.ext4"
     rm -f "$OUTPUT_DIR/parameter.txt"
     rm -f "$ROOTFS_DIR/configs/$BUILDROOT_CONFIG_FILE"
elif [[ $ACTION == distclean ]]; then
     make BR2_TOOLCHAIN_EXTERNAL_PATH="$TOOLCHAIN_PATH" \
          BR2_TOOLCHAIN_EXTERNAL_PREFIX="aarch64-none-linux-gnu" \
          distclean
     rm -f "$OUTPUT_DIR/rootfs.ext4"
     rm -f "$OUTPUT_DIR/parameter.txt"
     rm -f "$ROOTFS_DIR/configs/$BUILDROOT_CONFIG_FILE"
else
     echo "rootfs nothing to do!"
fi