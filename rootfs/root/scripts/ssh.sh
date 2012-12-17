#!/bin/sh
export PATH='/bin:/sbin:/usr/bin:/usr/sbin'
export HOME=/root
export USER=root

#rm -rf /tmp/*
#(cd dev; /sbin/MAKEDEV ptmx)

if [ ! -e /etc/init.d/ssh ]; then
  echo "Installing openssh-server..."
  apt-get -y install openssh-server
fi

/etc/init.d/ssh stop

if [ ! "$1" = "stop" ]; then
  /etc/init.d/ssh start
  echo "Fingerprint:"
  ssh-keygen -l -f /etc/ssh/ssh_host_rsa_key.pub
  ssh-keygen -l -f /etc/ssh/ssh_host_dsa_key.pub
  ssh-keygen -l -f /etc/ssh/ssh_host_ecdsa_key.pub
fi
