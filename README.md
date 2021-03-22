# 编译笔记

[![LICENSE](https://img.shields.io/github/license/mashape/apistatus.svg?style=flat-square&label=LICENSE)](https://github.com/P3TERX/Actions-OpenWrt/blob/master/LICENSE)
![GitHub Stars](https://img.shields.io/github/stars/P3TERX/Actions-OpenWrt.svg?style=flat-square&label=Stars&logo=github)
![GitHub Forks](https://img.shields.io/github/forks/P3TERX/Actions-OpenWrt.svg?style=flat-square&label=Forks&logo=github)

![芯片图](./images/B70.jpg)
### 参考

[利用github action功能，自己给极路由3编译l固件（基于lean）](https://www.right.com.cn/forum/thread-2906191-1-1.html)

[newifi3](https://github.com/liwenjie119/lede/blob/master/config/newifi3.config)

[MT7621芯片的各种路由器](https://www.right.com.cn/forum/thread-217908-1-1.html)

Build OpenWrt using GitHub Actions

[Read the details in my blog (in Chinese) | 中文教程](https://p3terx.com/archives/build-openwrt-with-github-actions.html)

## 说明

- 硬改SPI闪存后的硬件规格和youku-L2以及newifi-D1相近, 主要参考两者的dts文件配置来拼凑.
- 通过Star出发Action实现云端编译.
- [无线中继问题参考](https://www.right.com.cn/forum/thread-314109-1-1.html)
- U盘中文乱码[参考1](https://www.right.com.cn/forum/thread-248712-1-1.html), [参考2](https://www.right.com.cn/forum/thread-208227-1-1.html), [#2136](https://github.com/coolsnowwolf/lede/issues/2136)
- [解决openwrt页面升级中“不支持所上传的文件格式”问题](https://www.openwrtdl.com/wordpress/不支持所上传的文件格式请确认选择的文件无误) LEDE下该方法无效，可以用`sysupgrade`命令行下升级以跳过固件校验。参考：[OpenWrt升级脚本sysupgrade详解](http://www.linvon.cn/post/OpenWrt升级脚本sysupgrade详解/)
```
# sysupgrade命令参数：
-d 重启前等待 delay 秒
-f 从 .tar.gz (文件或链接) 中恢复配置文件
-i 交互模式
-c 保留 /etc 中所有修改过的文件
-n 重刷固件时不保留配置文件
-T | –test 校验固件 config .tar.gz，但不真正烧写
-F | –force 即使固件校验失败也强制烧写
-q 较少的输出信息
-v 详细的输出信息
-h 显示帮助信息
备份选项：
-b | –create-backup
把sysupgrade.conf 里描述的文件打包成.tar.gz 作为备份，不做烧写动作
-r | –restore-backup
从-b 命令创建的 .tar.gz 文件里恢复配置，不做烧写动作
-l | –list-backup
列出 -b 命令将备份的文件列表，但不创建备份文件
# 实用实例：
sysupgrade -v -F /tmp/openwrt-ramips-mt7621-hiwifi_hc5962-spi-squashfs-sysupgrade.bin  # 保留配置,强制升级
sysupgrade -n -v /tmp/openwrt-ramips-mt7621-hiwifi_hc5962-spi-squashfs-sysupgrade.bin  # 干净升级
```

## 备忘

 - [Breed](https://breed.hackpascal.net/), 适用与硬改SPI闪存B70的版本是[breed-mt7621-youku-l2.bin](https://breed.hackpascal.net/breed-mt7621-youku-l2.bin)为什么？看上面的“MT7621芯片的各种路由器”
 - [B70刷breed，刷灯大固件，简明步骤](https://www.right.com.cn/forum/thread-338869-1-1.html)
``` shell
root@Hiwifi:~# cd /tmp  # 都放在/tmp下操作
root@Hiwifi:/tmp# cat /proc/mtd     # 查看原固件信息
    mtd0: 00080000 00020000 "u-boot"
    mtd1: 00080000 00020000 "debug"
    mtd2: 00040000 00020000 "Factory"
    mtd3: 02000000 00020000 "firmware"
    mtd4: 00180000 00020000 "kernel"
    mtd5: 01e80000 00020000 "rootfs"
    mtd6: 00080000 00020000 "hw_panic"
    mtd7: 00080000 00020000 "bdinfo"
    mtd8: 00080000 00020000 "backup"
    mtd9: 01000000 00020000 "overlay"
    mtd10: 02000000 00020000 "firmware_backup"
    mtd11: 00200000 00020000 "oem"
    mtd12: 02ac0000 00020000 "opt"
# 备份原固件各分区到tmp目录下，挂*必备
dd if=/dev/mtd0 of=/tmp/u-boot.bin *
dd if=/dev/mtd1 of=/tmp/debug.bin
dd if=/dev/mtd2 of=/tmp/Factory.bin *
dd if=/dev/mtd3 of=/tmp/firmware.bin *
dd if=/dev/mtd4 of=/tmp/kernel.bin
dd if=/dev/mtd5 of=/tmp/rootfs.bin
dd if=/dev/mtd6 of=/tmp/hw_panic.bin
dd if=/dev/mtd7 of=/tmp/bdinfo.bin
dd if=/dev/mtd8 of=/tmp/backup.bin
...
# 刷写breed
mtd write breed-mt7621-youku-l2.bin u-boot
# 擦除固件备份，不然重启会被覆盖回去
mtd erase firmware_backup
# 刷写固件，需要自动重启用`mtd -r write ...`, 成功执行完命令后自动重启
mtd write openwrt-ramips-mt7621-hiwifi_hc5962-spi-squashfs-sysupgrade.bin firmware
```
如果路由器配置被你完全搞乱了，但是还能启动并且可以连上SSH，那么按照下面来备份：

仅对 /overlay 打包备份即可: `tar -czvf /tmp/overlay_backup.tar.gz /overlay`

需要恢复的时候将 overlay_backup.tar.gz 上传至 /tmp ，然后清空 /overlay 并恢复备份：
```
rm -rvf /overlay/* 
cd /
tar -xzvf /tmp/overlay_backup.tar.gz
```

### SmartDNS

[LEDE项目大佬对smartdns的态度](https://github.com/coolsnowwolf/lede/issues/2551)

服务可以通过页面的软件包列表找到，luci界面通过下面的命令安装

```
cd /tmp
wget https://github.com/pymumu/smartdns/releases/download/Release30/luci-app-smartdns.1.2020.02.25-2212.all-luci-compat-all.ipk
opkg install luci-app-smartdns.1.2020.02.25-2212.all-luci-compat-all.ipk
# 这里会提示 uci: Entry not found 错误，无视...
# 安装完成

# 卸载时用到的命令
opkg remove luci-app-smartdns
```

## License

[MIT](https://github.com/P3TERX/Actions-OpenWrt/blob/master/LICENSE) © P3TERX
