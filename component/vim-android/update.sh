#!/bin/bash

path=vim
co='hg clone https://code.google.com/p/vim ./'"$path"
ud='hg update'


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

./configure --enable-multibyte --enable-largefile --enable-acl --enable-nls \
            --disable-darwin --without-x --disable-fontset --disable-gui --disable-gtktest \
            --prefix=/system/usr --bindir=/system/xbin --sysconfdir=/system/etc && \
\
make LIBS="-static -Wl,-Bstatic -ldl -lm -ltinfo -lgpm" && \
\
make install prefix=/proc/1/root/system/usr BINDIR=/proc/1/root/system/xbin sysconfdir=/proc/1/root/system/etc

