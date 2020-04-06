#!/bin/bash
#=================================================
# Description: DIY script
# Lisence: MIT
# Author: P3TERX
# Blog: https://p3terx.com
#=================================================
# Modify default IP
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate
#- name: Costom configure file
#run: |
rm -f ./.config*
touch ./.config
#  chmod +x $DIY_SH
#  ./$DIY_SH
#
# ========================固件定制部分========================
  
# 编译极路由B70固件:
cat >> .config <<EOF
CONFIG_TARGET_ramips=y
CONFIG_TARGET_ramips_mt7621=y
CONFIG_TARGET_ramips_mt7621_DEVICE_youku_yk-l2=y
CONFIG_TARGET_PROFILE="DEVICE_hiwifi_hc5962"
CONFIG_TARGET_PREINIT_TIMEOUT=2
CONFIG_TARGET_PREINIT_IP="192.168.9.1"
CONFIG_TARGET_PREINIT_NETMASK="255.255.255.0"
CONFIG_TARGET_PREINIT_BROADCAST="192.168.9.255"
CONFIG_DEFAULT_kmod-usb-ledtrig-usbport=y
CONFIG_DEFAULT_kmod-usb3=y
CONFIG_USB_SUPPORT=y
CONFIG_DEFAULT_kmod-mt7603=y
CONFIG_DEFAULT_kmod-mt76x2=y
EOF

# 文件系统
cat >> .config <<EOF
CONFIG_PACKAGE_kmod-fs-ext4=y
CONFIG_PACKAGE_ntfs-3g=y
CONFIG_PACKAGE_kmod-fs-vfat=y
CONFIG_PACKAGE_kmod-fuse=y
EOF

# USB支持
cat >> .config <<EOF
CONFIG_PACKAGE_kmod-usb-core=y
CONFIG_PACKAGE_kmod-usb-ehci=y
# CONFIG_PACKAGE_kmod-usb-hid is not set
CONFIG_PACKAGE_kmod-usb-ledtrig-usbport=y
# CONFIG_PACKAGE_kmod-usb-net is not set
CONFIG_PACKAGE_kmod-usb-ohci=y
CONFIG_PACKAGE_kmod-usb-ohci-pci=y
CONFIG_PACKAGE_kmod-usb-storage=y
CONFIG_PACKAGE_kmod-usb-storage-extras=y
CONFIG_PACKAGE_kmod-usb2=y
CONFIG_PACKAGE_kmod-usb2-pci=y
CONFIG_PACKAGE_kmod-usb3=y
CONFIG_PACKAGE_automount=y
EOF

# 常用LuCI插件选择: 添加外面的主题和应用，包是通过diy.sh 脚本进行下载。
cat >> .config <<EOF
CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Trojan=n
CONFIG_PACKAGE_luci-app-wol=n
CONFIG_PACKAGE_luci-app-upnp=n
CONFIG_PACKAGE_luci-app-accesscontrol=n
CONFIG_PACKAGE_luci-app-ddns=n
CONFIG_PACKAGE_luci-app-filetransfer=n
CONFIG_PACKAGE_luci-app-unblockneteasemusic-mini=n
CONFIG_PACKAGE_luci-app-vsftpd=n
CONFIG_PACKAGE_luci-app-vlmcsd=n
CONFIG_PACKAGE_luci-app-zerotier=n
CONFIG_PACKAGE_luci-app-koolproxyR=y
CONFIG_PACKAGE_luci-app-ramfree=y
CONFIG_PACKAGE_luci-theme-argon=y
EOF

# 关闭ipv6:
cat >> .config <<EOF
CONFIG_KERNEL_IPV6=n
CONFIG_KERNEL_IPV6_MULTIPLE_TABLES=n
CONFIG_KERNEL_IPV6_SUBTREES=n
CONFIG_KERNEL_IPV6_MROUTE=n
CONFIG_IPV6=n
EOF

# 常用软件包:
cat >> .config <<EOF
CONFIG_PACKAGE_curl=y
CONFIG_PACKAGE_htop=y
CONFIG_PACKAGE_screen=y
CONFIG_PACKAGE_tree=y
CONFIG_PACKAGE_vim-fuller=y
CONFIG_PACKAGE_wget=y
EOF

# ========================固件定制部分结束========================
# 
sed -i 's/^[ \t]*//g' ./.config
make defconfig
