#!/bin/sh

. /koolshare/scripts/base.sh

eval "$(dbus export merlinclash_)"

get(){
    a="$(dbus get "$1")"
    a="$(dbus get "$1")"
    echo "$a" | tr -d '\r'
}

set_lock(){
    exec 233>"$LOCK_FILE"
    flock -n 233 || {
        echo_date "订阅脚本已经在运行，请稍候再试！" >> "$LOG_FILE"    
        unset_lock
    }
}

unset_lock(){
    flock -u 233
    rm -rf "${LOCK_FILE:?}"
}

alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'

NEW_PATH=$(echo $PATH|tr ':' '\n'|sed '/opt/d;/mmc/d'|awk '!a[$0]++'|tr '\n' ':'|sed '$ s/:$//')
export PATH=${NEW_PATH}

LOG_FILE="/tmp/upload/merlinclash_log.txt"

run(){
    env -i PATH=${PATH} "$@"
}

# RT-AX86U_PRO
model=$(nvram get model | tr -d '\r')

# 1.9.49
softcenter=$(dbus get softcenter_version | tr -d '\r')
# softcenter/1.9.49
softcenter_agent="softcenter/${softcenter}"

# 0.3.4.A64
merlinclash_version_local=$(dbus get merlinclash_version_local)
# MerlinClash2/0.3.4.A64
mc2_agent="$(get softcenter_module_merlinclash_title | sed 's# ##g')/${merlinclash_version_local}"

# Meta/v1.19.3
clash_agent="$(get merlinclash_clash_version | sed 's# #/#g')"

# MerlinClash2/0.3.4.A64 softcenter/1.9.49 RT-AX86U_PRO
MC2_agent="${mc2_agent} ${softcenter_agent} ${model}"

decode_url_link(){
    local link=$1
    local len=$(echo $link | wc -L)
    local mod4=$(($len%4))
    b64=$(b)
    echo_date "b64=$b64" >> LOG_FILE
    if [ "$mod4" -gt "0" ]; then
        local var="===="
        local newlink=${link}${var:$mod4}
        echo -n "$newlink" | sed 's/-/+/g; s/_/\//g' | $b64 -d 2>/dev/null
    else
        echo -n "$link" | sed 's/-/+/g; s/_/\//g' | $b64 -d 2>/dev/null
    fi
}


b(){
    if [ -f "/koolshare/bin/base64_decode" ]; then #HND有这个
        base=base64_decode
        echo $base
    elif [ -f "/bin/base64" ]; then #HND是这个
        base=base64
        echo $base
    elif [ -f "/koolshare/bin/base64" ]; then #网件R7K是这个
        base=base64
        echo $base
    elif [ -f "/sbin/base64" ]; then
        base=base64
        echo $base
    else
        echo_date "【错误】固件缺少base64decode文件，无法正常使用，直接退出" >> $LOG_FILE
        echo_date "解决办法请查看 MerlinClash Wiki" >> $LOG_FILE
        echo BBABBBBC >> $LOG_FILE
        exit 1
    fi
}
