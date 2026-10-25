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
sed -i '/Target Platform/d' feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/10_system.js && python3 -W ignore -c "import pathlib, re; p = pathlib.Path(\"feeds/luci/modules/luci-base/root/usr/share/rpcd/ucode/luci\"); q = pathlib.Path(\"feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/10_system.js\"); s = p.read_text(); t = q.read_text(); assert \"getCPUUsage\" not in s and \"callCPUUsage\" not in t; m = re.search(\"\tgetUnixtime: \{\n\t\tcall: function\(request\) \{\n\t\t\t// time\(\) ; Returns the current UNIX epoch\.\n\t\t\treturn \{ result: time\(\) \};\n\t\t\}\n\t\},\n\", s); assert m; assert \"var callSystemInfo = rpc.declare({\n\tobject: 'system',\n\tmethod: 'info'\n});\" in t; assert \"\t\t\tuci.load('system')\n\t\t]);\" in t; assert \"\t\t    systeminfo  = data[1],\" in t; assert \"\t\t\t) : null\n\t\t];\" in t; ins = \"\n\tgetCPUUsage: {\n\t\tcall: function() {\n\t\t\tconst fd = popen('top -n1');\n\t\t\tif (fd) {\n\t\t\t\tlet u = '?';\n\t\t\t\tfor (let line = fd.read('line'); length(line); line = fd.read('line')) {\n\t\t\t\t\tlet mm = match(line, /^CPU:.* ([0-9]+)% idle/);\n\t\t\t\t\tif (mm) u = sprintf('%d%', 100 - mm[1]);\n\t\t\t\t}\n\t\t\t\tfd.close();\n\t\t\t\treturn { cpuusage: u };\n\t\t\t} else {\n\t\t\t\treturn { cpuusage: error() };\n\t\t\t}\n\t\t}\n\t},\n\"; s = s[:m.end()] + ins + s[m.end():]; t = t.replace(\"var callSystemInfo = rpc.declare({\n\tobject: 'system',\n\tmethod: 'info'\n});\", \"var callSystemInfo = rpc.declare({\n\tobject: 'system',\n\tmethod: 'info'\n});\n\nvar callCPUUsage = rpc.declare({\n\tobject: 'luci',\n\tmethod: 'getCPUUsage'\n});\", 1); t = t.replace(\"\t\t\tuci.load('system')\n\t\t]);\", \"\t\t\tuci.load('system'),\n\t\t\tL.resolveDefault(callCPUUsage(), {})\n\t\t]);\", 1); t = t.replace(\"\t\t    systeminfo  = data[1],\", \"\t\t    systeminfo  = data[1],\n\t\t    cpuusage    = data[5],\", 1); t = t.replace(\"\t\t\t) : null\n\t\t];\", \"\t\t\t) : null,\n\t\t\t_('CPU usage (%)'),    cpuusage.cpuusage\n\t\t];\", 1); p.write_text(s); q.write_text(t)" || { echo "DIY FAIL: status page upstream changed"; exit 1; }
MJS=feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/20_memory.js; for p in "_('Buffered')" "_('Cached')" "_('Swap free')" "if (mem.buffered)" "if (mem.cached)" "if (swap.total > 0)"; do grep -qF "$p" "$MJS" || { echo "20_memory.js: pattern not found: $p"; exit 1; }; done; sed -i "/_('Buffered')/d; /_('Cached')/d; /_('Swap free')/d; /if (mem.buffered)/d; /if (mem.cached)/d; /if (swap.total > 0)/d" "$MJS"
rm -rf feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/{25_storage.js,50_dsl.js,60_wifi.js}
rm -rf feeds/luci/applications/luci-app-ddns/htdocs/luci-static/resources/view/status/include/70_ddns.js

# 计划任务
mkdir -p package/base-files/files/etc/crontabs && printf '%s\n' '# 定时重启（每周六凌晨3点33）' '#33 3 * * 6 sleep 66 && touch /etc/banner && reboot' > package/base-files/files/etc/crontabs/root

# 修改插件位置
sed -i 's/vpn/services/g' feeds/luci/applications/luci-app-zerotier/root/usr/share/luci/menu.d/luci-app-zerotier.json

# 修改WIFI名称
sed -i "s/ssid='.*'/ssid='OpenWrt'/g" package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc
# 修改WIFI密码
sed -i "s/key='.*'/key='password'/g" package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc
# 修改WIFI地区
sed -i "s/country='.*'/country='CN'/g" package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc
# 修改WIFI加密
sed -i "s/encryption='.*'/encryption='psk2+ccmp'/g" package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc

