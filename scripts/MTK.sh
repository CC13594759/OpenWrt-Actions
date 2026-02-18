# 添加其他仓库的插件 然后去config里添加上对应的插件名

# 修改默认IP
sed -i 's/192.168.6.1/192.168.12.1/g' package/base-files/files/bin/config_generate

# 修改默认主题
rm -rf feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg
cp -f $GITHUB_WORKSPACE/scripts/bg1.jpg feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' $(find ./feeds/luci/collections/ -type f -name "Makefile")

# 修改luci首页显示
sed -i 's/ImmortalWrt/OpenWrt/gi' package/base-files/files/bin/config_generate
sed -i 's/ImmortalWrt/OpenWrt/gi' include/version.mk
rm -rf feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/index.js
cp -f $GITHUB_WORKSPACE/scripts/index.js feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/index.js
sed -i '/Target Platform/d' feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/10_system.js
sed -i '38,47d' feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/20_memory.js
rm -rf feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/25_storage.js
rm -rf feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/29_ports.js
rm -rf feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/50_dsl.js
rm -rf feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/60_wifi.js
rm -rf feeds/luci/applications/luci-app-ddns/htdocs/luci-static/resources/view/status/include/70_ddns.js

# 删除attendedsysupgrade
sed -i '/attendedsysupgrade/d' $(find ./feeds/luci/collections/ -type f -name "Makefile")

# 删除ttyd
sed -i 's/luci-app-ttyd//g' target/linux/mediatek/Makefile

# 关闭RFC1918
sed -i 's/option rebind_protection 1/option rebind_protection 0/g' package/network/services/dnsmasq/files/dhcp.conf
sed -i 's/8000/0/g' package/network/services/dnsmasq/files/dhcp.conf

# 修改插件位置
sed -i 's/vpn/services/g' feeds/luci/applications/luci-app-zerotier/root/usr/share/luci/menu.d/luci-app-zerotier.json

# 修改homeproxy数据库
sed -i '/^case/,/^esac/d' feeds/luci/applications/luci-app-homeproxy/root/etc/homeproxy/scripts/update_resources.sh
sed -i '$a case "$1" in\n"china_ip4")\n check_list_update "$1" "Loyalsoldier/surge-rules" "release" "cncidr.txt" && \\\n  sed -i "/IP-CIDR6,/d; s/IP-CIDR,//g" "$RESOURCES_DIR/china_ip4.txt"\n ;;\n"china_ip6")\n check_list_update "$1" "Loyalsoldier/surge-rules" "release" "cncidr.txt" && \\\n  sed -i "/IP-CIDR,/d; s/IP-CIDR6,//g" "$RESOURCES_DIR/china_ip6.txt"\n ;;\n"gfw_list")\n check_list_update "$1" "Loyalsoldier/surge-rules" "release" "gfw.txt" && \\\n  sed -i "s/^\\.//g" "$RESOURCES_DIR/gfw_list.txt"\n ;;\n"china_list")\n check_list_update "$1" "Loyalsoldier/surge-rules" "release" "direct.txt" && \\\n  sed -i "s/^\\.//g" "$RESOURCES_DIR/china_list.txt"\n ;;\n*)\n echo -e "Usage: $0 <china_ip4 / china_ip6 / gfw_list / china_list>"\n exit 1\n ;;\nesac' feeds/luci/applications/luci-app-homeproxy/root/etc/homeproxy/scripts/update_resources.sh

# etc默认设置
cp -a $GITHUB_WORKSPACE/scripts/etc/* package/base-files/files/etc/

# 修改WIFI名称
sed -i 's/ImmortalWrt/OpenWrt/g' package/mtk/applications/mtwifi-cfg/files/mtwifi.sh
# 修改WIFI加密
sed -i "s/encryption=.*/encryption='psk2+ccmp'/g" package/mtk/applications/mtwifi-cfg/files/mtwifi.sh
# 修改WIFI密码
sed -i "/set wireless.default_\${dev}.encryption='psk2+ccmp'/a \\\t\t\t\t\t\set wireless.default_\${dev}.key='password'" $WIFI_FILE

./scripts/feeds update -a
./scripts/feeds install -a
