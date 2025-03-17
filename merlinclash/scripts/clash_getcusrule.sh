#!/bin/sh

export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
#
get(){
	a=$(echo $(dbus get $1))
	a=$(echo $(dbus get $1))
	echo $a
}

yamlname=$(get merlinclash_yamlsel)

rm -rf /tmp/upload/${yamlname}_rules.txt

if [ -f "/koolshare/merlinclash/rule_use/${yamlname}_rules.yaml" ]; then
	ln -sf /koolshare/merlinclash/rule_use/${yamlname}_rules.yaml /tmp/upload/${yamlname}_rules.txt
else
	ln -sf /koolshare/merlinclash/rule_bak/${yamlname}_rules.yaml /tmp/upload/${yamlname}_rules.txt
fi

http_response $1

