#!/system/bin/sh
# See the file "license.terms" for information on usage and redistribution of
# this file, and for a DISCLAIMER OF ALL WARRANTIES.

# Some formating Rules:
# http://wiki.bash-hackers.org/doku.php

##---------------------------Initialize---------------------------------------##
system="$(readlink -f $0 | tr '/' '\n' | tail -n 2 | head -n 1)"
home="$ANDROID_DATA/local"

if [ -z "$SECONDARY_STORAGE" ]; then
  sdcard="$EXTERNAL_STORAGE"
else
  intern="$EXTERNAL_STORAGE"
  sdcard="$SECONDARY_STORAGE"
fi



##---------------------------Defines------------------------------------------##
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



while true; do   # Worse workaround for goto
##---------------------------Check Arguments------------------------##
for (( i=$((BASH_ARGC - 1)); $((i >= 0)); i=$((i - 1)) )); do
  curr_arg="${BASH_ARGV[$i]}"
  if [ -z "$curr_arg" ]; then
    :
  if [ "$curr_arg" == "-h" ] || [ "$curr_arg" == "--help" ]; then
    goto HELP
  elif [ "$(echo "$curr_arg" | head -c 2)" == "--" ];then
    case "$arg" in
    ##-------------------------Architecture---------------------------##
    --architecture)
      i=$((i - 1))
      architecture="${BASH_ARGV[$i]}"
      arg_arch="true"
    ;;
    ##-------------------------System User Home-----------------------##
    --home)
      echo "WARNING: home"
      i=$((i - 1))
      arg_home="${BASH_ARGV[$i]}"
    ;;
    ##-------------------------Image Path-----------------------------##
    --img)
      i=$((i - 1))
      img="${BASH_ARGV[$i]}"
      arg_img="true"
    ;;
    ##-------------------------Initialize-----------------------------##
    --init)
      arg_init="true"
    ;;
    ##-------------------------Mount Path-----------------------------##
    --mnt)
      i=$((i - 1))
      mnt="${BASH_ARGV[$i]}"
      arg_mnt="true"
    ;;
    ##-------------------------Use native mount-----------------------##
    --native)
      arg_native="--native"
    ;;
    ##-------------------------System Name----------------------------##
    --system)
      arg_system="true"
      i=$((i - 1))
      system="${BASH_ARGV[$i]}"
    ;;
    ##-------------------------Install Path of linux Script-----------##
    --bin)
      i=$((i - 1))
      arg_bin="${BASH_ARGV[$i]}"
    ;;
    ##-------------------------System TERM----------------------------##
    --term)
      i=$((i - 1))
      arg_term="${BASH_ARGV[$i]}"
    ;;
    ##-------------------------System PATH----------------------------##
    --path)
      i=$((i - 1))
      arg_path_abs="${BASH_ARGV[$i]}"
    ;;
    ##-------------------------System PATH----------------------------##
    --pre-path)
      i=$((i - 1))
      arg_path_pre="${BASH_ARGV[$i]}"
    ;;
    ##-------------------------System PATH----------------------------##
    --post-path)
      i=$((i - 1))
      arg_path_post="${BASH_ARGV[$i]}"
    ;;
    ##-------------------------Unknown Argument-----------------------##
    *)
      echo -e "$0: unknown argument: $curr_arg\n"
      "$0" -h
      exit 2 #TODO set the standard return value for this case
    ;;
    esac
  elif [ "$(echo -"$curr_arg" | head -c 2)" == "--" ];then
    args="$(echo -"$curr_arg" | awk 'BEGIN{FS=""}{ for (i = 3; i <= NF; ++i) print $i; }')"
  
    for arg in `echo -e "$args"`; do
      case "$arg" in
    ##-------------------------System Name----------------------------##
      s)
        arg_system="true"
        i=$((i - 1))
        system="${BASH_ARGV[$i]}"
      ;;
      ##-----------------------Unknown--------------------------------##
      *)
        echo -e "$0: unknown argument: -$arg\n"
        "$0" -h
        exit 2 #TODO set the standard return value for this case
      ;;
      esac
    done
  else
    arg_system="true"
    system="${BASH_ARGV[$i]}"

    if [ "$((i != 0))" == "1" ]; then
      echo "WARNING: Did you realy mean: system=$system"
      unset accept
      read accept
      if [ "$accept" != "y" ] && [ "$accept" != "Y" ] && [ "$accept" != "yes" ] && [ "$accept" != "Yes" ]; then
        exit 2 #TODO set the standard return value for this case
      fi  
    fi

    ##-------------------------Unknown Argument-----------------------##
    #echo -e "$0: unknown argument: $curr_arg\n"
    #"$0" -h
    #exit 2 #TODO set the standard return value for this case
  fi
done



##---------------------------Continue Initialize------------------------------##
kit="$(currentscriptpath)"
kit2="$kit"

if [ ! -z "$args_checked" ] || [ ! -e "$home/linuxonandroid/config.$system" ]; then
  break
else
  . "$home/linuxonandroid/config.$system"

  kit="$kit2"
  args_checked="true"
fi

done   # Worse workaround for goto

unset kit2

if [ -z "$mnt" ]; then
  mnt="$home/$system"
fi
if [ ! -z "$arg_bin" ]; then
  export bin="$arg_bin"
else
  export bin="$ANDROID_ROOT/bin"
fi
if [ ! -z "$arg_term" ]; then
  export TERM="$arg_term"
else
  export TERM="screen"
fi
#if [ "$arg_path_abs" == "true" ]; then
#  export PATH="$arg_path_abs"
#else
  export PATH="$bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:$PATH"
  if [ ! -z "arg_path_pre" ]; then
    export PATH="$arg_path_pre:$PATH"
  fi
  if [ ! -z "arg_path_post" ]; then
    export PATH="$PATH:$arg_path_post"
  fi
  #if [ ! -z "arg_home" ]; then
    export HOME="/root"
  #else
  #  export HOME="$arg_home"
  #fi
#fi
##---------------------------Everything Initialized-----------------------------## TODO length of this line



# Include extra functions
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

# Search image
if [ -z "$img" ]; then
  img="$(searchImage $kit $system)"
fi

# Install $system config
if [ "$arg_init" == "true" ]; then
  if [ -z "$img" ]; then
    "$bin/$system" install "$system" --noimage $arg_native #--force
  else
    "$bin/$system" install "$system" "$img" $arg_native #--force
  fi
  exit 0
elif [ -z "$img" ]; then
  echo "Cannot find the image file. The system will only initialized."
  "$bin/$system" install "$system" --noimage $arg_native #--force
  exit 6
else
  "$bin/$system" install "$system" $arg_native
fi

echo "Mounting the Linux image ..."
"$bin/$system" mount

echo "Customizing the image ..."
echo "  Setting DNS Server"
echo "nameserver 8.8.8.8" > "$mnt/etc/resolv.conf"
echo "nameserver 8.8.4.4" >> "$mnt/etc/resolv.conf"
#echo "  Setting localhost on /etc/hosts "
#echo "127.0.0.1 localhost" > "$mnt/etc/hosts"

echo "Installing scripts ..."
echo "  Installing root-scripts ..."
# install custom root-scripts in $mnt/root/scripts
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
  #echo "#kit=\"$sdcard/linux\"" >> "/data/local/linuxonandroid/config.default"
  echo "#home=\"$ANDROID_DATA/local\"" >> "/data/local/linuxonandroid/config.default"
  echo "#mnt=\"$home/linux\"" >> "/data/local/linuxonandroid/config.default"
  echo "#architecture=\"debian\"" >> "/data/local/linuxonandroid/config.default"
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
exit 0

HELP:
name="$(basename "$0")"
echo -e "$name [-h|--help]\nPrint this help\n"
echo -e "$name [-s|--system]\nA name for the operating system\n"
