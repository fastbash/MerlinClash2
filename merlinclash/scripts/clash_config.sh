#!/bin/sh

source /koolshare/scripts/base.sh
eval `dbus export merlinclash`
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
mkdir -p /tmp/upload
LOG_FILE=/tmp/upload/merlinclash_log.txt
SIMLOG_FILE=/tmp/upload/merlinclash_simlog.txt
rm -rf $LOG_FILE
rm -rf $SIMLOG_FILE
echo "" > /tmp/upload/merlinclash_log.txt
echo "" > $SIMLOG_FILE
http_response "$1"

get(){
	a=$(echo $(dbus get $1))
	a=$(echo $(dbus get $1))
	echo $a
}

mcenable=$(get merlinclash_enable)
prepare(){
	[ -n "`cat /etc/dnsmasq.conf|grep no-resolv`" ] && sed -i '/no-resolv/d' /etc/dnsmasq.conf
	[ -n "`cat /etc/dnsmasq.conf|grep servers-file`" ] && sed -i '/servers-file/d' /etc/dnsmasq.conf
	[ -n "`cat /etc/dnsmasq.conf|grep dhcp-option-force=br1`" ] && sed -i '/dhcp-option-force=br1/d' /etc/dnsmasq.conf
	[ -n "`cat /etc/dnsmasq.conf|grep dhcp-option-force=br2`" ] && sed -i '/dhcp-option-force=br2/d' /etc/dnsmasq.conf
}

case $ACTION in
start)
	rm -rf /jffs/scripts/dnsmasq.postconf
    prepare
    sed -i '$a no-resolv' /etc/dnsmasq.conf
    sed -i '$a servers-file=/tmp/resolv.dnsmasq' /etc/dnsmasq.conf
    if [ "$mcenable" == "1" ];then
    	sleepset=$(get merlinclash_auto_delay_cbox)
		logger "[软件中心-开机自启]: MerlinClash自启推迟状态:$sleepset"
		if [ "$sleepset" == "1" ]; then		
			sleeptime=$(get merlinclash_auto_delay_time)
			logger "[软件中心-开机自启]: MerlinClash自启推迟:$sleeptime秒！"
			sleep ${sleeptime}s
			logger "[软件中心-开机自启]: MerlinClash自启推迟:$sleeptime秒 结束！"
		fi
		[ ! -L "/jffs/scripts/dnsmasq.postconf" ] && ln -sf /koolshare/merlinclash/conf/dnsmasq.postconf /jffs/scripts/dnsmasq.postconf && echo_date "创建dnsmasq.postconf软链接" >> $LOG_FILE
		sh /koolshare/merlinclash/clashconfig.sh start >> /tmp/upload/merlinclash_log.txt
	else
		logger "[软件中心-开机自启]: MerlinClash自未启动"
	fi

	;;
start_nat)
	logger "[软件中心-NAT重启]: IPTABLES发生变化，Merlin Clash NAT重启！"
	echo_date "[软件中心-NAT重启]: IPTABLES发生变化，Merlin Clash NAT重启！" >> $LOG_FILE
	echo_date "[软件中心-NAT重启]: MerlinClash开关状态为：【$mcenable】" >> $LOG_FILE
	if [ ! -n "$mcenable" ]; then	
		logger "[软件中心-NAT重启]: MerlinClash开关状态获取失败，强制退出！"
		exit 1
	fi
	if [ "$mcenable" == "1" -a "$(pidof clash)" -a "$(netstat -anp | grep clash | head -n 5)" -a ! -n "$(grep "Parse config error" /tmp/clash_run.log)" ]; then	
		logger "[软件中心-NAT重启]: MerlinClash完全启动，开始重写dns配置和iptables"
		echo_date "[软件中心-NAT重启]: MerlinClash完全启动，开始重写dns配置和iptables" >> $LOG_FILE
		[ ! -L "/jffs/scripts/dnsmasq.postconf" ] && ln -sf /koolshare/merlinclash/conf/dnsmasq.postconf /jffs/scripts/dnsmasq.postconf && echo_date "创建dnsmasq.postconf软链接" >> $LOG_FILE
		sh /koolshare/merlinclash/clashconfig.sh start_nat >> /tmp/upload/merlinclash_log.txt
	else
		logger "[软件中心-NAT重启]: MerlinClash插件未开启或Clash未完全启动，终止写入dns配置和iptables"
		echo_date "[软件中心-NAT重启]: MerlinClash插件未开启或Clash未完全启动，终止写入dns配置和iptables" >> $LOG_FILE
	fi
	;;
esac

case $2 in
start)
	if [ "$mcenable" == "1" ];then
		echo start >> /tmp/upload/merlinclash_log.txt
		[ ! -L "/jffs/scripts/dnsmasq.postconf" ] && ln -sf /koolshare/merlinclash/conf/dnsmasq.postconf /jffs/scripts/dnsmasq.postconf && echo_date "创建dnsmasq.postconf软链接" >> $LOG_FILE
        sh /koolshare/merlinclash/clashconfig.sh restart >> /tmp/upload/merlinclash_log.txt
	else
		rm -rf /jffs/scripts/dnsmasq.postconf
		prepare
		sed -i '$a no-resolv' /etc/dnsmasq.conf
		sed -i '$a servers-file=/tmp/resolv.dnsmasq' /etc/dnsmasq.conf
		sh /koolshare/merlinclash/clashconfig.sh stop >> /tmp/upload/merlinclash_log.txt
	fi

	echo BBABBBBC >> /tmp/upload/merlinclash_log.txt
	echo BBABBBBC >> $SIMLOG_FILE
	;;
quicklyrestart)
	if [ "$mcenable" == "1" ];then
		echo "快速重启" >> /tmp/upload/merlinclash_log.txt
		[ ! -L "/jffs/scripts/dnsmasq.postconf" ] && ln -sf /koolshare/merlinclash/conf/dnsmasq.postconf /jffs/scripts/dnsmasq.postconf && echo_date "创建dnsmasq.postconf软链接" >> $LOG_FILE
		sh /koolshare/merlinclash/clashconfig.sh quicklyrestart >> /tmp/upload/merlinclash_log.txt
	else
		echo "请先启用MerlinClash" >> /tmp/upload/merlinclash_log.txt		
	fi
	echo BBABBBBC >> /tmp/upload/merlinclash_log.txt
	echo BBABBBBC >> $SIMLOG_FILE
	;;
upload)
	sh /koolshare/merlinclash/clashconfig.sh upload
	echo BBABBBBC >> /tmp/upload/merlinclash_log.txt
	;;
update)
	sh /koolshare/merlinclash/clash_update_ipdb.sh
	echo BBABBBBC >> /tmp/upload/merlinclash_log.txt
	
	;;
esac