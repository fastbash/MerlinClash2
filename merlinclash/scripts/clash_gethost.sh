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
hostsel=$(get merlinclash_hostsel)
rm -rf /tmp/upload/$hostsel.txt

ln -sf /koolshare/merlinclash/yaml_basic/host/$hostsel.yaml /tmp/upload/$hostsel.txt

http_response $1

