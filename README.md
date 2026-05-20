# RK3588 系统代码

## 构建命令
以下命令都以opi5max项目为例，具体根据编译项目填写
1. build.sh 总构建脚本
    - ./build.sh opi5max 一键构建（此命令包括打包）
    - ./build.sh opi5max clean 清除
    - ./build.sh opi5max distclean 深度清除
    - ./build.sh opi5max pack 仅打包，用于向rootfs添加应用后直接打包
2. build_uboot.sh 单独构建uboot
    - ./build_uboot.sh opi5max 一键构建
    - ./build_uboot.sh opi5max clean 清除
    - ./build_uboot.sh opi5max distclean 深度清除
3. build_kernel.sh 单独构建kernel
    - ./build_kernel.sh opi5max 一键构建
    - ./build_kernel.sh opi5max clean 清除
    - ./build_kernel.sh opi5max distclean 深度清除   
4. build_rootfs.sh 单独构建rootfs（包括相关工具，应用，库等）
    - ./build_rootfs.sh opi5max 一键构建
    - ./build_rootfs.sh opi5max clean 清除
    - ./build_rootfs.sh opi5max distclean 深度清除
    - ./build_rootfs.sh opi5max pack 仅打包，用于向rootfs添加应用后直接打包
  
# 注意事项
1. 克隆子模块代码：
   git submodule update --init --recursive

2. 安装依赖：
   apt update && apt install -y make gcc g++ build-essential device-tree-compiler python2 python2-dev flex bison libssl-dev genext2fs unzip libncurses5-dev libncursesw5-dev
3. 解决因为wsl引入了windows的环境变量后导致运行程序，编译代码报错问题  
   在 WSL 中编辑（或创建）/etc/wsl.conf  
   添加以下内容：  
   [interop]  
   appendWindowsPath = false