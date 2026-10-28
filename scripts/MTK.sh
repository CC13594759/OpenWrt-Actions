# 添加其他仓库的插件
git clone --depth 1 -b main https://github.com/CC13594759/packages.git package/app
rm -rf package/app/luci-theme-argon

# 修改默认IP
sed -i 's/192.168.6.1/192.168.13.1/g' package/base-files/files/bin/config_generate

# 修改默认主题
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' $(find ./feeds/luci/collections/ -type f -name "Makefile")

# 修改luci首页显示
sed -i 's/ImmortalWrt/OpenWrt/gi' package/base-files/files/bin/config_generate
sed -i '/downloads\.immortalwrt\.org/!s/ImmortalWrt/OpenWrt/gi' include/version.mk
cp -f $GITHUB_WORKSPACE/scripts/index.js feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/index.js
sed -i -e '/"admin\/system\/plugins": {/,/"admin\/system\/startup": {/ { /"admin\/system\/startup": {/!d; }' feeds/luci/modules/luci-mod-system/root/usr/share/luci/menu.d/luci-mod-system.json
sed -i '/Target Platform/d' feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/10_system.js
MJS=feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/20_memory.js; for p in "_('Buffered')" "_('Cached')" "_('Swap free')" "if (mem.buffered)" "if (mem.cached)" "if (swap.total > 0)"; do grep -qF "$p" "$MJS" || { echo "20_memory.js: pattern not found: $p"; exit 1; }; done; sed -i "/_('Buffered')/d; /_('Cached')/d; /_('Swap free')/d; /if (mem.buffered)/d; /if (mem.cached)/d; /if (swap.total > 0)/d" "$MJS"
rm -rf feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/{25_storage.js,50_dsl.js,60_wifi.js}
rm -rf feeds/luci/applications/luci-app-ddns/htdocs/luci-static/resources/view/status/include/70_ddns.js

# 删除ttyd
sed -i 's/luci-app-ttyd//g' target/linux/mediatek/Makefile

# 修改插件位置
sed -i 's/vpn/services/g' feeds/luci/applications/luci-app-zerotier/root/usr/share/luci/menu.d/luci-app-zerotier.json

# 计划任务
mkdir -p package/base-files/files/etc/crontabs && printf '%s\n' '# 定时重启（每周六凌晨3点33）' '#33 3 * * 6 sleep 66 && touch /etc/banner && reboot' > package/base-files/files/etc/crontabs/root

# 修改WIFI名称
sed -i 's/ImmortalWrt/OpenWrt/g' package/mtk/applications/mtwifi-cfg/files/mtwifi.sh
# 修改WIFI加密
sed -i "s/encryption=.*/encryption='psk2+ccmp'/g" package/mtk/applications/mtwifi-cfg/files/mtwifi.sh
# 修改WIFI密码
sed -i "/psk2+ccmp/a \\\t\t\t\t\t\set wireless.default_\${dev}.key='password'" package/mtk/applications/mtwifi-cfg/files/mtwifi.sh

# 修改最大连接数为65535
sed -i "s/conntrack_max=.*/conntrack_max=65535/g" package/kernel/linux/files/sysctl-nf-conntrack.conf

