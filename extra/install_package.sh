#!/bin/bash
# See the file "license.terms" for information on usage and redistribution of
# this file, and for a DISCLAIMER OF ALL WARRANTIES.

#rm *.deb
apt-get download "$1"
if [ "$?" == "0" ]; then
  dpkg -x *.deb ./
  cp -r usr/* ./
  rm -r *.deb usr/
fi

