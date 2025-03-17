#!/bin/bash
DIR="$(cd "$(dirname "$0")";pwd)"

cd "$DIR"

for dir in package package_history;do
    if [ ! -d "$dir" ];then
        mkdir -p "$dir"
        touch "$dir/md5sum"
    fi
done

version=$(cat "$DIR/merlinclash/version")

if [ -z "$version" ];then
    echo "$DIR/merlinclash/version is empty!"
    exit 1
fi

tmpDIR="${DIR:?}/_tmp"

for bintype in 32 64;do
    rm -rf "${tmpDIR:?}"
    mkdir -p "$tmpDIR"
    \cp -rf "${DIR}/merlinclash" "${tmpDIR}/"
    cd "${tmpDIR}/merlinclash"
    find -name 'bin*' -type d | grep -v $bintype | xargs rm -rf
    find -name '.valid_*' -type f | grep -v $bintype | xargs rm -rf
    mv ".valid_$bintype" .valid
    fileName="${DIR}/package/MC2_ARM${bintype}.tar.gz"
    versionName="${DIR}/package_history/MC2_${version}_ARM${bintype}.tar.gz"
    tar czf "$fileName" -C "${tmpDIR}" merlinclash
    sed -i "/${fileName##*/}/d" "${DIR}/package/md5sum"
    echo "$(md5sum "$fileName" | awk '{print $1}') ${fileName##*/}" >> "${DIR}/package/md5sum"
    \cp "$fileName" "${versionName}"
    sed -i "/${versionName##*/}/d" "${DIR}/package_history/md5sum"
    echo "$(md5sum "$versionName" | awk '{print $1}') ${versionName##*/}" >> "${DIR}/package_history/md5sum"
    rm -rf "${tmpDIR:?}"
done