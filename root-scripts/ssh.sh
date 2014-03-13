#!/bin/sh
export PATH='/bin:/sbin:/usr/bin:/usr/sbin'
export HOME=/root
export USER=root

#rm -rf /tmp/*
#(cd dev; /sbin/MAKEDEV ptmx)

#if [ ! -e /etc/init.d/ssh ]; then
#  echo "Installing openssh-server..."
#  apt-get -y install openssh-server
#fi

/etc/rc.d/sshd stop

if [ ! "$1" = "stop" ]; then
  /etc/rc.d/sshd start
fi
