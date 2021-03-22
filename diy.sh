#!/bin/bash
#=================================================
# Description: DIY script
# Lisence: MIT
# Author: P3TERX
# Blog: https://p3terx.com
#=================================================
# Modify default IP
sed -i 's/192.168.1.1/192.168.77.1/g' package/base-files/files/bin/config_generate
# Web sysupgrade Fix
sed -i '/^.*hc5962.*/d' target/linux/ramips/mt7621/base-files/lib/upgrade/platform.sh
#- name: Costom configure file
#run: |
#rm -f ./package/system/fstools/files/mount.hotplug
#cp -f $GITHUB_WORKSPACE/mount.hotplug ./package/system/fstools/files/
cp -f $GITHUB_WORKSPACE/mt7621_hiwifi_hc5962-spi.dts ./target/linux/ramips/dts/
# 下面一行适配内核4.14
sed -i 's/<&gpio /<\&gpio0 /g' ./target/linux/ramips/dts/mt7621_hiwifi_hc5962-spi.dts
cat >> ./target/linux/ramips/image/mt7621.mk <<EOF
define Device/hiwifi_hc5962-spi
  IMAGE_SIZE := 16064k
  DEVICE_VENDOR := HiWiFi
  DEVICE_MODEL := HC5962
  DEVICE_PACKAGES := luci-app-mtwifi
endef
TARGET_DEVICES += hiwifi_hc5962-spi
EOF
sed -i 's/^[ \t]*//g' ./target/linux/ramips/image/mt7621.mk
# 修改默认主题
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' ./feeds/luci/collections/luci/Makefile
cp -f $GITHUB_WORKSPACE/.config ./
#rm -f ./.config*
#touch ./.config
# ========================固件定制部分========================

# ========================固件定制部分结束========================
sed -i 's/^[ \t]*//g' ./.config
# make defconfig
