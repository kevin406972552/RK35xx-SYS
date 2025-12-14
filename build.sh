#!/bin/bash
set -e

# 显示帮助信息
show_help() {
cat << EOF
用法: $0 [项目] [操作]

参数:
  项目   指定要编译的项目名称，如 opi5max
  操作   指定要执行的操作（默认为 build）

可用操作:
  build       一键构建（包括编译和打包）
  clean       清除编译结果
  distclean   深度清除（清除所有生成文件）
  pack        仅打包，用于向rootfs添加应用后直接打包
  help        显示此帮助信息

示例:
  $0 opi5max           # 一键构建 opi5max 项目
  $0 opi5max build     # 同上，显式指定 build 操作
  $0 opi5max clean     # 清除 opi5max 项目的编译结果
  $0 opi5max distclean # 深度清除 opi5max 项目
  $0 opi5max pack      # 仅打包 opi5max 项目
  $0 help              # 显示帮助信息

注意: 所有命令都以指定项目为例，请根据实际编译项目填写
EOF
}

load_config() {
   #-------------------- 加载板级配置 --------------------#
    BOARD_CONFIG_FILE="customer/$CUST/device/$selected_board"
    [[ -f "$BOARD_CONFIG_FILE" ]] || { echo "❌ 板子配置文件不存在：$BOARD_CONFIG_FILE"; exit 1; }
    echo "📦 加载板子配置：$BOARD_CONFIG_FILE"

    # 先记录现场已有变量
    before=$(compgen -v | sort)

    source "$BOARD_CONFIG_FILE"

    # 当前 shell 里导出新增变量
    for var in $(comm -13 <(echo "$before") <(compgen -v | sort)); do
        export "$var"
    done
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

# === 新增逻辑：自动选择板子 ===
BOARD_CACHE=".selected_board_${CUST}"

# 如果是 clean 或 distclean，而且不存在缓冲文件
if [[ $ACTION == "clean" || $ACTION == "distclean" ]];  then

    if [ ! -f $BOARD_CACHE ]; then
        echo "🧹 未编译任何板子，无需清理"
        exit 0
    else
        # 如果是 clean 或 distclean，删除缓存
        if [[ "$ACTION" == "clean" || "$ACTION" == "distclean" ]]; then
            selected_board=$(cat "$BOARD_CACHE")
            load_config
            rm -f "$BOARD_CACHE"
        fi
    fi
else
    # 如果缓存不存在，扫描 device 目录并让用户选择
    if [[ ! -f "$BOARD_CACHE" ]]; then
        DEVICE_DIR="customer/$CUST/device"
        if [[ ! -d "$DEVICE_DIR" ]]; then
            echo "❌ 未找到 device 目录，无法选择板子配置"
            exit 1
        fi

        # 查找所有 defconfig 文件
        mapfile -t boards < <(find "$DEVICE_DIR" -name "*_defconfig" -exec basename {} \; | sort)

        if [[ ${#boards[@]} -eq 0 ]]; then
            echo "❌ 未找到任何板子配置文件（*_defconfig）"
            exit 1
        fi

        echo "📋 请选择要编译的板子配置："
        for i in "${!boards[@]}"; do
            echo "$((i+1)). ${boards[i]}"
        done

        read -p "请输入编号（1-${#boards[@]}）：" choice
        if ! [[ "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > ${#boards[@]} )); then
            echo "❌ 无效选择"
            exit 1
        fi

        selected_board="${boards[$((choice-1))]}"
        echo "$selected_board" > "$BOARD_CACHE"
        echo "✅ 已选择板子配置：$selected_board"
    else
        selected_board=$(cat "$BOARD_CACHE")
        echo "📌 使用上次选择的板子配置：$selected_board"
    fi

    load_config
fi

# 执行子脚本
./build_uboot.sh   "$CUST" "$ACTION"
./build_kernel.sh  "$CUST" "$ACTION"
./build_rootfs.sh  "$CUST" "$ACTION"

echo "===== All $ACTION finished ====="