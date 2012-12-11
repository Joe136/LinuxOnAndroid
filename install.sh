#!/system/bin/sh
system="$(readlink -f $0 | tr '/' '\n' | tail -n 2 | head -n 1)"
sdcard="$EXTERNAL_STORAGE"
kit="$sdcard/$system"
home="$ANDROID_DATA/local"

if [ ! -z "$1" ]; then
  sysmod="true"
  system="$1"
  kit2="$kit"
fi

mnt="$home/$system"

export bin="/system/bin"
export PATH="$bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:$PATH"
export TERM="screen"
export HOME="/root"

if [ -e "$home/linuxonandroid/config.$system" ]; then
  . "$home/linuxonandroid/config.$system"
  if [ ! -z "$1" ]; then
    kit="$kit2"
  fi
fi

unset kit2

#Include extra functions
. "$kit/scripts/functions.sh"

echo "Remounting /system rw ..."
#set -x
if [ $(vercmp $(getBBver busybox) 1.20.0) -gt -1 ] ; then
  mount -o remount,rw -t "$(mount | awk ' /\/system\/* /{ print $5 " " $1 " " $3 }')" || mount -o remount,rw /system
else
  mount -o remount,rw -t "$(mount | awk ' /\/system\/* /{ print $3 " " $1 " " $2 }')" || mount -o remount,rw /system
fi

echo "Installing scripts into $bin ..."
#cd $kit/scripts
#for file in *; do
  #cp $file $bin
  #chmod 755 $bin/$file
#done
#cd - > /dev/null
cp -f "$kit/scripts/linux" "$bin/$system"
chmod 755 "$bin/$system"

#Install user config
"$bin/$system" install "$system"

echo "Mounting the Linux image ..."
"$bin/$system" mount

echo "Customizing the image ..."
echo "nameserver 8.8.8.8" > "$mnt/etc/resolv.conf"
echo "nameserver 8.8.4.4" >> "$mnt/etc/resolv.conf"
#echo "Setting localhost on /etc/hosts "
#echo "127.0.0.1 localhost" > "$mnt/etc/hosts"

echo "  Installing root-scripts ..."
#install custom root-scripts in $mnt/root/scripts
mkdir -p "$mnt/root/scripts"
chmod 755 "$mnt/root/scripts"
cp -f "$kit/root-scripts/"* "$mnt/root/scripts/"
chmod 755 "$mnt/root/scripts/"*

echo "  Installing user-scripts"
if [ -e "$mnt/etc/bash.bashrc" ] && [ ! -e "$mnt/etc/bash.bashrc.bak" ]; then
  mv "$mnt/etc/bash.bashrc" "$mnt/etc/bash.bashrc.bak"
fi
if [ -e "$mnt/etc/bash.bash_aliases" ] && [ ! -e "$mnt/etc/bash.bash_aliases.bak" ]; then
  mv "$mnt/etc/bash.bash_aliases" "$mnt/etc/bash.bash_aliases.bak"
fi
cp -f "$kit/scripts/.bashrc" "$mnt/root/"
cp -f "$kit/scripts/.bash_aliases" "$mnt/root/"
echo -n "$system" > "$mnt/etc/debian_chroot"

echo "  Installing bin-scripts ..."
cd "$kit/bin-scripts"
for file in *; do
  cp -f "$file" "$mnt/usr/bin/"
  chmod 755 "$mnt/usr/bin/$file"
done
cd - > /dev/null

if [ ! -e "/data/local/linuxonandroid/config.default" ]; then
  echo "Creating config files ..."
  mkdir -p "/data/local/linuxonandroid"
  echo "sdcard=\"$EXTERNAL_STORAGE\"" > "/data/local/linuxonandroid/config.default"
  echo "#kit=\"$sdcard/linux\"" >> "/data/local/linuxonandroid/config.default"
  echo "#home=\"$ANDROID_DATA/local\"" >> "/data/local/linuxonandroid/config.default"
  echo "#mnt=\"$home/linux\"" >> "/data/local/linuxonandroid/config.default"
  echo "export TERM=screen" >> "/data/local/linuxonandroid/config.default"
  echo "loopno=254" >> "/data/local/linuxonandroid/config.default"
fi

echo "Setting Root Password ..."
echo "Set new root password? [y/N]"
read accept
if [ "$accept" = "y" ] || [ "$accept" = "Y" ]; then
  "$bin/$system" passwd root
fi

echo "Install finished, Have Fun"
