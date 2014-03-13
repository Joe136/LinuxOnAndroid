#!/bin/sh

size=852x480
dpisize=64
displaynum=1
vncport=5902

if [ "$1" = "1920" ]  ; then
  size=1920x1080
  dpisize=96
elif [ "$1" = "1280" ] ; then
  size=1280x1024
  dpisize=96
else
  if [ -n "$1" ] ; then
    size=$1
  fi
  if [ -n "$2" ] ; then
    dpisize=$2
  fi
fi

if [ ! -e /usr/bin/vncserver ]; then
  echo "Installing tightvncserver and LXDE..."
  apt-get -y install tightvncserver lxde lxtask
fi

com='cd ;
vncserver -kill :'"$displaynum"' ;
rm -f /tmp/.X1-lock ;
rm -f /tmp/.X11-unix/X1 ;
vncserver -geometry '"$size :$displaynum -dpi $dpisize -rfbport $vncport"' ;
read ;
vncserver -kill :'"$displaynum"' ;
rm -f /tmp/.X1-lock ;
rm -f /tmp/.X11-unix/X1 ;
'

su -l user -c "$com"
