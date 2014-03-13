#!/system/bin/sh
system="$(readlink -f $0 | tr '/' '\n' | tail -n 2 | head -n 1)"
kit=/mnt/sdcard/$system
img=$kit/$system.img
mnt=/data/local/$system

export bin=/system/bin
export PATH=$bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:$PATH
export TERM=screen
export HOME=/root

if [ -e /data/local/linuxonandroid/config.$system ]; then
  . /data/local/linuxonandroid/config.$system
fi

#Include extra functions
. $kit/scripts/functions.sh

echo "Remounting /system rw ..."
#set -x
if [ $(vercmp $(getBBver busybox) 1.20.0) -gt -1 ] ; then
  mount -o remount,rw -t $(mount | awk ' /\/system\/* /{ print $5 " " $1 " " $3 }') || mount -o remount,rw /system
else
  mount -o remount,rw -t $(mount | awk ' /\/system\/* /{ print $3 " " $1 " " $2 }') || mount -o remount,rw /system
fi

echo "Installing scripts into $bin ..."
#cd $kit/scripts
#for file in *; do
  #cp $file $bin
  #chmod 755 $bin/$file
#done
#cd - > /dev/null
cp -f $kit/scripts/linux $bin/$system
chmod 755 $bin/$system

#Install user config
$bin/$system install $system

echo "Mounting the Linux image ..."
#mount the image
$bin/$system mount

echo "Customizing the image ..."
echo "nameserver 8.8.8.8" > $mnt/etc/resolv.conf
echo "nameserver 8.8.4.4" >> $mnt/etc/resolv.conf
#echo "Setting localhost on /etc/hosts "
#echo "127.0.0.1 localhost" > $mnt/etc/hosts

echo "  Installing root-scripts ..."
#install custom root-scripts in $mnt/root/scripts
if [ ! -d $mnt/root/scripts ]; then
  mkdir $mnt/root/scripts
fi
chmod 755 $mnt/root/scripts
cp -f $kit/root-scripts/* $mnt/root/scripts
chmod 755 $mnt/root/scripts/*

echo "  Installing user-scripts"
if [ -e $mnt/root/.bashrc ] && [ ! -e $mnt/root/.bashrc.bak ]; then
  mv $mnt/root/.bashrc $mnt/root/.bashrc.bak
fi
cp -f $kit/scripts/.bashrc $mnt/root/
echo -n $system > $mnt/etc/debian_chroot

echo "  Installing bin-scripts ..."
cd $kit/bin-scripts
for file in *; do
  cp -f $file $mnt/usr/bin
  chmod 755 $mnt/usr/bin/$file
done
cd - > /dev/null

if [ ! -e /data/local/linuxonandroid/config.default ]; then
  echo "Creating config files ..."
  mkdir -p /data/local/linuxonandroid
  echo "sdcard=/mnt/sdcard" > /data/local/linuxonandroid/config.default
  echo "#kit=/mnt/sdcard/linux" >> /data/local/linuxonandroid/config.default
  echo "#img=$kit/linux.img" >> /data/local/linuxonandroid/config.default
  echo "#mnt=/data/local/linux" >> /data/local/linuxonandroid/config.default
  echo "export TERM=screen" >> /data/local/linuxonandroid/config.default
  echo "loopno=254" >> /data/local/linuxonandroid/config.default
fi

echo "Setting Root Password ..."
echo "Set new root password? [N/y]"
read accept
if [ "$accept" = "y" ] || [ "$accept" = "Y" ]; then
  $bin/$system passwd root
fi

echo "Install finished, Have Fun"
