#!/bin/sh

source /koolshare/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'

LOG_FILE=/tmp/upload/merlinclash_log.txt

echo_date "定时重启Clash进程... " >> $LOG_FILE
/bin/sh /koolshare/merlinclash/clashconfig.sh restart


