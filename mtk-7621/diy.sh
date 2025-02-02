# 修改默认IP
sed -i 's/192.168.1.1/192.168.12.1/g' package/base-files/files/bin/config_generate

# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

# airconnect
git clone --depth=1 https://github.com/CC13594759/luci-app-airconnect package/luci-app-airconnect

# 修改本地时间格式
sed -i 's/os.date()/os.date("%Y-%m-%d %H:%M:%S")/g' package/lean/autocore/files/*/index.htm

# 去除主页一串的LUCI版本号显示
sed -i 's/distversion)%>/distversion)%><!--/g' package/lean/autocore/files/*/index.htm
sed -i 's/luciversion)%>)/luciversion)%>)-->/g' package/lean/autocore/files/*/index.htm

# 修改 Makefile
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/..\/..\/lang\/golang\/golang-package.mk/$(TOPDIR)\/feeds\/packages\/lang\/golang\/golang-package.mk/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/PKG_SOURCE_URL:=@GHREPO/PKG_SOURCE_URL:=https:\/\/github.com/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/PKG_SOURCE_URL:=@GHCODELOAD/PKG_SOURCE_URL:=https:\/\/codeload.github.com/g' {}

# 修改插件名字
sed -i 's/"ShadowSocksR Plus+"/"SSR Plus"/g' `egrep "ShadowSocksR Plus+" -rl ./`

#修改插件位置
sed -i "/exit 0/i\sed -i 's/nas/services/g' /usr/lib/lua/luci/controller/samba4.lua" package/lean/default-settings/files/zzz-default-settings
sed -i "/exit 0/i\sed -i 's/nas/services/g' /usr/lib/lua/luci/controller/aria2.lua" package/lean/default-settings/files/zzz-default-settings
sed -i "/exit 0/i\sed -i 's/nas/services/g' /usr/lib/lua/luci/view/aria2/overview_status.htm" package/lean/default-settings/files/zzz-default-settings

#删除系统英文语言
sed -i 's/LUCI_LANG_en/LUCI_LANG_zh-cn/g' package/lean/default-settings/Makefile

#替换luci源
sed -i 's|^#src-git luci https://github.com/coolsnowwolf/luci|src-git luci https://github.com/coolsnowwolf/luci|' feeds.conf.default
sed -i 's|^src-git luci https://github.com/coolsnowwolf/luci.git;openwrt-23.05|#src-git luci https://github.com/coolsnowwolf/luci.git;openwrt-23.05|' feeds.conf.default

# etc默认设置
#cp -a $GITHUB_WORKSPACE/mtk-7621/etc/* package/base-files/files/etc/

./scripts/feeds update -a
./scripts/feeds install -a

#修改插件位置
sed -i 's/vpn/services/g' feeds/luci/applications/luci-app-zerotier/luasrc/controller/zerotier.lua
sed -i 's/VPN/Services/g' feeds/luci/applications/luci-app-zerotier/luasrc/controller/zerotier.lua
sed -i 's/vpn/services/g' feeds/luci/applications/luci-app-zerotier/luasrc/view/zerotier/zerotier_status.htm
