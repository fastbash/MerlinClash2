#!/bin/sh
 
export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
LOG_FILE=/tmp/upload/merlinclash_log.txt
upload_path=/tmp/upload

get(){
	a=$(echo $(dbus get $1))
	a=$(echo $(dbus get $1))
	echo $a
}
yamlname=$(get merlinclash_yamlsel)
yamlpath=/koolshare/merlinclash/yaml_use/$yamlname.yaml
binary_type=$(get merlinclash_binary_type)
uploadname=$(get merlinclash_binary_type)
upload_file=/tmp/upload/$uploadname

getClashVersion(){
	binPath=$1

	local clashTmpV1=$($binPath -v 2>/dev/null | head -n 1 | cut -d " " -f2)
	local clashTmpV2=$($binPath -v 2>/dev/null | head -n 1 | cut -d " " -f3)
	if [ "$clashTmpV1" = "Meta" ];then
		clash_version="$clashTmpV1 $clashTmpV2"
	else
		clash_version=$clashTmpV1
	fi
	echo $clash_version
}

local_binary_replace(){
	chmod +x $upload_file
	case $binary_type in
	clash)
		clash_upload_ver=$(getClashVersion $upload_file)
		if [ -n "$clash_upload_ver" ]; then
			echo_date "上传Clash二进制版本为：$clash_upload_ver" >> $LOG_FILE
			echo_date "开始替换处理" >> $LOG_FILE
			replace_binary "clash"
		else
			echo_date "上传的二进制不合法！！！" >> $LOG_FILE
		fi
		;;
	subconverter)
		$upload_file  -v 2>/dev/null | head -n 1 | xargs killall subconverter > /tmp/sc.txt 2>&1
		sc_upload=$(cat /tmp/2.txt | grep verter)
		if [ -n "$sc_upload" ]; then
			echo_date "开始替换处理" >> $LOG_FILE
			replace_binary "subconverter"
		else
			echo_date "上传的二进制不合法！！！" >> $LOG_FILE
		fi
		;;
	esac
}

replace_binary(){
	case $1 in
	clash)
		echo_date "检查空间" >> $LOG_FILE
		SPACE_AVAL=$(df|grep jffs|head -n 1 | awk '{print $4}')
		SPACE_NEED=$(du -s /tmp/upload/clash | awk '{print $1}')
		if [ "$SPACE_AVAL" -gt "$SPACE_NEED" ];then
			echo_date 当前jffs分区剩余"$SPACE_AVAL" KB, 二进制需要"$SPACE_NEED" KB，空间满足，继续安装！ >> $LOG_FILE
			echo_date "开始替换clash二进制!" >> $LOG_FILE
			if [ "$(pidof clash)" ];then
				echo_date "为了保证更新正确，先关闭Clash主进程... " >> $LOG_FILE
				echo_date "为了保证更新正确，先关闭Clash看门狗..." >> $LOG_FILE
				sed -i '/clash_watchdog/d' /var/spool/cron/crontabs/* >/dev/null 2>&1
				killall clash >/dev/null 2>&1
				move_binary "clash"
				sleep 1
				start_clash
			else
				move_binary "clash"
			fi
		else
			echo_date 当前jffs分区剩余"$SPACE_AVAL" KB, 二进制需要"$SPACE_NEED" KB，空间不足！ >> $LOG_FILE
			echo_date 退出安装！ >> $LOG_FILE
			echo BBABBBBC >> $LOG_FILE
			rm -rf /tmp/upload/clash
			exit 1
		fi
		;;
	subconverter)
		echo_date "检查空间" >> $LOG_FILE
		SPACE_AVAL=$(df|grep jffs|head -n 1 | awk '{print $4}')
		SPACE_NEED=$(du -s /tmp/upload/subconverter | awk '{print $1}')
		if [ "$SPACE_AVAL" -gt "$SPACE_NEED" ];then
			echo_date 当前jffs分区剩余"$SPACE_AVAL" KB, 二进制需要"$SPACE_NEED" KB，空间满足，继续安装！ >> $LOG_FILE
			echo_date "开始替换Subconverter二进制!" >> $LOG_FILE
			move_binary "subconverter"
		else
			echo_date 当前jffs分区剩余"$SPACE_AVAL" KB, 二进制需要"$SPACE_NEED" KB，空间不足！ >> $LOG_FILE
			echo_date 退出安装！ >> $LOG_FILE
			echo BBABBBBC >> $LOG_FILE
			rm -rf /tmp/upload/subconverter
			exit 1
		fi
		;;
	esac
}

move_binary(){
	case $1 in 
	clash)
		echo_date "开始替换Clash二进制文件... " >> $LOG_FILE
		mv $upload_file /koolshare/bin/clash
		chmod +x /koolshare/bin/clash
		clash_local_ver=$(getClashVersion /koolshare/bin/clash)
		[ -n "$clash_local_ver" ] && dbus set merlinclash_clash_version="$clash_local_ver"
		echo_date "Clash二进制上传完成... " >> $LOG_FILE
		;;
	subconverter)
		echo_date "开始替换Subconverter二进制文件... " >> $LOG_FILE
		mv $upload_file /koolshare/merlinclash/subconverter/subconverter
		chmod +x /koolshare/merlinclash/subconverter/subconverter
		echo_date "Subconverter二进制上传完成... " >> $LOG_FILE
		;;
	esac
	
}

start_clash(){
	echo_date "开启Clash进程... " >> $LOG_FILE
	/bin/sh /koolshare/scripts/clash_config.sh quicklyrestart quicklyrestart
}

close_in_five() {
	echo_date "插件将在5秒后自动关闭！！"
	local i=5
	while [ $i -ge 0 ]; do
		sleep 1
		echo_date $i
		let i--
	done
	dbus set merlinclash_enable="0"
	sh /koolshare/scripts/clash_config.sh start
}

case $2 in
12)
	echo "本地上传二进制替换" > $LOG_FILE
	http_response "$1"
	local_binary_replace >> $LOG_FILE
	echo BBABBBBC >> $LOG_FILE	
	;;
esac