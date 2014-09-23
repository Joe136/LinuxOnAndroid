#!/bin/bash

path=nano
co='svn co svn://svn.savannah.gnu.org/nano/trunk/nano ./'"$path"
ud='svn update'


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

./configure --enable-utf8 --prefix=/system/usr --bindir=/system/xbin --sysconfdir=/system/etc && \
\
make LIBS="-static -Wl,-Bstatic -ldl -ltinfo -lncursesw -lgpm -ltermcap" && \
\
make install prefix=/proc/1/root/system/usr bindir=/proc/1/root/system/xbin sysconfdir=/proc/1/root/system/etc

