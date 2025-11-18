#!/bin/sh

LOCK_FILE=/var/lock/merlinclash_regular_update.lock

. /koolshare/scripts/clash_base.sh

Regularlog=/tmp/upload/merlinclash_regular.log

yamlname="$(get merlinclash_yamlsel)"
subscribeplan="$(get merlinclash_subscribeplan)"
yamlsel="$(get merlinclash_yamlsel)"
#配置文件路径
yamlpath="/koolshare/merlinclash/yaml_use/$yamlname.yaml"

filename="/koolshare/merlinclash/yaml_bak/subscription.txt"
mcflag="$(get merlinclash_flag)"
mcenable="$(get merlinclash_enable)"

cd . > "${Regularlog:?}"

echo_date "定时订阅进程启动" >> "$Regularlog"
if [ ! -f "$filename" ];then
    touch "$filename"
    echo_date "丢失订阅文件 $filename" >> "$Regularlog"
    merlinclash_links="$(get merlinclash_links)"
    if [ -n "$merlinclash_links" ];then
        merlinclash_links="$(decode_url_link "$merlinclash_links")"
        echo_date "使用当前订阅链接 $merlinclash_links 订阅" >> "$Regularlog"
        echo "\"name\":\"$(get merlinclash_yamlsel).yaml\",\"link\":\"$merlinclash_links\",\"type\":\"1\",\"use\":\"0\"" | tee "$filename"
    fi
fi
if [ -z "$(cat "$filename")" ];then
    echo_date "订阅链接获取错误！退出订阅" >> "$Regularlog"
    exit
fi
if [ "$subscribeplan" = "all" ]; then
    result_code=1
    while read -r line;do
        # $line
        # "name":"subname.yaml","link":"https://...","type":"1","use":"0"
        sleep 1
        # subname.yaml
        upname=$(echo "$line" |grep -o "\"name\".*"|awk -F\" '{print $4}')
        # 名字去除.yaml后缀 subname
        upname=$(echo "$upname" | awk -F"." '{print $1}')
        # link https://..
        merlinc_link=$(echo "$line" | grep -o "\"link\".*"|awk -F\" '{print $4}')
        # type:1
        subscription_type=$(echo "$line" | grep -o "\"type\".*"|awk -F\" '{print $4}')
        # use:0
        # use=$(echo "$line" | grep -o "\"use\".*"|awk -F\" '{print $4}')
        if [ -z "$upname" ] || [ -z "$merlinc_link" ] || [ -z "$subscription_type" ];then
            echo_date "订阅文件格式异常，请重新设置订阅！"  >> "$Regularlog"
        fi

        # null
        clashtarget=$(echo "$line" | grep -o "\"clashtarget\".*"|awk -F\" '{print $4}')
        emoji=$(echo "$line" | grep -o "\"emoji\".*"|awk -F\" '{print $4}')
        udp=$(echo "$line" | grep -o "\"udp\".*"|awk -F\" '{print $4}')
        xudp=$(echo "$line" | grep -o "\"xudp\".*"|awk -F\" '{print $4}')
        appendtype=$(echo "$line" | grep -o "\"appendtype\".*"|awk -F\" '{print $4}')
        sort=$(echo "$line" | grep -o "\"sort\".*"|awk -F\" '{print $4}')
        fnd=$(echo "$line" | grep -o "\"fnd\".*"|awk -F\" '{print $4}')
        include=$(echo "$line" | grep -o "\"include\".*"|awk -F\" '{print $4}')
        exclude=$(echo "$line" | grep -o "\"exclude\".*"|awk -F\" '{print $4}')
        scv=$(echo "$line" | grep -o "\"scv\".*"|awk -F\" '{print $4}')
        tfo=$(echo "$line" | grep -o "\"tfo\".*"|awk -F\" '{print $4}')
        acltype=$(echo "$line" | grep -o "\"acltype\".*"|awk -F\" '{print $4}')

        if [ "$subscription_type" = "3" ] || [ "$subscription_type" = "5" ] || [ "$subscription_type" = "8" ]; then
            addr=$(echo "$line" | grep -o "\"addr\".*"|awk -F\" '{print $4}')
            #echo_date "addr=$addr" >> "$Regularlog"
        elif [ "$subscription_type" = "4" ] || [ "$subscription_type" = "6" ]; then
            customrule=$(echo "$line" | grep -o "\"customrule\".*"|awk -F\" '{print $4}')
        elif [ "$subscription_type" = "7" ]; then
            customrule=$(echo "$line" | grep -o "\"customrule\".*"|awk -F\" '{print $4}')
            urlinilink=$(echo "$line" | grep -o "\"url\".*"|awk -F\" '{print $4}')
        elif [ "$subscription_type" = "8" ]; then
            urlinilink=$(echo "$line" | grep -o "\"url\".*"|awk -F\" '{print $4}')
        else
            # 参数超范围？
            echo_date "" >> "$Regularlog"
        fi

        #echo_date "name=$name" >> "$Regularlog"
        #echo_date "link=$link" >> "$Regularlog"
        #echo_date "type=$type" >> "$Regularlog"
        #echo_date "use=$use" >> "$Regularlog"
        #echo_date "ruletype=$ruletype" >> "$Regularlog"
        #echo_date "acltype=$acltype" >> "$Regularlog"
        #echo_date "clashtarget=$clashtarget" >> "$Regularlog"
        #echo_date "emoji=$emoji" >> "$Regularlog"
        #echo_date "udp=$udp" >> "$Regularlog"
        #echo_date "appendtype=$appendtype" >> "$Regularlog"
        #echo_date "sort=$sort" >> "$Regularlog"
        #echo_date "fnd=$fnd" >> "$Regularlog"
        #echo_date "include=$include" >> "$Regularlog"
        #echo_date "exclude=$exclude" >> "$Regularlog"
        #echo_date "scv=$scv" >> "$Regularlog"
        #echo_date "tfo=$tfo" >> "$Regularlog"
        #echo_date "acltype=$acltype" >> "$Regularlog"
        #echo_date "customrule=$customrule" >> "$Regularlog"
        #echo_date "" >> "$Regularlog"
        #根据subscription_type类型调用不同订阅方法
        #subscription_type：1:Clash-Yaml配置下载 2:HND_小白订阅 3：384_小白订阅 4：HND_SC订阅 5:384_ACL订阅 
        #subscription_type：6：HND_自定订阅 7：HND_远程订阅 8:384_远程订阅
        case $subscription_type in
        1)
            # 1:Clash-Yaml配置下载
            # echo "启动方案1"
            # upname 1 https://...
            echo_date "Clash-Yaml配置下载" >> "$Regularlog"
            sh /koolshare/scripts/clash_online_yaml.sh "$upname" "$subscription_type" "$merlinc_link" >> "$Regularlog" 2>&1
            ;;
        2)    
            #HND_小白订阅
            # echo "启动方案2"
            #名字带前缀，先去除前缀
            #name=$(echo $name | awk -F"_" '{print $2}')
            #从左向右截取第一个 _ 后的字符串
            echo_date "本地SC_小白订阅定时更新" >> "$Regularlog"
            upname="${upname#*_}"
            sh /koolshare/scripts/clash_online_yaml_2.sh "$upname" "$subscription_type" "$merlinc_link"
            ;;
        3)    
            #384_小白订阅
            echo_date "ACL4SSR_小白订阅定时更新" >> "$Regularlog"
            #名字带前缀，先去除前缀
            #name=$(echo $name | awk -F"_" '{print $2}')
            #从左向右截取第一个 _ 后的字符串
            upname="${upname#*_}"
            sh /koolshare/scripts/clash_online_yaml_2.sh "$upname" "$subscription_type" "$merlinc_link" "$addr"
            ;;
        4)    
            #HND_SC订阅
            #名字带前缀，先去除前缀
            echo_date "SubConverter本地转换定时更新" >> "$Regularlog"
            #name=$(echo $name | awk -F"_" '{print $2}')
            #从左向右截取第一个 _ 后的字符串
            upname="${upname#*_}"
            sh /koolshare/scripts/clash_online_yaml4.sh "$upname" "$subscription_type" "$merlinc_link" "$clashtarget" "$acltype" "$emoji" "$udp" "$appendtype" "$sort" "$fnd" "$include" "$exclude" "$scv" "$tfo" "$customrule" "$xudp"
            ;;
        5)    
            #384_ACL订阅
            echo_date "ACL4SSR转换定时更新" >> "$Regularlog"
            upname="${upname#*_}"
            sh /koolshare/scripts/clash_online_yaml4.sh "$upname" "$subscription_type" "$merlinc_link" "$clashtarget" "$acltype" "$emoji" "$udp" "$appendtype" "$sort" "$fnd" "$include" "$exclude" "$scv" "$tfo" "$addr" "$xudp"
            ;;
        6)    
            #HND_自定订阅
            #名字带前缀，先去除前缀
            echo_date "本地SC自定订阅定时更新" >> "$Regularlog"
            #name=$(echo $name | awk -F"_" '{print $2}')
            #从左向右截取第一个 _ 后的字符串
            upname="${upname#*_}"
            sh /koolshare/scripts/clash_online_yaml4.sh "$upname" "$subscription_type" "$merlinc_link" "$clashtarget" "$acltype" "$emoji" "$udp" "$appendtype" "$sort" "$fnd" "$include" "$exclude" "$scv" "$tfo" "$customrule" "$xudp"
            ;;
        7)   
            #HND_远程订阅
            #名字带前缀，先去除前缀
            echo_date "本地SC远程订阅定时更新" >> "$Regularlog"
            #name=$(echo $name | awk -F"_" '{print $2}')
            #从左向右截取第一个 _ 后的字符串
            upname="${upname#*_}"
            sh /koolshare/scripts/clash_online_yaml4.sh "$upname" "$subscription_type" "$merlinc_link" "$clashtarget" "$acltype" "$emoji" "$udp" "$appendtype" "$sort" "$fnd" "$include" "$exclude" "$scv" "$tfo" "$customrule" "$xudp" "$urlinilink"
            ;;
        8)    
            #ACL4SSR远程订阅
            #名字带前缀，先去除前缀
            echo_date "ACL4SSR远程订阅定时更新" >> "$Regularlog"
            #name=$(echo $name | awk -F"_" '{print $2}')
            #从左向右截取第一个 _ 后的字符串
            upname="${upname#*_}"
            sh /koolshare/scripts/clash_online_yaml4.sh "$upname" "$subscription_type" "$merlinc_link" "$clashtarget" "$acltype" "$emoji" "$udp" "$appendtype" "$sort" "$fnd" "$include" "$exclude" "$scv" "$tfo" "$addr" "$xudp" "$urlinilink"
            ;;    
        esac
        # 只要当前使用的配置订阅成功，才重启插件
        if [ $? = 0 ] && [ "$upname" = "$(get merlinclash_yamlsel)" ];then
            result_code=0
        fi
        sleep 3
    done < "$filename"
    if [ "$mcenable" = "1" ] && [ "$result_code" = "0" ];then
        #订阅后重启clash
        sleep 3
        echo_date "订阅配置成功后重启clash" >> "$Regularlog"
        sh /koolshare/merlinclash/clashconfig.sh restart
    fi
else
    sh /koolshare/scripts/clash_updateyamlsel.sh 0 1 "$yamlsel" >> "$Regularlog" 2>&1
    #订阅后重启clash
    sleep 5
    echo_date "订阅后重启clash"  >> "$Regularlog" 2>&1
    sh /koolshare/merlinclash/clashconfig.sh restart
fi

