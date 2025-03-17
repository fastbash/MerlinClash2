#!/bin/sh

export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
#

case $2 in
koolproxy)
    if [ -f "/koolshare/merlinclash/yaml_basic/kpipset.yaml" ]; then
        ln -sf /koolshare/merlinclash/yaml_basic/kpipset.yaml /tmp/upload/clash_kpipset.txt
    else
        rm -rf /tmp/upload/clash_kpipset.txt
    fi
    if [ -f "/koolshare/merlinclash/yaml_basic/kpipsetarround.yaml" ]; then
        ln -sf /koolshare/merlinclash/yaml_basic/kpipsetarround.yaml /tmp/upload/clash_kpipsetarround.txt
    else   
        rm -rf /tmp/upload/clash_kpipsetarround.txt
    fi
    ;;
*)
    if [ -f "/koolshare/merlinclash/yaml_basic/ipsetproxy.yaml" ]; then
        ln -sf /koolshare/merlinclash/yaml_basic/ipsetproxy.yaml /tmp/upload/clash_ipsetproxy.txt
    else
        rm -rf /tmp/upload/clash_ipsetproxy.txt
    fi
    if [ -f "/koolshare/merlinclash/yaml_basic/ipsetproxyarround.yaml" ]; then
        ln -sf /koolshare/merlinclash/yaml_basic/ipsetproxyarround.yaml /tmp/upload/clash_ipsetproxyarround.txt
    else   
        rm -rf /tmp/upload/clash_ipsetproxyarround.txt
    fi
    ;;
esac

http_response $1

