#!/bin/bash
#=================================================
# File name: hook-feeds.sh
# Author: SuLingGG
# Blog: https://mlapp.cn
#=================================================
#--------------------------------------------------------
#   If you use some codes frome here, please give credit to www.helmiau.com
#--------------------------------------------------------

# Clone Lean's feeds
mkdir customfeeds
git clone --depth=1 https://github.com/coolsnowwolf/packages customfeeds/packages
git clone --depth=1 https://github.com/coolsnowwolf/luci customfeeds/luci

# Clone ImmortalWrt's feeds
pushd customfeeds
mkdir temp
git clone --depth=1 https://github.com/immortalwrt/packages -b openwrt-18.06 temp/packages
git clone --depth=1 https://github.com/immortalwrt/luci -b openwrt-18.06-k5.4 temp/luci

# Add luci-app-adguardhome
cp -r temp/luci/applications/luci-app-adguardhome luci/applications/luci-app-adguardhome
cp -r temp/packages/net/adguardhome packages/net/adguardhome
cp -r temp/packages/lang/node-yarn packages/lang/node-yarn
cp -r temp/packages/devel/packr packages/devel/packr

# Add luci-app-cpulimit
cp -r temp/luci/applications/luci-app-cpulimit luci/applications/luci-app-cpulimit
cp -r temp/packages/utils/cpulimit packages/cpulimit

# Add luci-proto-modemmanager
cp -r temp/luci/protocols/luci-proto-modemmanager luci/protocols/luci-proto-modemmanager

# Replace coolsnowwolf/lede watchcat and luci-app-watchcat with immortalwrt source
rm -rf packages/utils/watchcat
rm -rf luci/applications/luci-app-watchcat
cp -r temp/luci/applications/luci-app-watchcat luci/applications/luci-app-watchcat
cp -r temp/packages/utils/watchcat packages/utils/watchcat

# Replace coolsnowwolf/lede php7 with immortalwrt source
rm -rf packages/lang/php7
cp -r temp/packages/lang/php7 packages/lang/php7

# Add tmate
cp -r temp/packages/net/tmate packages/net/tmate
cp -r temp/packages/libs/msgpack-c packages/libs/msgpack-c

# Add minieap
cp -r temp/packages/net/minieap packages/net/minieap

# Add v2rayA
cp -r temp/packages/net/xray-core packages/net/xray-core
cp -r temp/packages/net/xray-plugin packages/net/xray-plugin
cp -r temp/packages/net/v2raya packages/net/v2raya
sed -i 's#include ../../lang/golang#include $(TOPDIR)/feeds/packages/lang/golang#g' packages/net/v2raya/Makefile

# Clearing temp directory
rm -rf temp
popd

# Set to local feeds
pushd customfeeds/packages
export packages_feed="$(pwd)"
popd
pushd customfeeds/luci
export luci_feed="$(pwd)"
popd
sed -i '/src-git packages/d' feeds.conf.default
echo "src-link packages $packages_feed" >> feeds.conf.default
sed -i '/src-git luci/d' feeds.conf.default
echo "src-link luci $luci_feed" >> feeds.conf.default

# Update feeds
./scripts/feeds update -a
./scripts/feeds install -a
