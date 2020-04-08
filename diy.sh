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
cp -f ../mt7621_hiwifi_hc5962-spi.dts ./target/linux/ramips/dts/
cat >> ./target/linux/ramips/image/mt7621.mk <<EOF
define Device/hiwifi_hc5962-spi
  IMAGE_SIZE := 16064k
  DEVICE_VENDOR := HiWiFi
  DEVICE_MODEL := HC5962
  DEVICE_PACKAGES := kmod-mt7603 kmod-mt76x2 kmod-usb3 kmod-sdhci-mt7620 \
	kmod-usb-ledtrig-usbport wpad-openssl
endef
TARGET_DEVICES += hiwifi_hc5962-spi
EOF
sed -i 's/^[ \t]*//g' ./target/linux/ramips/image/mt7621.mk
# 
rm -f ./.config*
touch ./.config
# 
# ========================固件定制部分========================
# 
# 编译极路由B70固件:
cat >> .config <<EOF
CONFIG_TARGET_ramips=y
CONFIG_TARGET_ramips_mt7621=y
CONFIG_TARGET_ramips_mt7621_DEVICE_hiwifi_hc5962-spi=y
EOF
# 常用LuCI插件选择: 添加外面的主题和应用，包是通过diy.sh 脚本进行下载。
cat >> .config <<EOF
CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Trojan=y
CONFIG_PACKAGE_luci-app-wol=n
CONFIG_PACKAGE_luci-app-upnp=n
CONFIG_PACKAGE_luci-app-accesscontrol=n
CONFIG_PACKAGE_luci-app-ddns=n
CONFIG_PACKAGE_luci-app-filetransfer=y
CONFIG_PACKAGE_luci-app-unblockmusic=n
CONFIG_PACKAGE_luci-app-unblockneteasemusic-mini=n
CONFIG_PACKAGE_luci-app-vsftpd=y
CONFIG_PACKAGE_luci-app-vlmcsd=n
CONFIG_PACKAGE_luci-app-zerotier=n
CONFIG_PACKAGE_luci-app-koolproxyR=y
CONFIG_PACKAGE_luci-app-samba=y
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
CONFIG_PACKAGE_automount=y
CONFIG_PACKAGE_autosamba=y
CONFIG_PACKAGE_kmod-fs-ext4=y
CONFIG_PACKAGE_curl=y
CONFIG_PACKAGE_htop=y
CONFIG_PACKAGE_screen=y
CONFIG_PACKAGE_tree=y
CONFIG_PACKAGE_vim-fuller=y
CONFIG_PACKAGE_wget=y
EOF
# 
# ========================固件定制部分结束========================
# 
sed -i 's/^[ \t]*//g' ./.config
make defconfig
