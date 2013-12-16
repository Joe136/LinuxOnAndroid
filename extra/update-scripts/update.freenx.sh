#!/bin/bash
# See the file "license.terms" for information on usage and redistribution of
# this file, and for a DISCLAIMER OF ALL WARRANTIES.

false > /mnt/ramdisk/nxserver.log
false > /mnt/ramdisk/nxserver.err.log

if [ "$(cat nxcomp.state 2> /dev/null)" != "done" ]; then
	echo "----------nxcomp"
	cd nxcomp
	./configure --prefix=/usr/local/NX >> /mnt/ramdisk/nxserver.log 2>> /mnt/ramdisk/nxserver.err.log
	[[ "$?" != "0" ]] && cd .. && exit 1
	make >> /mnt/ramdisk/nxserver.log 2>> /mnt/ramdisk/nxserver.err.log
	[[ "$?" != "0" ]] && cd .. && exit 1
	cd ..
	echo -n "done" > nxcomp.state
fi

if [ "$(cat nxcompext.state 2> /dev/null)" != "done" ]; then
	echo "----------nxcompext"
	cd nxcompext
	./configure --prefix=/usr/local/NX --x-includes=../nx-X11/lib >> /mnt/ramdisk/nxserver.log 2>> /mnt/ramdisk/nxserver.err.log
	[[ "$?" != "0" ]] && cd .. && exit 1
	make >> /mnt/ramdisk/nxserver.log 2>> /mnt/ramdisk/nxserver.err.log
	[[ "$?" != "0" ]] && cd .. && exit 1
	cd ..
	echo -n "done" > nxcompext.state
fi

if [ "$(cat nxcompsh.state 2> /dev/null)" != "done" ]; then
	echo "----------nxcompsh"
	cd nxcompsh
	./configure --prefix=/usr/local/NX >> /mnt/ramdisk/nxserver.log 2>> /mnt/ramdisk/nxserver.err.log
	[[ "$?" != "0" ]] && cd .. && exit 1
	make >> /mnt/ramdisk/nxserver.log 2>> /mnt/ramdisk/nxserver.err.log
	[[ "$?" != "0" ]] && cd .. && exit 1
	cd ..
	echo -n "done" > nxcompsh.state
fi

if [ "$(cat nxcompshad.state 2> /dev/null)" != "done" ]; then
	echo "----------nxcompshad"
	cd nxcompshad
	./configure --prefix=/usr/local/NX >> /mnt/ramdisk/nxserver.log 2>> /mnt/ramdisk/nxserver.err.log
	[[ "$?" != "0" ]] && cd .. && exit 1
	make >> /mnt/ramdisk/nxserver.log 2>> /mnt/ramdisk/nxserver.err.log
	[[ "$?" != "0" ]] && cd .. && exit 1
	cd ..
	echo -n "done" > nxcompshad.state
fi

if [ "$(cat nxkill.state 2> /dev/null)" != "done" ]; then
	echo "----------nxkill"
	cd nxkill
	./configure --prefix=/usr/local/NX >> /mnt/ramdisk/nxserver.log 2>> /mnt/ramdisk/nxserver.err.log
	[[ "$?" != "0" ]] && cd .. && exit 1
	make >> /mnt/ramdisk/nxserver.log 2>> /mnt/ramdisk/nxserver.err.log
	[[ "$?" != "0" ]] && cd .. && exit 1
	cd ..
	echo -n "done" > nxkill.state
fi

if [ "$(cat nxproxy.state 2> /dev/null)" != "done" ]; then
	echo "----------nxproxy"
	cd nxproxy
	./configure --prefix=/usr/local/NX >> /mnt/ramdisk/nxserver.log 2>> /mnt/ramdisk/nxserver.err.log
	[[ "$?" != "0" ]] && cd .. && exit 1
	make >> /mnt/ramdisk/nxserver.log 2>> /mnt/ramdisk/nxserver.err.log
	[[ "$?" != "0" ]] && cd .. && exit 1
	cd ..
	echo -n "done" > nxproxy.state
fi

if [ "$(cat nxsensor.state 2> /dev/null)" != "done" ]; then
	echo "----------nxsensor"
	cd nxsensor-3.5.0-1
	./configure --prefix=/usr/local/NX >> /mnt/ramdisk/nxserver.log 2>> /mnt/ramdisk/nxserver.err.log
	[[ "$?" != "0" ]] && cd .. && exit 1
	make >> /mnt/ramdisk/nxserver.log 2>> /mnt/ramdisk/nxserver.err.log
	[[ "$?" != "0" ]] && cd .. && exit 1
	cd ..
	echo -n "done" > nxsensor.state
fi

if [ "$(cat nxservice.state 2> /dev/null)" != "done" ]; then
	echo "----------nxservice"
	cd nxservice
	./configure --prefix=/usr/local/NX >> /mnt/ramdisk/nxserver.log 2>> /mnt/ramdisk/nxserver.err.log
	[[ "$?" != "0" ]] && cd .. && exit 1
	make >> /mnt/ramdisk/nxserver.log 2>> /mnt/ramdisk/nxserver.err.log
	[[ "$?" != "0" ]] && cd .. && exit 1
	cd ..
	echo -n "done" > nxservice.state
fi

if [ "$(cat nxspool.state 2> /dev/null)" != "done" ]; then
	echo "----------nxspool"
	cd nxspool-3.5.0-1/source
	./configure --prefix=/usr/local/NX >> /mnt/ramdisk/nxserver.log 2>> /mnt/ramdisk/nxserver.err.log
	[[ "$?" != "0" ]] && cd .. && exit 1
	make >> /mnt/ramdisk/nxserver.log 2>> /mnt/ramdisk/nxserver.err.log
	[[ "$?" != "0" ]] && cd .. && exit 1
	cd ..
	echo -n "done" > nxspool.state
fi

if [ "$(cat nxssh.state 2> /dev/null)" != "done" ]; then
	echo "----------nxssh"
	cd nxssh
	./configure --prefix=/usr/local/NX >> /mnt/ramdisk/nxserver.log 2>> /mnt/ramdisk/nxserver.err.log
	[[ "$?" != "0" ]] && cd .. && exit 1
	make >> /mnt/ramdisk/nxserver.log 2>> /mnt/ramdisk/nxserver.err.log
	[[ "$?" != "0" ]] && cd .. && exit 1
	cd ..
	echo -n "done" > nxssh.state
fi

if [ "$(cat nxuexec.state 2> /dev/null)" != "done" ]; then
	echo "----------nxuexec"
	cd nxuexec
	./configure --prefix=/usr/local/NX >> /mnt/ramdisk/nxserver.log 2>> /mnt/ramdisk/nxserver.err.log
	[[ "$?" != "0" ]] && cd .. && exit 1
	make >> /mnt/ramdisk/nxserver.log 2>> /mnt/ramdisk/nxserver.err.log
	[[ "$?" != "0" ]] && cd .. && exit 1
	cd ..
	echo -n "done" > nxuexec.state
fi

if [ "$(cat nx-X11.state 2> /dev/null)" != "done" ]; then
	echo "----------nx-X11"
	cd nx-X11
	make World prefix=/usr/local/NX >> /mnt/ramdisk/nxserver.log 2>> /mnt/ramdisk/nxserver.err.log
	[[ "$?" != "0" ]] && cd .. && exit 1
	cd ..
	echo -n "done" > nx-X11.state
fi

