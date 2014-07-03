#!/bin/bash


if [ ! -d "nano" ]; then
   mkdir -p nano
   mount -t ramfs ramfs ./nano
   init=true
fi


if [ "$1" == "init" ] || [ "$init" == "true" ]; then
   svn co svn://svn.savannah.gnu.org/nano/trunk/nano ./nano
   generate=true
   patch=true
fi

cd nano

[[ "$1" == "update"  ]] && svn update && generate=true

if [ "$1" == "patch" ] || [ "$patch" == "true" ]; then
   patch -R -i ../src_Makefile_am.patch src/Makefile.am
fi

if [ "$1" == "autogen" ] || [ "$generate" == "true" ]; then
   ./autogen.sh
fi

./configure --sysconfdir=/etc --enable-utf8 --disable-mouse --prefix=/system/usr --bindir=/system/xbin --sysconfdir=/system/etc && \
\
make && \
\
make install prefix=/proc/1/root/system/usr bindir=/proc/1/root/system/xbin sysconfdir=/proc/1/root/system/etc

