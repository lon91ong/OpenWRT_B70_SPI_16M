#!/bin/bash
#=================================================
# Description: DIY script
# Lisence: MIT
# Author: P3TERX
# Blog: https://p3terx.com
#=================================================
# Modify default IP
sed -i 's/192.168.1.1/192.168.77.1/g' ./package/base-files/files/bin/config_generate
# Web sysupgrade Fix
sed -i '/^.*hc5962.*/d' ./target/linux/ramips/mt7621/base-files/lib/upgrade/platform.sh
#- name: Costom configure file
#run: |
#rm -f ./package/system/fstools/files/mount.hotplug
#cp -f $GITHUB_WORKSPACE/mount.hotplug ./package/system/fstools/files/
cp -f $GITHUB_WORKSPACE/mt7621_hiwifi_hc5962-spi.dts ./target/linux/ramips/dts/
# 内核5.4配置32M闪存, 参考https://github.com/coolsnowwolf/lede/issues/5113
#sed -i '/spi-max-frequency/a\\t\tbroken-flash-reset;' ./target/linux/ramips/dts/mt7621_hiwifi_hc5962.dts
sed -i 's/<0x50000 0xfb0000>/<0x50000 0x1fb0000>/g' ./target/linux/ramips/dts/mt7621_hiwifi_hc5962-spi.dts
sed -i 's/hc5962/&|\\\n\thiwifi,hc5962-spi/g' ./target/linux/ramips/mt7621/base-files/etc/board.d/02_network
# 下面一行适配内核4.14
sed -i 's/<&gpio /<\&gpio0 /g' ./target/linux/ramips/dts/mt7621_hiwifi_hc5962-spi.dts
#sed -i 's/16064/32128/g' ./target/linux/ramips/image/mt7621.mk
# Add a feed source
#sed -i '$a src-git lienol https://github.com/Lienol/openwrt-package' feeds.conf.default
cat >> ./target/linux/ramips/image/mt7621.mk <<EOF
define Device/hiwifi_hc5962-spi
  IMAGE_SIZE := 32128k
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
# ========================固件定制部分========================
# 编译极路由B70固件:
cat >> .config <<EOF
CONFIG_TARGET_ramips=y
CONFIG_TARGET_ramips_mt7621=y
CONFIG_TARGET_ramips_mt7621_DEVICE_hiwifi_hc5962-spi=y
# 常用LuCI插件选择: 添加外面的主题和应用
CONFIG_PACKAGE_luci-app-aria2=y
CONFIG_PACKAGE_webui-aria2=y
CONFIG_PACKAGE_aria2=y
CONFIG_PACKAGE_luci-app-wol=n
CONFIG_PACKAGE_luci-app-upnp=y
CONFIG_PACKAGE_luci-app-accesscontrol=n
CONFIG_PACKAGE_luci-app-filetransfer=y
CONFIG_PACKAGE_luci-app-unblockmusic=n
CONFIG_PACKAGE_luci-app-unblockneteasemusic-mini=n
CONFIG_PACKAGE_luci-app-vsftpd=y
CONFIG_PACKAGE_luci-app-cifs-mount=y
CONFIG_PACKAGE_luci-app-vlmcsd=n
CONFIG_PACKAGE_luci-app-zerotier=n
# SSR Configuration 16M固件取 n, 32M固件取 y
CONFIG_PACKAGE_luci-app-ssr-plus=y
CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Shadowsocks=y
CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_V2ray_plugin=y
CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Trojan=y
CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Redsocks2=y
CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_ShadowsocksR_Server=n
CONFIG_PACKAGE_luci-app-ssrserver-python=n
CONFIG_PACKAGE_shadowsocks-libev-ss-local=y
CONFIG_PACKAGE_shadowsocks-libev-ss-redir=y
CONFIG_PACKAGE_shadowsocksr-libev-alt=y
CONFIG_PACKAGE_shadowsocksr-libev-server=y
CONFIG_PACKAGE_shadowsocksr-libev-ssr-local=y
# 常用软件包:
CONFIG_PACKAGE_mount-utils=n
CONFIG_PACKAGE_automount=y
CONFIG_PACKAGE_kmod-fs-ext4=y
CONFIG_PACKAGE_curl=y
CONFIG_PACKAGE_htop=y
CONFIG_PACKAGE_screen=y
CONFIG_PACKAGE_tree=y
CONFIG_PACKAGE_vim-fuller=y
CONFIG_PACKAGE_wget=y
# ===================固件定制部分结束===================
# 修改默认主题
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' ./feeds/luci/collections/luci/Makefile
sed -i 's/^[ \t]*//g' ./.config
make defconfig
