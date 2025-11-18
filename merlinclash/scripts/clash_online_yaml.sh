#!/bin/sh

LOCK_FILE=/var/lock/merlinclash_yaml_online_update.lock

. /koolshare/scripts/clash_base.sh

. /koolshare/scripts/clash_download.sh


cd . > "${LOG_FILE:?}"
# rm -rf /tmp/upload/*.yaml
flag=0
upname=""
upname_tmp=""
#subscription_type：1:Clash-Yaml配置下载 2:HND_小白订阅 3：384_小白订阅 4：HND_SC订阅 5:384_ACL订阅 
#subscription_type：6：HND_自定订阅 7：HND_远程订阅 8:384_远程订阅
subscription_type="1"
dictionary=/koolshare/merlinclash/yaml_bak/subscription.txt
updateflag=""
Regularlog=/tmp/upload/merlinclash_regular.log


start_online_update(){
    updateflag="start_online_update"
    link1=$(get merlinclash_links)
    links=$(decode_url_link "$link1")
    merlinc_link="$links"
    LINK_FORMAT=$(echo "$merlinc_link" | grep -E "^http://|^https://")
    echo_date "订阅地址是：$LINK_FORMAT"
    if [ -z "$LINK_FORMAT" ]; then
        echo_date "订阅地址错误！检测到你输入的订阅地址并不是标准网址格式！"
        sleep 2
        echo_date "退出订阅程序" >> "$LOG_FILE"
    else
        upname_tmp=$(get merlinclash_uploadrename)
        
        newname=$(date "+%H%M%S")
        if [ -n "$upname_tmp" ]; then
            upname=$upname_tmp.yaml
        else
            upname=$newname.yaml
        fi
        echo_date "订阅配置文件 重命名为：$upname" 
        #echo_date merlinclash_link=$merlinc_link >> "$LOG_FILE"
        #wget下载文件
        #wget --no-check-certificate -t3 -T30 -4 -O /tmp/upload/$upname "$merlinc_link"
        if download_by_mc2 "$merlinc_link" "/tmp/upload/$upname";then
        	echo_date "订阅配置文件 下载完成" >> "$LOG_FILE"
        else
			echo_date "订阅配置文件 下载失败..." >> "$LOG_FILE"
			failed_warning_clash
        fi
		#虽然为0但是还是要检测下是否下载到正确的内容
        if [ "$(wc -c < "/tmp/upload/$upname")" -lt 10 ]; then
            echo_date "订阅配置文件 ${upname} 下载内容过小，疑似下载失败..." >> "$LOG_FILE"
            failed_warning_clash
        fi
        echo_date "已获取 Clash 订阅配置文件" >> "$LOG_FILE"
        echo_date "订阅配置文件 yaml合法性检查" >> "$LOG_FILE"
        check_yamlfile
        if [ $? = "1" ]; then
        #执行上传文件名.yaml处理工作，包括去注释，去空白行，去除dns以上头部，将标准头部文件复制一份到/tmp/ 跟tmp的标准头部文件合并，生成新的head.yaml，再将head.yaml复制到/koolshare/merlinclash/并命名为upload.yaml
            echo_date "执行yaml文件预处理工作" >> "$LOG_FILE"
            sh /koolshare/scripts/clash_yaml_sub.sh #>/dev/null 2>&1 &
            #20200803写入字典
            echo_date "开始创建字典" >> "$LOG_FILE"
            write_dictionary
            echo_date "字典创建完成" >> "$LOG_FILE"
            echo_date "订阅完成" >> "$LOG_FILE"
			after_update
        else
            echo_date "yaml文件格式不合法" >> "$LOG_FILE"
        fi
    fi
}

start_regular_update(){
    updateflag="start_regular_update"

    subscription_type="1"
    upname="$1.yaml"
    merlinc_link="$2"

    echo_date "订阅配置名称【${upname}】" | tee -a "$Regularlog" | tee -a "$LOG_FILE" >/dev/null
    echo_date "订阅配置地址【${merlinc_link}】" | tee -a "$Regularlog" | tee -a "$LOG_FILE" >/dev/null
    #wget --no-check-certificate -t3 -T30 -4 -O /tmp/upload/$upname "$merlinc_link"
    if download_by_mc2 "$merlinc_link" "/tmp/upload/$upname" >> "$Regularlog";then
		echo_date "订阅配置文件 ${upname} 下载完成" | tee -a "$LOG_FILE" | tee -a "$Regularlog" >/dev/null
	else
		echo_date "订阅配置文件 ${upname} 下载失败..." >> "$LOG_FILE"
		failed_warning_clash
	fi
	#虽然为0但是还是要检测下是否下载到正确的内容
    if [ "$(wc -c < "/tmp/upload/$upname")" -lt 10 ]; then
        echo_date "订阅配置文件 ${upname} 下载内容过小，疑似下载失败..." >> "$LOG_FILE"
		failed_warning_clash
	fi
    echo_date "已获取 Clash 订阅配置文件" >> "$Regularlog"
    echo_date "订阅配置文件 yaml合法性检查" >> "$Regularlog"
    check_yamlfile
    if [ $? = "1" ]; then
    #执行上传文件名.yaml处理工作，包括去注释，去空白行，去除dns以上头部，将标准头部文件复制一份到/tmp/ 跟tmp的标准头部文件合并，生成新的head.yaml，再将head.yaml复制到/koolshare/merlinclash/并命名为upload.yaml
        echo_date "执行yaml文件处理工作" >> "$Regularlog"
        sh /koolshare/scripts/clash_yaml_sub.sh #>/dev/null 2>&1 &
        #20200803写入字典
        #write_dictionary    
        echo_date "订阅完成" >> "$Regularlog"
		after_update
    else
        echo_date "yaml文件格式不合法" >> "$Regularlog"
    fi
}

write_dictionary(){
    /bin/sh /koolshare/scripts/clash_dictionary.sh "$upname" "$subscription_type" "$merlinc_link" 
}

failed_warning_clash(){
    # rm -rf "/tmp/upload/${upname:?}"
    echo_date "获取文件 /tmp/upload/${upname:?} 失败！！请检查网络！" >> "$LOG_FILE"
    echo_date "===================================================================" >> "$LOG_FILE"
    # echo BBABBBBC
    return 1
}


after_update(){
    if [ -z "$(dbus get merlinclash_yamlsel)" ] && [ -n "$(cat /koolshare/merlinclash/yaml_bak/yamls.txt)" ];then
        dbus set merlinclash_yamlsel="$(grep -v '^$' /koolshare/merlinclash/yaml_bak/yamls.txt | head -n1)"
    fi
    if ! dbus listall | grep -q merlinclash_select_regular;then
        #打开自动订阅
        dbus set merlinclash_select_regular_day=1
        dbus set merlinclash_select_regular_hour=5
        dbus set merlinclash_select_regular_minute=0
        dbus set merlinclash_select_regular_minute_2=2
        dbus set merlinclash_select_regular_subscribe=2
        dbus set merlinclash_select_regular_week=1
    fi
    if ! cru l | grep -q regular_subscribe;then
        cru a regular_subscribe "0 5 * * * /bin/sh /koolshare/scripts/clash_regular_update.sh"
    fi
	return 0
}

check_yamlfile(){
    /bin/sh /koolshare/scripts/clash_checkyaml.sh "/tmp/upload/$upname"
}

case $2 in
2)
    #set_lock
    echo "" > "$LOG_FILE"
    http_response "$1"
    echo_date "在线clash订阅" >> "$LOG_FILE"
    echo_date "订阅UserAgent为：$UA" >> "$LOG_FILE"
    echo_date "clash订阅链接处理" >> "$LOG_FILE"
    start_online_update >> "$LOG_FILE"
    status_code=$?
    echo BBABBBBC | tee -a "$LOG_FILE"
	exit $status_code
    #unset_lock
    ;;
1)
    echo_date "clash订阅定时更新" | tee -a "$LOG_FILE" | tee -a "$Regularlog" >/dev/null
	# name https://...
    start_regular_update "$1" "$3" >> "$LOG_FILE"
    status_code=$?
    echo BBABBBBC | tee -a "$LOG_FILE"
	exit $status_code
    # echo_date "" >> "$Regularlog"
    #echo BBABBBBC >> "$LOG_FILE"
    ;;
esac

