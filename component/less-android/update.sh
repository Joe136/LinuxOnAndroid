#!/bin/bash

path="less-458"
co='wget -N http://www.greenwoodsoftware.com/less/less-458.tar.gz && tar -xzf less-458.tar.gz'
ud=':'


if [ ! -d "$path" ] || ! mountpoint -q "$path"; then
   mkdir -p "$path"
   mount -t ramfs ramfs "./$path"
   init=true
fi


if [ "$1" == "init" ] || [ "$init" == "true" ]; then
   eval $co
   generate=true
fi

cd "$path"

[[ "$1" == "update"  ]] && eval $ud && generate=true && clean=true

if [ "$1" == "autogen" ] || [ "$generate" == "true" ] || [ ! -e "configure" ]; then
   ./autogen.sh
   clean=true
fi

if [ "$1" == "clean" ] || [ "$clean" == "true" ]; then
   make clean
fi

./configure --prefix=/system/usr --bindir=/system/xbin --sysconfdir=/system/etc --enable-unicode --enable-openvz --enable-cgroup --enable-taskstats && \
\
make LIBS="-static-libgcc -static -Wl,-Bstatic -ldl -ltinfo -lncursesw -lgpm -ltermcap -lm" && \
\
make install prefix=/proc/1/root/system/usr bindir=/proc/1/root/system/xbin sysconfdir=/proc/1/root/system/etc

