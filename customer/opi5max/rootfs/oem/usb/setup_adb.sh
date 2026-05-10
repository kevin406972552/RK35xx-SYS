#!/bin/sh

# 挂载 configfs
mount -t configfs none /sys/kernel/config 2>/dev/null

# 清理旧配置
if [ -d /sys/kernel/config/usb_gadget/g1 ]; then
    cd /sys/kernel/config/usb_gadget/g1
    
    # 1. 先解绑 UDC
    echo "" > UDC 2>/dev/null
    sleep 1
    
    # 2. 删除符号链接
    rm -f configs/c.1/ffs.adb 2>/dev/null
    
    # 3. 删除目录（从最内层开始）
    rmdir configs/c.1/strings/0x409 2>/dev/null
    rmdir configs/c.1 2>/dev/null
    rmdir functions/ffs.adb 2>/dev/null
    rmdir strings/0x409 2>/dev/null
    
    # 4. 最后删除主目录
    cd ..
    rmdir g1 2>/dev/null

fi

# 创建配置
cd /sys/kernel/config/usb_gadget
mkdir g1
cd g1

echo "0x18d1" > idVendor
echo "0x4e42" > idProduct
mkdir strings/0x409
echo "20240510" > strings/0x409/serialnumber
echo "Rockchip" > strings/0x409/manufacturer
echo "ADB Device" > strings/0x409/product

mkdir configs/c.1
mkdir configs/c.1/strings/0x409
echo "adb" > configs/c.1/strings/0x409/configuration
echo 500 > configs/c.1/MaxPower

mkdir functions/ffs.adb
ln -s functions/ffs.adb configs/c.1

mkdir -p /dev/usb-ffs/adb
mount -t functionfs adb /dev/usb-ffs/adb

killall adbd 2>/dev/null
adbd &

sleep 1
UDC=$(ls /sys/class/udc/ | head -1)
echo $UDC > UDC

echo "ADB setup complete on UDC: $UDC"
cat /sys/class/udc/$UDC/state
