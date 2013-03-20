#!/system/bin/sh
# See the file "license.terms" for information on usage and redistribution of
# this file, and for a DISCLAIMER OF ALL WARRANTIES.

# Some formating Rules:
# http://wiki.bash-hackers.org/doku.php

# More Projects
# http://sourceforge.net/p/linuxonandroid/wiki/Home/
# http://forum.xda-developers.com/showthread.php?t=1522604
# http://www.pro-linux.de/news/1/17928/pulseaudio-auf-android-portiert.html
# http://sven-ola.dyndns.org/repo/debian-kit-en.html


##---------------------------Initialize---------------------------------------##
system="$(readlink -f $0 | tr '/' '\n' | tail -n 2 | head -n 1)"
home="$ANDROID_DATA/local"

if [ -z "$SECONDARY_STORAGE" ]; then
  sdcard="$EXTERNAL_STORAGE"
  #sdcard="$(df -P "/dev/block/mmcblk0p1" | awk '{ print $6 }' | tail -n 1 )"
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
while true; do   # Really worse workaround for goto
##---------------------------Check Arguments--------------------------##
#for (( i=$((BASH_ARGC - 1)); $((i >= 0)); i=$((i - 1)) )); do
for (( i=$((-1)); $((i >= -BASH_ARGC)); i=$((i - 1)) )); do
  curr_arg="${BASH_ARGV[$i]}"
  if [ -z "$curr_arg" ]; then
    :
  elif [ "$curr_arg" == "-h" ] || [ "$curr_arg" == "--help" ]; then
    arg_help=true
    break
  elif [ "$(echo "$curr_arg" | head -c 2)" == "--" ];then
    case "$arg" in
    ##-------------------------Architecture---------------------------##
    --architecture)
      i=$((i - 1))
      architecture="${BASH_ARGV[$i]}"
      arg_arch="true"
    ;;
    ##-------------------------Install Path of linux Script-----------##
    --bin)
      i=$((i - 1))
      arg_bin="${BASH_ARGV[$i]}"
    ;;
    ##-------------------------Config Path----------------------------##
    --config)
      echo "WARNING: Do not change the default config path."
      i=$((i - 1))
      config_path="${BASH_ARGV[$i]}"
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
    ##-------------------------System Name----------------------------##
    --system)
      arg_system="true"
      i=$((i - 1))
      system="${BASH_ARGV[$i]}"
    ;;
    ##-------------------------System TERM----------------------------##
    --term)
      i=$((i - 1))
      arg_term="${BASH_ARGV[$i]}"
    ;;
    ##-------------------------Install Path of linux Script-----------##
    --update)
      arg_update="--refresh"
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
    if [ "$((i != 0))" == "1" ]; then
      echo -n "WARNING: Did you realy mean: system=${BASH_ARGV[$i]} "
      unset accept
      read accept
      if [ "$accept" != "y" ] && [ "$accept" != "Y" ] && [ "$accept" != "yes" ] && [ "$accept" != "Yes" ]; then
        exit 2 #TODO set the standard return value for this case
      else
        arg_system="true"
        system="${BASH_ARGV[$i]}"
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
  . "$home/linuxonandroid/config.$system" # TODO

  kit="$kit2"
  args_checked="true"
fi

done   # Worse workaround for goto
if [ ! -z "$arg_help" ]; then break; fi   # Really worse workaround for goto

unset kit2

if [ -z "$mnt" ]; then
  mnt="$home/$system"
fi
if [ -z "$config_path" ]; then
  config_path="$home/linuxonandroid"
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

if [ ! -e "$config_path/config.default" ]; then
  echo "Creating config files ..."
  mkdir -p "$config_path"
  echo "#sdcard=\"$EXTERNAL_STORAGE\"" > "$config_path/config.default"
  echo "#intern=\"$EXTERNAL_STORAGE\"" > "$config_path/config.default"
  echo "#sdcard=\"$SECONDARY_STORAGE\"" > "$config_path/config.default"
  #echo "#kit=\"$sdcard/linux\"" >> "$config_path/config.default"
  echo "#home=\"$home\"" >> "$config_path/config.default"
  echo "#mnt=\"$home/linux\"" >> "$config_path/config.default"
  echo "#architecture=\"debian\"" >> "$config_path/config.default"
  echo "#export TERM=screen" >> "$config_path/config.default"
  echo "#nw_service=ifupdown" >> "$config_path/config.default"
fi
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
    "$bin/$system" install --system "$system" --noimage "$arg_native" "$arg_update" #--force
  else
    "$bin/$system" install --system "$system" --img "$img" "$arg_native" "$arg_update" #--force
  fi
  exit 0
elif [ -z "$img" ]; then
  echo "Cannot find the image file. The system will only initialized."
  "$bin/$system" install --system "$system" --noimage "$arg_native" "$arg_update" #--force
  exit 6
else
  "$bin/$system" install --system "$system" --img "$img" "$arg_native" "$arg_update"
fi

echo "Mounting the Linux image ..."
"$bin/$system" mount

if ! mountpoint -q "$mnt"; then
  echo "Cannot mount the image."
  exit 7
fi

echo "Customizing the image ..."
echo "  Setting DNS Server"
echo "nameserver 8.8.8.8" > "$mnt/etc/resolv.conf"
echo "nameserver 8.8.4.4" >> "$mnt/etc/resolv.conf"
#echo "  Setting localhost on /etc/hosts "
#echo "127.0.0.1 localhost" > "$mnt/etc/hosts"

if [ -e "$" ]; then
  echo "  Installing additional files ..."
  cd "$kit/rootfs"
  sh "$kit/rootfs/.install.sh"
  cd - > /dev/null
fi

echo "Setting Root Password ..."
echo -n "Set new root password? [y/N] "
read accept
if [ "$accept" = "y" ] || [ "$accept" = "Y" ] || [ "$accept" = "yes" ] || [ "$accept" = "Yes" ]; then
  "$bin/$system" passwd root
fi

echo "Install finished, Have Fun"
exit 0

done   # Really worse workaround for goto

name="$(basename "$0")"
echo -e "$name [-h|--help]\nPrint this help\n"
echo -e "$name [-s|--system]\nA name for the operating system\n"
