# 添加其他仓库的插件
rm -rf package/feeds/luci/luci-theme-argon
git clone --depth 1 -b main https://github.com/CC13594759/packages.git package/app

# 修改默认IP
sed -i 's/192.168.1.1/192.168.12.1/g' package/base-files/files/bin/config_generate

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
rm -f target/linux/qualcommax/base-files/etc/uci-defaults/992_set-*-load.sh target/linux/qualcommax/base-files/sbin/cpuusage

# 修改插件位置
sed -i 's/vpn/services/g' feeds/luci/applications/luci-app-zerotier/root/usr/share/luci/menu.d/luci-app-zerotier.json

# 计划任务
mkdir -p package/base-files/files/etc/crontabs && printf '%s\n' '# 定时重启（每周六凌晨3点33）' '#33 3 * * 6 sleep 66 && touch /etc/banner && reboot' > package/base-files/files/etc/crontabs/root

# 修改WIFI名称
sed -i "s/ssid='.*'/ssid='OpenWrt'/g" package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc
# 修改WIFI密码
sed -i "s/key='.*'/key='password'/g" package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc
# 修改WIFI地区
sed -i "s/country='.*'/country='CN'/g" package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc
# 修改WIFI加密
sed -i "s/encryption='.*'/encryption='psk2+ccmp'/g" package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc

