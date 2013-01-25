#!/bin/bash
# See the file "license.terms" for information on usage and redistribution of
# this file, and for a DISCLAIMER OF ALL WARRANTIES.

if [ ! -e "/sbin/ifup" ]; then
  echo "Installing ifupdown programs..."
  apt-get -y install ifupdown
fi

#service networking start

if [ "$2" == "up" ]; then
  /sbin/ifup "$1"
elif [ "$2" == "down" ]; then
  /sbin/ifdown "$1"
fi
