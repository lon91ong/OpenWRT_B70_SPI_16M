#!/bin/bash
rm -f ./target/linux/ramips/dts/mt7621_hiwifi_hc5962-spi.dts
sed -i 's/192.168.1.1/192.168.77.1/g' ./package/base-files/files/bin/config_generate
sed -i '/^.*hc5962.*/d' ./target/linux/ramips/mt7621/base-files/lib/upgrade/platform.sh
wget -P ./target/linux/ramips/dts/ https://raw.sevencdn.com/lon91ong/OpenWRT_B70_SPI_16M/master/mt7621_hiwifi_hc5962-spi.dts
chmod 644 ./target/linux/ramips/dts/mt7621_hiwifi_hc5962-spi.dts
chmod 644 ./target/linux/ramips/image/mt7621.mk
chmod 644 ./target/linux/ramips/mt7621/base-files/etc/board.d/02_network
sed -i 's/hc5962)/hc5962|\\\n\thiwifi,hc5962-spi\)/g' ./target/linux/ramips/mt7621/base-files/etc/board.d/02_network
sed -i 's/<&gpio /<\&gpio0 /g' ./target/linux/ramips/dts/mt7621_hiwifi_hc5962-spi.dts
#cat >> ./target/linux/ramips/image/mt7621.mk <<EOF
#define Device/hiwifi_hc5962-spi
#  IMAGE_SIZE := 16064k
#  DEVICE_VENDOR := HiWiFi
#  DEVICE_MODEL := HC5962
#  DEVICE_PACKAGES := kmod-mt7603 kmod-mt76x2 kmod-usb3 wpad-openssl
#endef
#TARGET_DEVICES += hiwifi_hc5962-spi
#EOF
# 下面两条适配32M闪存
sed -i 's/<0x50000 0xfb0000>/<0x50000 0x1fb0000>/g' ./target/linux/ramips/dts/mt7621_hiwifi_hc5962-spi.dts
#sed -i 's/16064/32128/g' ./target/linux/ramips/image/mt7621.mk
# 修改默认主题
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' ./feeds/luci/collections/luci/Makefile
rm -f ./.config*
touch ./.config
# ===========固件定制部分=============
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
CONFIG_PACKAGE_luci-theme-argon=y
CONFIG_PACKAGE_luci-theme-bootstrap=n
# passwall Configuration 16M固件取 n, 32M固件取 y
CONFIG_PACKAGE_luci-app-ssr-plus=n
CONFIG_PACKAGE_luci-app-passwall=y
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Shadowsocks=y
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Shadowsocks_Server=y
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ShadowsocksR=y
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ShadowsocksR_Server=y
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Xray=y
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Trojan_Plus=y
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Trojan_GO=y
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_haproxy=y
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_dns2socks=y
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_v2ray-plugin=y
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_simple-obfs=y
CONFIG_PACKAGE_shadowsocks-libev-ss-server=y
CONFIG_PACKAGE_shadowsocks-libev-ss-redir=y
CONFIG_PACKAGE_shadowsocks-libev-ss-local=y
CONFIG_PACKAGE_shadowsocksr-libev-server=y
# 常用软件包:
CONFIG_PACKAGE_mount-utils=n
CONFIG_PACKAGE_automount=y
CONFIG_PACKAGE_coreutils-nohup=y
CONFIG_PACKAGE_kmod-fs-ext4=y
CONFIG_PACKAGE_curl=y
CONFIG_PACKAGE_htop=y
CONFIG_PACKAGE_libmbedtls=y
CONFIG_PACKAGE_ipt2socks=y
CONFIG_PACKAGE_ssocks=y
CONFIG_PACKAGE_screen=y
CONFIG_PACKAGE_trojan-go=y
CONFIG_PACKAGE_tree=y
CONFIG_PACKAGE_unzip=y
CONFIG_PACKAGE_vim-fuller=y
CONFIG_PACKAGE_wget=y
EOF
sed -i 's/^[ \t]*//g' ./.config
make defconfig

#make dirclean #清除上一次编译产生的垃圾
make download -j8 V=s
make -j6 V=s
