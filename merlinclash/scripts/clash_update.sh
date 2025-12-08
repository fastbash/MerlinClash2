#!/bin/sh

# merlinclash script for asuswrt/merlin based router with software center
LOG_FILE=“”

. /koolshare/scripts/clash_base.sh

. /koolshare/scripts/clash_download.sh

# mkdir -p /tmp/upload >/dev/null 2>&1
# alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
main_url="https://raw.githubusercontent.com/fastbash/MerlinClash2/refs/heads/main"


LOCK_FILE=/var/lock/clash_update.lock

set_lock(){
    exec 233>"$LOCK_FILE"
    flock -n 233 || {
        echo_date "更新脚本已经在运行，请稍候再试！" >> "$LOG_FILE"    
        unset_lock
    }
}

unset_lock(){
    flock -u 233
    rm -rf "${LOCK_FILE:?}"
}

# 0.3.4.A64
if [ -z "$merlinclash_version_local" ];then
    echo_date "版本号获取错误！请重新安装"
    exit
fi

update_merclinclash(){
    echo_date "更新过程中请不要刷新本页面或者关闭路由等，不然可能导致问题！"
    echo_date "检查 MC2 插件更新，使用主服务器：github"
    echo_date "检测主服务器在线版本号..."
    
    download_by_mc2 "${main_url}/merlinclash/version" "/tmp/MC2_version"
    merlinclash_version_online=$(cat "/tmp/MC2_version")
    if [ -z "$merlinclash_version_online" ];then
        echo_date "没有检测到主服务器在线版本号，访问github服务器可能有点问题！"
        # echo "XU6J03M6"
        exit_update
    fi

    if [ -z "$merlinclash_version_online" ] || ! echo "$merlinclash_version_online" | grep -qE '[0-9]+\.[0-9]+\.[0-9]+' ;then
        echo_date "在线版本号【${merlinclash_version_online}】错误！请检测你的网络！"
        # echo "XU6J03M6"
        exit_update
    fi
    
    echo_date "检测到主服务器在线版本号：${merlinclash_version_online}"
    dbus set merlinclash_version_online="${merlinclash_version_online}"
    if [ "${merlinclash_version_local%.*}" != "${merlinclash_version_online}" ];then
        echo_date "主服务器在线版本号：${merlinclash_version_online} 和本地版本号：${merlinclash_version_local%.*} 不同！"

        # MC2_0.3.4_ARM64.tar.gz
        PACKAGE="MC2_${merlinclash_version_online}_$(echo "$merlinclash_version_local" | sed 's#\.A#_ARM#g' | awk -F'_' '{print $2}').tar.gz"

        echo_date "获取在线md5内容..."
        download_by_mc2 "${main_url}/package_history/md5sum" "/tmp/MC2_md5sum"
        merlinclash_md5_online=$(grep "$PACKAGE" "/tmp/MC2_md5sum")
        if [ -z "$merlinclash_version_online" ];then
            echo_date ""
            echo_date "在线包 $PACKAGE 没有检测到在线md5内容，访问github服务器可能有点问题！"
            exit_update
        fi

        if [ "$(echo "$merlinclash_md5_online" | awk '{print $2}')" != "$PACKAGE" ] || [ "$(echo "$merlinclash_md5_online" | awk '{print $1}' | wc -c)" != "33" ];then
            echo_date "在线包 $PACKAGE md5内容【${merlinclash_md5_online}】错误！请检测你的网络！"
            exit_update
        fi

        echo_date "开启下载进程，从主服务器上下载更新包..."
        
        if ! download_by_mc2 "${main_url}/package_history/${PACKAGE}" "/tmp/${PACKAGE}";then
            echo_date "下载失败！请检查你的网络！"
            exit_update
        fi

        echo_date "${PACKAGE} 下载成功！"
        # mv MC2_0.3.4_ARM64.tar.gz MC2.tar.gz
        merlinclash_size_download=$(wc -c < "/tmp/${PACKAGE}")
        echo_date "安装包大小：${merlinclash_size_download}"

        merlinclash_md5_download=$(md5sum "/tmp/${PACKAGE}" | awk '{print $1}')
        echo_date "安装包md5校验值：${merlinclash_md5_download}"

        echo_date "安装包在线md5：$(echo "$merlinclash_md5_online" | awk '{print $1}')"
        if [ "${merlinclash_md5_download}" = "$(echo "$merlinclash_md5_online" | awk '{print $1}')" ]; then
            echo_date "更新包md5校验一致！ 开始安装！..."
            install_merlinclash
        else
            echo_date "更新包md5校验不一致！请检测你的网络，或请过一会重试..."
            exit_update
        fi
    else
        echo_date "主服务器在线版本号：${merlinclash_version_online} 和本地版本号：${merlinclash_version_local} 相同！"
        echo_date "退出插件更新!"
    fi

}

exit_update(){
    rm -rf /tmp/MC2*
    return 1
    # exit
}

install_merlinclash(){
    echo_date "开始解压压缩包..."
    rm -rf /tmp/merlinclash*
    tar -zxf "/tmp/${PACKAGE}" -C /tmp/
    chmod a+x /tmp/merlinclash/install.sh
    echo_date "开始安装更新文件..."
    sh /tmp/merlinclash/install.sh
    rm -rf /tmp/merlinclash*
    rm -rf /tmp/MC2*
}

true > "$LOG_FILE"

case $2 in
update)
    http_response "$1"
    update_merclinclash >> "$LOG_FILE" 2>&1
    status_code=$?
    echo BBABBBBC | tee -a "$LOG_FILE"
	exit $status_code
    # echo XU6J03M6 >> "$LOG_FILE"
    ;;
*)
    http_response "$1"
    echo "error: $2" >> "$LOG_FILE"
    echo BBABBBBC | tee -a "$LOG_FILE"
    ;;
esac
