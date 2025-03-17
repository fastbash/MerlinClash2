#!/bin/sh

export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
eval $(dbus export merlinclash_)
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'

pid_clash=$(pidof clash)
pid_d2s=$(pidof mc_dns2socks)
pid_watchdog=$(perpls | grep clash | grep -Eo "uptime.+-s\ " | awk -F" |:|/" '{print $3}')
date=$(echo_date)
get(){
	a=$(echo $(dbus get $1))
	a=$(echo $(dbus get $1))
	echo $a
}
yamlname=$(get merlinclash_yamlsel)
#yamlpath=/koolshare/merlinclash/yaml_use/$yamlname.yaml
yamlpath=/tmp/upload/view.txt
starttime=$(get merlinclash_clashstarttime)
lan_ipaddr=$(nvram get lan_ipaddr)
board_port="9990"
if [ ! -f $yamlpath ]; then
    host=''
    port=''
    secret=''
else
    host_port=$(cat $yamlpath | awk -F": " '/external-controller/{print $2}')
    port=$(cat $yamlpath | awk -F: '/external-controller/{print $3}')
    secret=$(cat $yamlpath | awk '/secret:/{print $2}' | sed 's/"//g')
fi

if [ -n "$pid_clash" ]; then
    text1="<span style='color: #6C0'>$date Clash 进程运行正常！(PID: $pid_clash)</span>"
    text4="<span style='color: gold'>面板端口：$port</span>"
    text3="<span style='color: gold'>管理面板：$host_port</span>"
    text15="<span style='color: gold'>面板密码：$secret</span>"
    text18="<span style='color: #6C0'>【Clash本次启动时间】：$starttime</span>"
    
else
    text1="<span style='color: red'>$date Clash 进程未在运行！</span>"
    text18="<span style='color: red'>$date Clash 进程未在运行！</span>"
    
fi

if [ -n "$pid_watchdog" ]; then
    text2="<span style='color: #6C0'>$date Clash 进程实时守护中！</span>"
else
    text2="<span style='color: gold'>$date Clash 进程守护未在运行！</span>"
fi

yamlsel_tmp2=$yamlname


#内置SC规则文件版本
scver=$(get merlinclash_scrule_version)
if [ "$scver" != "" ]; then
    text13="<span style='color: gold'>当前版本：s$scver</span>"
else    
    text13="<span style='color: gold'>当前版本：s0</span>"
fi


if [ "$yamlname" != "" ]; then
    text14="<span style='display:table-cell;float: middle; color: gold'>当前配置为：$yamlname</span>"
fi

cirtag=$(ipset list china_ip_route | wc -l)
if [ -n "$cirtag" ]; then
    dbus set merlinclash_cirtag=$cirtag
else
    dbus set merlinclash_cirtag=0
fi

#获取本地HTTP代理端口
proxyPort=$merlinclash_cus_port

#检查域名是否被污染
checkHostIsBlock(){
    local domain=$(echo $1|sed -E 's/^https?:\/\/([^\/:]+).*$/\1/')
    local ip=$(ping -4 -c 1 -W 1 "$domain" 2>/dev/null | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -n 1)
    if [ "$ip" == "127.0.0.1" ] || [ "$ip" == "0.0.0.0" ] || [ -z "$ip" ]; then
        return 1
    else
        return 0
    fi
}
#请求都到这里来
requestUrl(){
    local url=$1
    local use_proxy=$2
    local proxyPort=$3
    local result
    local UA="User-Agent: curl/merlin clash 5.20"
    
    checkHostIsBlock $url
    if [ "$?" -eq "0" ];then
        if [ "$use_proxy" = true ]; then
            result=$(curl --max-time 2 --retry 1 -s  -H "$UA"  --proxy 127.0.0.1:"$proxyPort" "$url" 2>/dev/null)
            if [ -z "$result" ]; then
                result=$(wget --no-hsts -q -O - --timeout=2 --tries=1 --header="$UA" -e use_proxy=yes -e http_proxy=127.0.0.1:"$proxyPort" "$url" 2>/dev/null)
            fi
        else
            result=$(curl --max-time 2 --retry 1 -s -H "$UA" "$url" 2>/dev/null)
            if [ -z "$result" ]; then
                result=$(wget --no-hsts -q -O - --timeout=2 --tries=1 --header="$UA" "$url" 2>/dev/null)
            fi
        fi
        echo "$result"
    fi
}

getIPinfo(){
    local url=$1;
    if [ -z "$url" ];then
        echo "出现错误了，找管理解决"
        return 0
    fi
    
    # 获取信息
    if [ -z "$2" ];then
        # 获取本地 IP 地址并去掉换行符 国内不需要代理
        # local localip=$(wget --no-hsts -q -O - --timeout=3 --tries=2 --header="User-Agent: curl/8.1.2" "$url" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}')
        local localip=$(requestUrl $url | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}')
        # 构建查询 URL
        local queryhost="https://api-v3.speedtest.cn/ip?ip=${localip}"
        # local result=$(curl --max-time 5 -s $queryhost)
        local result=$(requestUrl $queryhost)
        local return=$(echo "$result" | jq -r '.data |  "\(.country)\(.province)\(.city)\(.isp)"' 2>/dev/null)
    else
        # 获取本地 IP 地址
        # local localip=$(wget --no-hsts -q -O - --timeout=3 --tries=2 --header="User-Agent: curl/8.1.2" -e use_proxy=yes -e http_proxy=127.0.0.1:$proxyPort "$url" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}')
        # 获取本地 IP 地址
        local localip=$(requestUrl $url true $proxyPort | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}')
        # 构建查询 URL
        local queryhost="http://ip-api.com/json/${localip}?lang=zh-CN"
        # local result=$(curl --max-time 5 -s $queryhost)
        local result=$(requestUrl $queryhost true $proxyPort)
        local return=$(echo "$result" | jq -r '.country,.regionName,.city,.isp' 2>/dev/null)
    fi
    echo "$localip $return"
}

#检查连通性
checkWebSite(){
    local url=$1;
    if [ -z "$url" ];then
        echo "出现错误了，找管理解决";
        return ;
    fi
    checkHostIsBlock $url
    if [ "$?" == "0" ]; then
        # 检查连通性
        if [ -z "$2" ];then #国内，不走代理，提速。
            if wget --no-hsts -q -O - --timeout=2 --tries=1   --spider "$url"; then
                echo "连通正常"
            else
                echo "连通失败"
            fi
        else
            if wget --no-hsts -q -O - --timeout=2 --tries=1  -e use_proxy=yes -e http_proxy="127.0.0.1:$proxyPort" --spider "$url"; then
                echo "连通正常"
            else
                echo "连通失败"
            fi
        fi
    fi
}


#开启proxy端口了，才检测这些玩意
text20="不检测"
text21="不检测"
text22="不检测"
text23="不检测"
if [ "$merlinclash_mixport_enable" == "1" ]; then
    # 创建临时文件，用于存储返回值
    tempfile1="/tmp/mc_ip_tempfile1_$$.tmp"
    tempfile2="/tmp/mc_ip_tempfile2_$$.tmp"
    tempfile3="/tmp/mc_ip_tempfile3_$$.tmp"
    tempfile4="/tmp/mc_ip_tempfile4_$$.tmp"
    
    # 后台执行函数并将结果写入临时文件
    (checkWebSite "www.google.com.hk" out > "$tempfile4") &
    pid4=$!
    (checkWebSite "www.baidu.com" > "$tempfile3") &
    pid3=$!
    (getIPinfo "ipv4.ip.sb" out > "$tempfile2") &
    pid2=$!
    (getIPinfo "ip.clang.cn" > "$tempfile1") &
    pid1=$!
    #等待所有后台任务完成
    wait $pid1
    wait $pid2
    wait $pid3
    wait $pid4
    
    # 读取临时文件中的返回值并去掉换行符
    text20=$(tr -d '\r\n' < "$tempfile1")
    text21=$(tr -d '\r\n' < "$tempfile2")
    text22=$(tr -d '\r\n' < "$tempfile3")
    text23=$(tr -d '\r\n' < "$tempfile4")
    
    # 删除临时文件
    rm "$tempfile1"
    rm "$tempfile2"
    rm "$tempfile3"
    rm "$tempfile4"
fi

http_response "$text1@$text2@$host@$port@$secret@$text3@$text4@$yamlsel_tmp2@$text8@$text9@$text10@$text11@$text12@$text13@$text14@$text15@$secret@$text16@$text18@$text19@$text20@$text21@$text22@$text23"