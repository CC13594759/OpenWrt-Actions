# 添加其他仓库的插件
#echo "CONFIG_PACKAGE_luci-app-dockerman=y" >> ./.config
# 修改默认IP
sed -i 's/192.168.1.1/192.168.12.1/g' package/base-files/files/bin/config_generate

# 修改默认主题
rm -rf feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg
cp -f $GITHUB_WORKSPACE/scripts/bg1.jpg feeds/luci/themes/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' $(find ./feeds/luci/collections/ -type f -name "Makefile")

# 修改luci首页显示
sed -i 's/ImmortalWrt/OpenWrt/gi' package/base-files/files/bin/config_generate
sed -i '/downloads\.immortalwrt\.org/!s/ImmortalWrt/OpenWrt/gi' include/version.mk
rm -rf feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/index.js
cp -f $GITHUB_WORKSPACE/scripts/index.js feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/index.js
sed -i -e '/"admin\/system\/plugins": {/,/"admin\/system\/startup": {/ { /"admin\/system\/startup": {/!d; }' feeds/luci/modules/luci-mod-system/root/usr/share/luci/menu.d/luci-mod-system.json
sed -i '/Target Platform/d' feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/10_system.js
MJS=feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/20_memory.js; for p in "_('Buffered')" "_('Cached')" "_('Swap free')" "if (mem.buffered)" "if (mem.cached)" "if (swap.total > 0)"; do grep -qF "$p" "$MJS" || { echo "20_memory.js: pattern not found: $p"; exit 1; }; done; sed -i "/_('Buffered')/d; /_('Cached')/d; /_('Swap free')/d; /if (mem.buffered)/d; /if (mem.cached)/d; /if (swap.total > 0)/d" "$MJS"
rm -rf feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/25_storage.js
rm -rf feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/50_dsl.js
rm -rf feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/60_wifi.js
rm -rf feeds/luci/applications/luci-app-ddns/htdocs/luci-static/resources/view/status/include/70_ddns.js

# 删除attendedsysupgrade
sed -i '/attendedsysupgrade/d' $(find ./feeds/luci/collections/ -type f -name "Makefile")

# 修改插件位置
sed -i 's/vpn/services/g' feeds/luci/applications/luci-app-zerotier/root/usr/share/luci/menu.d/luci-app-zerotier.json

# 修改homeproxy数据库
sed -i '/^case/,/^esac/d' feeds/luci/applications/luci-app-homeproxy/root/etc/homeproxy/scripts/update_resources.sh
sed -i '$a case "$1" in\n"china_ip4")\n check_list_update "$1" "Loyalsoldier/surge-rules" "release" "cncidr.txt" && \\\n  sed -i "/IP-CIDR6,/d; s/IP-CIDR,//g" "$RESOURCES_DIR/china_ip4.txt"\n ;;\n"china_ip6")\n check_list_update "$1" "Loyalsoldier/surge-rules" "release" "cncidr.txt" && \\\n  sed -i "/IP-CIDR,/d; s/IP-CIDR6,//g" "$RESOURCES_DIR/china_ip6.txt"\n ;;\n"gfw_list")\n check_list_update "$1" "Loyalsoldier/surge-rules" "release" "gfw.txt" && \\\n  sed -i "s/^\\.//g" "$RESOURCES_DIR/gfw_list.txt"\n ;;\n"china_list")\n check_list_update "$1" "Loyalsoldier/surge-rules" "release" "direct.txt" && \\\n  sed -i "s/^\\.//g" "$RESOURCES_DIR/china_list.txt"\n ;;\n*)\n echo -e "Usage: $0 <china_ip4 / china_ip6 / gfw_list / china_list>"\n exit 1\n ;;\nesac' feeds/luci/applications/luci-app-homeproxy/root/etc/homeproxy/scripts/update_resources.sh
HP_GEN=feeds/luci/applications/luci-app-homeproxy/root/etc/homeproxy/scripts/generate_client.uc; python3 -c 'import sys;p=sys.argv[1];s=open(p,encoding="utf-8").read();o="\t\tconst main_urltest_nodes = uci.get(uciconfig, ucimain, \x27main_urltest_nodes\x27) || [];";n="\t\t/* Drop stale node references, e.g. removed by subscription updates */\n\t\tconst main_urltest_nodes = filter(uci.get(uciconfig, ucimain, \x27main_urltest_nodes\x27) || [],\n\t\t\t(v) => !isEmpty(uci.get(uciconfig, v)));";assert s.count(o)==1,"m1";s=s.replace(o,n);o="\t\tconst main_udp_urltest_nodes = uci.get(uciconfig, ucimain, \x27main_udp_urltest_nodes\x27) || [];";n="\t\t/* Drop stale node references, e.g. removed by subscription updates */\n\t\tconst main_udp_urltest_nodes = filter(uci.get(uciconfig, ucimain, \x27main_udp_urltest_nodes\x27) || [],\n\t\t\t(v) => !isEmpty(uci.get(uciconfig, v)));";assert s.count(o)==1,"m2";s=s.replace(o,n);o="\t\tif (cfg.node === \x27urltest\x27) {\n\t\t\tpush(config.outbounds, {";n="\t\tif (cfg.node === \x27urltest\x27) {\n\t\t\t/* Drop stale node references, e.g. removed by subscription updates */\n\t\t\tconst urltest_node_list = filter(cfg.urltest_nodes || [], (v) => !isEmpty(uci.get(uciconfig, v)));\n\t\t\tpush(config.outbounds, {";assert s.count(o)==1,"m3";s=s.replace(o,n);o="\t\t\t\toutbounds: map(cfg.urltest_nodes, (k) => `cfg-${k}-out`),";n="\t\t\t\toutbounds: map(urltest_node_list, (k) => `cfg-${k}-out`),";assert s.count(o)==1,"m4";s=s.replace(o,n);o="\t\t\turltest_nodes = [...urltest_nodes, ...filter(cfg.urltest_nodes, (l) => !~index(urltest_nodes, l))];";n="\t\t\turltest_nodes = [...urltest_nodes, ...filter(urltest_node_list, (l) => !~index(urltest_nodes, l))];";assert s.count(o)==1,"m5";s=s.replace(o,n);open(p,"w",encoding="utf-8").write(s);print("homeproxy #356 fix applied")' "$HP_GEN" || exit 1

# 计划任务
mkdir -p package/base-files/files/etc/crontabs && printf '%s\n' '# 定时重启（每个星期六凌晨2点50）' '#50 2 * * 6 sleep 5 && touch /etc/banner && reboot' > package/base-files/files/etc/crontabs/root

# 修改WIFI名称
sed -i "s/ssid='.*'/ssid='OpenWrt'/g" package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc
# 修改WIFI密码
sed -i "s/key='.*'/key='password'/g" package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc
# 修改WIFI地区
sed -i "s/country='.*'/country='CN'/g" package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc
# 修改WIFI加密
sed -i "s/encryption='.*'/encryption='psk2+ccmp'/g" package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc

