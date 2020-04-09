# 编译笔记

[![LICENSE](https://img.shields.io/github/license/mashape/apistatus.svg?style=flat-square&label=LICENSE)](https://github.com/P3TERX/Actions-OpenWrt/blob/master/LICENSE)
![GitHub Stars](https://img.shields.io/github/stars/P3TERX/Actions-OpenWrt.svg?style=flat-square&label=Stars&logo=github)
![GitHub Forks](https://img.shields.io/github/forks/P3TERX/Actions-OpenWrt.svg?style=flat-square&label=Forks&logo=github)

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

### SmartDNS

服务可以通过页面的软件包列表找到，luci界面通过下面的命令安装
 - 注意有两个luci-app-smartdns*.ipk, 都要用到，直接安装无compat的会出现下面的错误，只能重新刷固件才能恢复

```
/usr/lib/lua/luci/controller/smartdns.lua:25: attempt to call global 'view' (a nil value)
stack traceback:
	/usr/lib/lua/luci/controller/smartdns.lua:25: in function 't'
	/usr/lib/lua/luci/dispatcher.lua:465: in function 'createtree'
	/usr/lib/lua/luci/dispatcher.lua:188: in function 'dispatch'
	/usr/lib/lua/luci/dispatcher.lua:95: in function </usr/lib/lua/luci/dispatcher.lua:94>
```
 - 正确的安装步骤是，先装compat版，会有错误提示：uci: Entry not found，忽略继续装另一个版本即可。
```
cd /tmp
wget https://github.com/pymumu/smartdns/releases/download/Release30/luci-app-smartdns.1.2020.02.25-2212.all-luci-compat-all.ipk
opkg install luci-app-smartdns.1.2020.02.25-2212.all-luci-compat-all.ipk
# 这里会提示 uci: Entry not found 错误，继续...
wget https://github.com/pymumu/smartdns/releases/download/Release30/luci-app-smartdns.1.2020.02.25-2212.all-luci-all.ipk
opkg install luci-app-smartdns.1.2020.02.25-2212.all-luci-all.ipk
#安装完成

# 卸载时用到的命令
opkg remove luci-app-smartdns
```


## License

[MIT](https://github.com/P3TERX/Actions-OpenWrt/blob/master/LICENSE) © P3TERX
