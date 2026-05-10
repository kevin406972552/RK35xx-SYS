#!/bin/sh

echo "Disconnecting ADB..."

# 解绑 UDC
if [ -d /sys/kernel/config/usb_gadget/g1 ]; then
    echo "" > /sys/kernel/config/usb_gadget/g1/UDC 2>/dev/null
    echo "UDC unbound"
fi

# 停止 adbd
killall adbd 2>/dev/null
echo "adbd stopped"

# 卸载 FunctionFS
umount /dev/usb-ffs/adb 2>/dev/null
echo "FunctionFS unmounted"

echo "ADB disconnected"
