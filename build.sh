#!/bin/bash
set -e

# 显示帮助信息
show_help() {
    cat << EOF
用法: $0 [项目] [操作]

参数:
  项目   指定要编译的项目名称，如 OPi5Max
  操作   指定要执行的操作（默认为 build）

可用操作:
  build       一键构建（包括编译和打包）
  clean       清除编译结果
  distclean   深度清除（清除所有生成文件）
  pack        仅打包，用于向rootfs添加应用后直接打包
  help        显示此帮助信息

示例:
  $0 OPi5Max           # 一键构建 OPi5Max 项目
  $0 OPi5Max build     # 同上，显式指定 build 操作
  $0 OPi5Max clean     # 清除 OPi5Max 项目的编译结果
  $0 OPi5Max distclean # 深度清除 OPi5Max 项目
  $0 OPi5Max pack      # 仅打包 OPi5Max 项目
  $0 help              # 显示帮助信息

注意: 所有命令都以指定项目为例，请根据实际编译项目填写
EOF
}

# 检查是否需要显示帮助
if [[ "$1" == "help" || "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

# 如果没有提供任何参数，也显示帮助
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

CUST=${1:-generic}
ACTION=${2:-build}

./build_uboot.sh   "$CUST" "$ACTION"
./build_kernel.sh  "$CUST" "$ACTION"
./build_rootfs.sh  "$CUST" "$ACTION"

echo "===== All $ACTION finished ====="