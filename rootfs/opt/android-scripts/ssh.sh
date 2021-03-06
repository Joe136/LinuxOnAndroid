#!/bin/bash
# See the file "license.terms" for information on usage and redistribution of
# this file, and for a DISCLAIMER OF ALL WARRANTIES.

export PATH='/bin:/sbin:/usr/bin:/usr/sbin'
export HOME=/root
export USER=root

#rm -rf /tmp/*
#(cd dev; /sbin/MAKEDEV ptmx)

if [ ! -e /etc/init.d/ssh ]; then
  echo "Installing openssh-server..."
  apt-get -y install openssh-server
fi

/etc/init.d/ssh stop "-p $1"

if [ ! "$2" = "stop" ]; then
  /etc/init.d/ssh start "-p $1"
  echo "Fingerprint:"
  ssh-keygen -l -f /etc/ssh/ssh_host_rsa_key.pub
  ssh-keygen -l -f /etc/ssh/ssh_host_dsa_key.pub
  ssh-keygen -l -f /etc/ssh/ssh_host_ecdsa_key.pub
fi
