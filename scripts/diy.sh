# 添加其他仓库的插件
rm -rf package/feeds/luci/luci-theme-argon
git clone --depth 1 -b main https://github.com/CC13594759/packages.git package/app
#docker
rm -rf feeds/luci/applications/luci-app-dockerman
git clone --depth 1 --single-branch --no-tags -b openwrt-24.10 https://github.com/sbwml/luci-app-dockerman package/luci-app-dockerman
sed -i '/"docker", "events"/d' package/luci-app-dockerman/luasrc/controller/dockerman.lua
git clone --depth 1 --single-branch --no-tags -b main https://github.com/sbwml/luci-lib-docker package/luci-lib-docker

# 修改默认主题
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' $(find ./feeds/luci/collections/ -type f -name "Makefile")

# 修改luci首页显示
sed -i 's/ImmortalWrt/OpenWrt/gi' package/base-files/files/bin/config_generate
sed -i '/downloads\.immortalwrt\.org/!s/ImmortalWrt/OpenWrt/gi' include/version.mk
cp -f $GITHUB_WORKSPACE/scripts/index.js feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/index.js
sed -i '/Target Platform/d' feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/10_system.js
MJS=feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/20_memory.js; for p in "_('Buffered')" "_('Cached')" "_('Swap free')" "if (mem.buffered)" "if (mem.cached)" "if (swap.total > 0)"; do grep -qF "$p" "$MJS" || { echo "20_memory.js: pattern not found: $p"; exit 1; }; done; sed -i "/_('Buffered')/d; /_('Cached')/d; /_('Swap free')/d; /if (mem.buffered)/d; /if (mem.cached)/d; /if (swap.total > 0)/d" "$MJS"
rm -rf feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/{25_storage.js,50_dsl.js,60_wifi.js}
rm -rf feeds/luci/applications/luci-app-ddns/htdocs/luci-static/resources/view/status/include/70_ddns.js

# 计划任务
mkdir -p package/base-files/files/etc/crontabs && printf '%s\n' '# 定时重启（每周六凌晨3点33）' '#33 3 * * 6 sleep 66 && touch /etc/banner && reboot' > package/base-files/files/etc/crontabs/root

# 修改插件位置
sed -i 's/vpn/services/g' feeds/luci/applications/luci-app-zerotier/root/usr/share/luci/menu.d/luci-app-zerotier.json

# 修改WIFI名称"OpenWrt"
sed -i 's/defaults?.ssid || "ImmortalWrt"/defaults?.ssid || "OpenWrt"/' package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc
# 修改WIFI密码"password"
sed -i 's/defaults?.key || ""/defaults?.key || "password"/' package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc
# 修改WIFI地区"CN"
sed -i "s/set \${s}.country='\${country || ''}'/set \${s}.country=\"CN\"/; s/set \${s}.country='\${country || \"CN\"}'/set \${s}.country=\"CN\"/" package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc
# 修改WIFI加密"psk2+ccmp"
sed -i 's/defaults?.encryption || encryption/defaults?.encryption || "psk2+ccmp"/' package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc

# 兼容8220分区
grep -q 'fixed-partitions' target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/ipq8071-ap8220.dts && awk 'BEGIN{c=0} /^\t\tpartitions \{$/{inpart=1; print "\t\tpartitions {"; print "\t\t\tcompatible = \"qcom,smem-part\";"; print "\t\t\tqcom,smem-flash-id = <" c ">;"; c++; next} inpart && /^\t\t\};$/{inpart=0; print; next} inpart{next} {print}' target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/ipq8071-ap8220.dts > /tmp/ap8220.dts && mv /tmp/ap8220.dts target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/ipq8071-ap8220.dts && grep -q 'qcom,smem-part' target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/ipq8071-ap8220.dts && [ "$(grep -c 'qcom,smem-part' target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/ipq8071-ap8220.dts)" = "2" ] && grep -q '/proc/mtd | awk' package/base-files/files/lib/functions.sh && sed -i '/^find_mtd_index/,/^}/ s#/proc/mtd #/proc/mtd | head -n1 #' package/base-files/files/lib/functions.sh && grep -q 'head -n1' package/base-files/files/lib/functions.sh || exit 1
