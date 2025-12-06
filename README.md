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
1. 在WSL中如果报：
        Your PATH contains spaces, TABs, and/or newline (\n) characters.
        This doesn't work. Fix you PATH.  
        请执行  export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/binj'h'f'd'h'g's'd'd'j'hdjcdcjcvnükjr'l'b'g'f'j'k
2. 在WSL中如果报：
        configure: error: you should not run configure as root (set FORCE_UNSAFE_CONFIGURE=1 in environment to bypass this check)  
        请执行 export FORCE_UNSAFE_CONFIGURE=1