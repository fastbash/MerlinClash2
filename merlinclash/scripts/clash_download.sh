#!/bin/sh

# . /koolshare/scripts/clash_base.sh

LOCK_FILE=/var/lock/merlinclash_download.lock

download_by_mc2(){
    if [ -z "$1" ] || [ -z "$2" ];then
        return 1
    fi
    if download_by_curl "$1" "$2";then
        return 0
    else
        if download_by_wget "$1" "$2";then
            return 0
        fi
    fi
    return 1
}

download_by_wget(){
    _url="$1"
    _url_file_tmp="$2"
    
    if [ -f "${_url_file_tmp:?}" ];then
        rm -f > "${_url_file_tmp:?}" 2>/dev/null
    fi
    if [ ! -d "${_url_file_tmp%/*}" ];then
        echo_date "⚠️临时文件【${_url_file_tmp}】所在文件夹【${_url_file_tmp%/*}】异常！"
        return 1
    fi
    if ! touch "${_url_file_tmp:?}";then
        echo_date "⚠️临时文件【${_url_file_tmp}】创建失败！"
        return 1
    fi

    wget_bin="$(which wget)"
    wget_agent="$wget_bin/$($wget_bin --version | head -n1 | awk '{print $3}')"
    download_agent="${wget_agent} ${MC2_agent}"

    echo_date "ℹ️使用 $wget_bin"
    echo_date "下载地址： ${_url}"
    echo_date "目标文件： ${_url_file_tmp}"
    
    _OPT="-4 -t 1 -T 10 --dns-timeout=5 -q"
    _OPT="-4 -t 1 -T 10 --dns-timeout=5"

    if echo "$1" | grep -qE "^https"; then
        EXT_OPT="--no-check-certificate"
    else
        EXT_OPT=""
    fi
    
    _url_encode=$(echo "$1" | sed 's/[[:space:]]/%20/g')
    
    _url_domain="$(echo "$_url" | sed -E 's#^[a-zA-Z]+://([^/:]+).*#\1#')"

    if netstat -nlp 2>/dev/null|grep -w "3333"|grep -Eoq "ss-local|sslocal|v2ray|xray|naive|tuic|clash";then

        echo_date "⬇️尝试通过✈️代理下载..."
        export http_proxy=127.0.0.1:3333
        export https_proxy=127.0.0.1:3333

        echo_date "1️⃣第一次尝试下载..."
        $wget_bin ${_OPT} ${EXT_OPT} -U "$download_agent" "${_url_encode}" -O "${_url_file_tmp}" >> "$LOG_FILE" 2>&1
        if [ $? = 0 ] && [ "$(wc -c < "${_url_file_tmp}")" -gt 0 ];then
            unset http_proxy https_proxy
            return 0
        fi

        echo_date "2️⃣第二次尝试下载..."
        $wget_bin ${_OPT} ${EXT_OPT} -U "$download_agent" "${_url_encode}" -O "${_url_file_tmp}" >> "$LOG_FILE" 2>&1
        if [ $? = 0 ] && [ "$(wc -c < "${_url_file_tmp}")" -gt 0 ];then
            unset http_proxy https_proxy
            return 0
        fi
    fi

    echo_date "⬇️使用常规网络下载..."
    unset http_proxy https_proxy
    
    echo_date "1️⃣第一次尝试下载..."
    $wget_bin ${_OPT} ${EXT_OPT} -U "$download_agent" "${_url_encode}" -O  "${_url_file_tmp}" >> "$LOG_FILE" 2>&1
    if [ $? = 0 ] && [ "$(wc -c < "${_url_file_tmp}")" -gt 0 ];then
        return 0
    fi

    echo_date "2️⃣第二次尝试下载..."
    $wget_bin ${_OPT} ${EXT_OPT} -U "$download_agent" "${_url_encode}" -O  "${_url_file_tmp}" >> "$LOG_FILE" 2>&1
    if [ $? = 0 ] && [ "$(wc -c < "${_url_file_tmp}")" -gt 0 ];then
        return 0
    fi

    echo_date "⚠️下载失败！请检查路由器网络！"
    return 1
}


download_by_curl(){
    _url="$1"
    _url_file_tmp="$2"

    if [ -f "${_url_file_tmp:?}" ];then
        rm -f > "${_url_file_tmp:?}" 2>/dev/null
    fi
    if [ ! -d "${_url_file_tmp%/*}" ];then
        echo_date "⚠️临时文件【${_url_file_tmp}】所在文件夹【${_url_file_tmp%/*}】异常！"
        return 1
    fi
    if ! touch "${_url_file_tmp:?}";then
        echo_date "⚠️临时文件【${_url_file_tmp}】创建失败！"
        return 1
    fi

    CURL_BIN="$(which curl)"
    CURL_VER="$CURL_BIN/$($CURL_BIN --version | head -n1 | awk '{print $2}')"
    UA_STRING="${CURL_VER} ${MC2_agent}"

    echo_date "ℹ️使用 $CURL_BIN "
    echo_date "下载地址： ${_url}"
    echo_date "目标文件： ${_url_file_tmp}"

    _curl_arg="-4SkL"

    _url_encode="$(echo "$_url" | sed 's/[[:space:]]/%20/g')"

    _url_domain="$(echo "$_url" | sed -E 's#^[a-zA-Z]+://([^/:]+).*#\1#')"

    echo_date "⬇️使用常规网络下载..."
    
    echo_date "1️⃣使第一次尝试下载..."
    $CURL_BIN ${_curl_arg} -H "$UA_STRING" --connect-timeout 6 "${_url_encode}" > "${_url_file_tmp}"
    if [ $? = 0 ] && [ "$(wc -c < "${_url_file_tmp}")" -gt 0 ];then
        return 0
    fi
    
    echo_date "2️⃣第二次尝试下载..."
    $CURL_BIN ${_curl_arg} -H "$UA_STRING" --connect-timeout 10 "${_url_encode}" > "${_url_file_tmp}"
    if [ $? = 0 ] && [ "$(wc -c < "${_url_file_tmp}")" -gt 0 ];then
        return 0
    fi

    echo_date "⚠️下载失败！"
    return 1
}
