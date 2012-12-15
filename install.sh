#!/system/bin/sh
system="$(readlink -f $0 | tr '/' '\n' | tail -n 2 | head -n 1)"
home="$ANDROID_DATA/local"

if [ -z "$SECONDARY_STORAGE" ]; then
  sdcard="$EXTERNAL_STORAGE"
else
  intern="$EXTERNAL_STORAGE"
  sdcard="$SECONDARY_STORAGE"
fi

currentscriptpath()
{
  local fullpath=`echo "$(readlink -f $0)"`
  local fullpath_length=`echo ${#fullpath}`
  local scriptname="$(basename "$fullpath")"
  local scriptname_length=`echo ${#scriptname}`
  local result_length=`echo $((fullpath_length - $scriptname_length - 1))`
  local result=`echo "$fullpath" | head -c $result_length`
  echo "$result"
}

kit="$(currentscriptpath)"

if [ ! -z "$1" ]; then
  sysmod="true"
  system="$1"
  kit2="$kit"
fi

mnt="$home/$system"

export bin="$ANDROID_ROOT/bin"
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

echo "Remounting $ANDROID_ROOT rw ..."
#set -x
#if [ $(vercmp $(getBBver busybox) 1.20.0) -gt -1 ] ; then
#  mount -o remount,rw -t "$(mount | awk ' /\/system\/* /{ print $5 " " $1 " " $3 }')" || mount -o remount,rw $ANDROID_ROOT
#else
#  mount -o remount,rw -t "$(mount | awk ' /\/system\/* /{ print $3 " " $1 " " $2 }')" || mount -o remount,rw $ANDROID_ROOT
#fi
mount -o remount,rw "$ANDROID_ROOT"

echo "Installing main-script into $bin ..."
#cd $kit/scripts
#for file in *; do
  #cp $file $bin
  #chmod 755 $bin/$file
#done
#cd - > /dev/null
cp -f "$kit/scripts/linux" "$bin/$system"
chmod 755 "$bin/$system"

#Install $system config
if [ -z "$img" ]; then
  img="$(searchImage $kit $system)"
fi

if [ "$1" == "--init" ] || [ "$2" == "--init" ] || [ "$3" == "--init" ]; then
  if [ -z "$img" ]; then
    "$bin/$system" install "$system" --noimage #--force
  else
    "$bin/$system" install "$system" "$img" #--force
  fi
elif [ -z "$img" ]; then
  echo "Cannot find the image file. The system will only initialized."
  "$bin/$system" install "$system" --noimage #--force
fi

"$bin/$system" install "$system"

echo "Mounting the Linux image ..."
"$bin/$system" mount

echo "Customizing the image ..."
echo "nameserver 8.8.8.8" > "$mnt/etc/resolv.conf"
echo "nameserver 8.8.4.4" >> "$mnt/etc/resolv.conf"
#echo "Setting localhost on /etc/hosts "
#echo "127.0.0.1 localhost" > "$mnt/etc/hosts"

echo "Installing scripts ..."
echo "  Installing root-scripts ..."
#install custom root-scripts in $mnt/root/scripts
mkdir -p "$mnt/root/scripts"
chmod 755 "$mnt/root/scripts"
cp -f "$kit/rootfs/root/scripts/"* "$mnt/root/scripts/"
chmod 755 "$mnt/root/scripts/"*

echo "  Installing user-configs ..."
if [ -e "$mnt/etc/bash.bashrc" ] && [ ! -e "$mnt/etc/bash.bashrc.bak" ]; then
  mv "$mnt/etc/bash.bashrc" "$mnt/etc/bash.bashrc.bak"
fi
if [ ! -e "$mnt/etc/bash.bashrc" ]; then
  cp -f "$kit/rootfs/etc/bash.bashrc" "$mnt/etc/bash.bashrc"
  chmod 644 "$mnt/etc/bash.bashrc"
  chown root:root "$mnt/etc/bash.bashrc"
fi

if [ -e "$mnt/etc/bash.bash_aliases" ] && [ ! -e "$mnt/etc/bash.bash_aliases.bak" ]; then
  mv "$mnt/etc/bash.bash_aliases" "$mnt/etc/bash.bash_aliases.bak"
fi
if [ ! -e "$mnt/etc/bash.bashrc_aliases" ]; then
  cp -f "$kit/rootfs/etc/bash.bashrc_aliases" "$mnt/etc/bash.bashrc_aliases"
  chmod 644 "$mnt/etc/bash.bashrc_aliases"
  chown root:root "$mnt/etc/bash.bashrc_aliases"
fi

cp -f "$kit/rootfs/etc/bash.bashrc" "$mnt/root/.bashrc"
cp -f "$kit/rootfs/etc/bash.bash_aliases" "$mnt/root/.bash_aliases"
echo -n "$system" > "$mnt/etc/debian_chroot"

echo "  Installing bin-scripts ..."
cd "$kit/rootfs/usr/bin"
for file in *; do
  cp -f "$file" "$mnt/usr/bin/"
  chmod 755 "$mnt/usr/bin/$file"
done
cd - > /dev/null

if [ ! -e "$home/linuxonandroid/config.default" ]; then
  echo "Creating config files ..."
  mkdir -p "$home/linuxonandroid"
  echo "#sdcard=\"$EXTERNAL_STORAGE\"" > "/data/local/linuxonandroid/config.default"
  echo "#intern=\"$EXTERNAL_STORAGE\"" > "/data/local/linuxonandroid/config.default"
  echo "#sdcard=\"$SECONDARY_STORAGE\"" > "/data/local/linuxonandroid/config.default"
  echo "#kit=\"$sdcard/linux\"" >> "/data/local/linuxonandroid/config.default"
  echo "#home=\"$ANDROID_DATA/local\"" >> "/data/local/linuxonandroid/config.default"
  echo "#mnt=\"$home/linux\"" >> "/data/local/linuxonandroid/config.default"
  echo "#export TERM=screen" >> "/data/local/linuxonandroid/config.default"
  echo "#loopno=254" >> "/data/local/linuxonandroid/config.default"
fi

echo "Setting Root Password ..."
echo "Set new root password? [y/N]"
read accept
if [ "$accept" = "y" ] || [ "$accept" = "Y" ] || [ "$accept" = "yes" ] || [ "$accept" = "Yes" ]; then
  "$bin/$system" passwd root
fi

echo "Install finished, Have Fun"
