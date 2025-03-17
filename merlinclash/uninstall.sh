#!/bin/sh
eval `dbus export merlinclash`
source /koolshare/scripts/base.sh


if [ "$merlinclash_enable" == "1" ];then
	echo 先关闭clash插件！
	#sh /koolshare/merlinclash/clashconfig.sh stop
    sleep 1s
	exit 
fi


find /koolshare/init.d/ -name "*clash*" | xargs rm -rf
rm -rf /koolshare/bin/clash
rm -rf /koolshare/bin/jq >/dev/null 2>&1
rm -rf /koolshare/bin/haveged >/dev/null 2>&1
rm -rf /tmp/upload/yamls.txt
rm -rf /tmp/upload/*_status.txt
rm -rf /tmp/upload/merlinclash*
rm -rf /tmp/upload/dlercloud.log >/dev/null 2>&1
rm -rf /tmp/upload/host_yaml.txt
rm -rf /tmp/upload/dns_redirhost.txt >/dev/null 2>&1
rm -rf /tmp/upload/dns_fakeip.txt >/dev/null 2>&1
rm -rf /tmp/upload/proxygroups.txt >/dev/null 2>&1

rm -rf /koolshare/bin/subconverter
rm -rf /koolshare/res/icon-merlinclash.png
rm -rf /koolshare/res/clash-dingyue.png
rm -rf /koolshare/res/clash*
rm -rf /koolshare/res/merlinclash.css
rm -rf /koolshare/res/mc-tablednd.js
rm -rf /koolshare/res/mc-menu.js
rm -rf /koolshare/res/china_ip_route.ipset
rm -rf /koolshare/res/china_ip_route6.ipset
#
rm -rf /koolshare/merlinclash/Country.mmdb
rm -rf /koolshare/merlinclash/GeoIP.dat
rm -rf /koolshare/merlinclash/GeoSite.dat
rm -rf /koolshare/merlinclash/clashconfig.sh
rm -rf /koolshare/merlinclash/yaml_bak/*
rm -rf /koolshare/merlinclash/yaml_use/*
rm -rf /koolshare/merlinclash/yaml_basic/*
rm -rf /koolshare/merlinclash/yaml_dns/*
rm -rf /koolshare/merlinclash/subconverter/*
rm -rf /koolshare/merlinclash/conf/*
rm -rf /koolshare/merlinclash/dashboard/*
rm -rf /koolshare/scripts/clash*.sh
rm -rf /koolshare/webs/Module_merlinclash.asp
rm -rf /koolshare/merlinclash
rm -rf /koolshare/scripts/merlinclash_install.sh
rm -rf /koolshare/scripts/uninstall_merlinclash.sh
rm -rf /tmp/dc*
rm -rf /jffs/configs/dnsmasq.d/clash*
rm -rf /jffs/configs/dnsmasq.d/dns_custom.conf >/dev/null 2>&1

#清除相关skipd数据

datas=`dbus list merlinclash_ | cut -d "=" -f 1`
for data in $datas
do
	dbus remove $data
done
dbus remove softcenter_module_merlinclash_install
dbus remove softcenter_module_merlinclash_version
