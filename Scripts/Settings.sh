#!/bin/bash
#修改系统
mkdir -p files/etc/config
wget -qO- https://raw.githubusercontent.com/sos801107/TP-Link-TL-XDR6086/refs/heads/main/etc/openclash > files/etc/config/openclash
wget -qO- https://raw.githubusercontent.com/sos801107/TP-Link-TL-XDR6086/refs/heads/main/etc/mosdns > files/etc/config/mosdns
wget -qO- https://raw.githubusercontent.com/sos801107/TP-Link-TL-XDR6086/refs/heads/main/etc/smartdns > files/etc/config/smartdns

mkdir -p files/etc
wget -qO- https://raw.githubusercontent.com/sos801107/TP-Link-TL-XDR6086/refs/heads/main/etc/opkg.conf > files/etc/opkg.conf
mkdir -p files/etc/opkg
wget -qO- https://raw.githubusercontent.com/sos801107/TP-Link-TL-XDR6086/refs/heads/main/etc/distfeeds.conf > files/etc/opkg/distfeeds.conf
mkdir -p files/root
wget -qO- https://raw.githubusercontent.com/sos801107/TP-Link-TL-XDR6086/refs/heads/main/etc/.profile > files/root/.profile
#修改WIFI名称
mkdir -p files/lib/modules/5.4.284
wget -qO- https://raw.githubusercontent.com/sos801107/CloseWRT-CI/refs/heads/main/Config/mt_wifi.ko > files/lib/modules/5.4.284/mt_wifi.ko


#修改默认主题
sed -i "s/luci-theme-bootstrap/luci-theme-$WRT_THEME/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")
#修改immortalwrt.lan关联IP
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $(find ./feeds/luci/modules/luci-mod-system/ -type f -name "flash.js")
#添加编译日期标识
sed -i "s/(\(luciversion || ''\))/(\1) + (' \/ $WRT_MARK-$WRT_DATE')/g" $(find ./feeds/luci/modules/luci-mod-status/ -type f -name "10_system.js")

WIFI_FILE="./package/mtk/applications/mtwifi-cfg/files/mtwifi.sh"
#修改WIFI名称
sed -i "s/ImmortalWrt/$WRT_SSID/g" $WIFI_FILE
#修改WIFI加密
sed -i "s/encryption=.*/encryption='psk2+ccmp'/g" $WIFI_FILE
#修改WIFI密码
sed -i "/set wireless.default_\${dev}.encryption='psk2+ccmp'/a \\\t\t\t\t\t\set wireless.default_\${dev}.key='$WRT_WORD'" $WIFI_FILE

CFG_FILE="./package/base-files/files/bin/config_generate"
#修改默认IP地址
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $CFG_FILE
#修改默认主机名
sed -i "s/hostname='.*'/hostname='$WRT_NAME'/g" $CFG_FILE

#配置文件修改
echo "CONFIG_PACKAGE_luci=y" >> ./.config
echo "CONFIG_LUCI_LANG_zh_Hans=y" >> ./.config
echo "CONFIG_PACKAGE_luci-theme-$WRT_THEME=y" >> ./.config
echo "CONFIG_PACKAGE_luci-app-$WRT_THEME-config=y" >> ./.config
echo "CONFIG_TARGET_OPTIONS=y" >> ./.config
echo "CONFIG_TARGET_OPTIMIZATION=\"-O2 -pipe -march=armv8-a+crypto+crc -mcpu=cortex-a53+crypto+crc -mtune=cortex-a53\"" >> ./.config

#手动调整的插件
if [ -n "$WRT_PACKAGE" ]; then
	echo -e "$WRT_PACKAGE" >> ./.config
fi

#调整mtk系列配置
sed -i '/TARGET.*mediatek/d' ./.config
sed -i '/TARGET_MULTI_PROFILE/d' ./.config
sed -i '/TARGET_PER_DEVICE_ROOTFS/d' ./.config
cat $GITHUB_WORKSPACE/Config/$WRT_CONFIG.txt >> .config
