#!/system/bin/mksh
# See the file "license.terms" for information on usage and redistribution of
# this file, and for a DISCLAIMER OF ALL WARRANTIES.

# Some formating Rules:
# http://wiki.bash-hackers.org/doku.php

# More Projects
# http://sourceforge.net/p/linuxonandroid/wiki/Home/
# http://forum.xda-developers.com/showthread.php?t=1522604
# http://www.pro-linux.de/news/1/17928/pulseaudio-auf-android-portiert.html
# http://sven-ola.dyndns.org/repo/debian-kit-en.html


# I need a MKSH shell but busybox's 'sh' was preffered in PATH
if [ "$(basename "`readlink -f "/proc/$$/exe"`")" != "mksh" ]; then
   exec mksh "$0" $@
fi


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



##-------------------------Prepare Argument List------------------------------##
unset BASH_ARGV
BASH_ARGC="$#"
i=-1
for curr_arg in "$@"; do
   set +A BASH_ARGV -- [$i]="$curr_arg"
   i=$((i - 1))
done
unset curr_arg



##---------------------------Defines------------------------------------------##



##---------------------------Start currentscriptpath--------------------------##
function currentscriptpath()
{
   local fullpath=`echo "$(readlink -f $0)"`
   local fullpath_length=`echo ${#fullpath}`
   local scriptname="$(basename "$fullpath")"
   local scriptname_length=`echo ${#scriptname}`
   local result_length=`echo $((fullpath_length - $scriptname_length - 1))`
   local result=`echo "$fullpath" | head -c $result_length`
   echo "$result"
}



##---------------------------Start function_main------------------------------##
function_main()
{
   function_initialize
   function_execute
} #end Fct



##---------------------------Start function_initialize------------------------##
function function_initialize()
{
   function_preCheckArguments

   if [ -z "$config_path" ]; then
      config_path="$home/linuxonandroid"
   fi

   kit="$(currentscriptpath)"
   kit2="$kit"

   # Get system alias name
   bname="$(basename $system)"
   #len1="${#bname}"
   #len2="${#system}"
   #systempath="${system:0:$((len2 - len1))}"

   if [ "$(($(echo $bname | awk 'BEGIN{FS="."}{print NF}') > 1))" == "1" ]; then
      # If bname has a suffix
      if [ "$(echo $bname | awk 'BEGIN{FS="."}{print $NF}')" == "img" ]; then
         # If suffix is 'img'
         systembase="$(echo $bname | awk 'BEGIN{FS=".";ORS=""}{rec = 0; for (i = 1; i < NF; i++) { if (rec == 1) print "."; rec = 1; print $i; } }')"
      fi
   fi

   if [ -n "$systembase" ] && [ -e "$config_path/config.$systembase" ]; then
      echo "Warning, a configuration with the systemname '$systembase' exists (extracted from '$bname')."

      . "$config_path/config.$system" # TODO

      kit="$kit2"
   fi
#exit

   function_checkArguments

   [[ ! -z "$arg_help" ]] && function_help && exit 0

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
   #   export PATH="$arg_path_abs"
   #else
   export PATH="$bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"
   if [ -n "arg_path_pre" ]; then
      export PATH="$arg_path_pre:$PATH"
   fi
   if [ -n "arg_path_post" ]; then
      export PATH="$PATH:$arg_path_post"
   fi
   #if [ -n "arg_home" ]; then
      export HOME="/root"
   #else
   #   export HOME="$arg_home"
   #fi
   #fi

   # Include extra functions
   . "$kit/scripts/functions.sh"

   # Search image
   if [ -z "$img" ]; then
      echo "Searching the Linux image ..."
      # Sets the img variable
      searchImage $kit $system
      export img
   fi

   # Set architecture for forwarding
   [[ -n "$architecture" ]] && arg_arch="--architecture $architecture"

   # 
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
} #end Fct



##---------------------------Start function_build_system_script---------------##
function function_build_system_script()
{
   cat "$kit/scripts/utils" "$kit/scripts/argumenthandling" "$kit/scripts/main" "$kit/scripts/mounthandling" "$kit/scripts/install" "$kit/scripts/linux" > "$bin/$system"
} #end Fct



##---------------------------Start function_execute---------------------------##
function function_execute()
{
   function_info

   ##------------------------Start Main---------------------------------------##
   echo "Remounting $ANDROID_ROOT rw ..."
   #set -x
   #if [ $(vercmp $(getBBver busybox) 1.20.0) -gt -1 ] ; then
   #   mount -o remount,rw -t "$(mount | awk ' /\/system\/* /{ print $5 " " $1 " " $3 }')" || mount -o remount,rw $ANDROID_ROOT
   #else
   #   mount -o remount,rw -t "$(mount | awk ' /\/system\/* /{ print $3 " " $1 " " $2 }')" || mount -o remount,rw $ANDROID_ROOT
   #fi
   mount -o remount,rw "$ANDROID_ROOT"

   echo "Installing main-script into $bin ..."
   #cd $kit/scripts
   #for file in *; do
      #cp $file $bin
      #chmod 755 $bin/$file
   #done
   #cd - > /dev/null
   function_build_system_script
   #cp -f "$kit/scripts/linux" "$bin/$system"
   chmod 755 "$bin/$system"

   # Install $system config
   if [ "$arg_init" == "true" ]; then
      if [ -z "$img" ]; then
         echo "Initialize without image file specification"
         "$bin/$system" install --system "$system" $arg_arch --noimage "$arg_native" "$arg_update" #--force
      else
         "$bin/$system" install --system "$system" $arg_arch --img "$img" "$arg_native" "$arg_update" #--force
      fi
      exit 0
   elif [ -z "$img" ]; then
      echo "Cannot find the image file. The system will only initialized."
      "$bin/$system" install --system "$system" $arg_arch --noimage "$arg_native" "$arg_update" #--force
      exit 6
   else
      "$bin/$system" install --system "$system" $arg_arch --img "$img" "$arg_native" "$arg_update"
   fi

   echo "Mounting the Linux image ..."
   "$bin/$system" mount

   if ! mountpoint -q "$mnt"; then
      echo "Cannot mount the image."
      exit 7
   fi

   # Find out architecture
   if [ -z "$architecture" ]; then
      echo "Guessing Linux Distribution ..."
      : #TODO find out architecture
   fi

   echo "Customizing the image ..."
   # TODO Complete the next line
   if ([ -e "$kit/config.user" ] || [ -e "$kit/config" ]) && [ -e "$kit/rootfs/.install.sh" ]; then
      echo "  Installing additional files ..."

      unset config_file
      if [ -e "$kit/config.user" ]; then
         config_file="--config=$kit/config.user"
      elif [ -e "$kit/config" ]; then
         config_file="--config=$kit/config"
      fi

      export kit system mnt img sdcard intern architecture

      cd "$kit/rootfs"
      #sh "$kit/rootfs/.install.sh" "$config_file"
      sh "$kit/rootfs/.install.sh" "$config_file"
      #mksh "$kit/rootfs/.install.sh" "$config_file"
      cd - > /dev/null
   fi

   echo "Setting Root Password ..."
   echo -n "Set new root password? [y/N] "
   read accept
   if [ "$accept" = "y" ] || [ "$accept" = "Y" ] || [ "$accept" = "yes" ] || [ "$accept" = "Yes" ]; then
      "$bin/$system" passwd root
   fi

   echo "Install finished, Have Fun"
} #end Fct



##---------------------------Start function_preCheckArguments-----------------##
function function_preCheckArguments()
{
   ##-------------------------Check Arguments---------------------------------##
   i=0
   #for (( i=$((BASH_ARGC - 1)); $((i >= 0)); i=$((i - 1)) )); do
   #for (( i=$((-1)); $((i >= -BASH_ARGC)); i=$((i - 1)) )); do
   until test "$((i > -BASH_ARGC))" == "0"; do
      i=$((i - 1))
      curr_arg="${BASH_ARGV[$i]}"

      if [ "$(echo "$curr_arg" | head -c 2)" == "--" ]; then
         case "$curr_arg" in
         ##---------------------Config Path-----------------------------------##
         --config)
            echo "WARNING: Do not change the default config path."
            i=$((i - 1))
            config_path="${BASH_ARGV[$i]}"
         ;;
         ##---------------------System User Home------------------------------##
         --home)
            echo "WARNING: Do not change the default home path."
            i=$((i - 1))
            arg_home="${BASH_ARGV[$i]}"
         ;;
         ##-----------------------System Name---------------------------------##
         --system)
            arg_system="true"
            i=$((i - 1))
            system="${BASH_ARGV[$i]}"
         ;;
         esac
      elif [ "$(echo -"$curr_arg" | head -c 2)" == "--" ]; then
         args="$(echo -"$curr_arg" | awk 'BEGIN{FS=""}{ for (i = 3; i <= NF; ++i) print $i; }')"

         for arg in `echo -e "$args"`; do
            case "$arg" in
            ##-----------------------System Name------------------------------##
            s)
               arg_system="true"
               i=$((i - 1))
               system="${BASH_ARGV[$i]}"
            ;;
            esac
         done
      fi
   done

   unset curr_arg
} #end Fct



##---------------------------Start function_checkArguments--------------------##
function function_checkArguments()
{
   ##---------------------------Check Arguments-------------------------------##
   i=0
   #for (( i=$((BASH_ARGC - 1)); $((i >= 0)); i=$((i - 1)) )); do
   #for (( i=$((-1)); $((i >= -BASH_ARGC)); i=$((i - 1)) )); do
   #for i in `seq 0 -1 -$BASH_ARGC | tail -n $BASH_ARGC`; do
   until test "$((i > -BASH_ARGC))" == "0"; do
      i=$((i - 1))
      curr_arg="${BASH_ARGV[$i]}"

      if [ -z "$curr_arg" ]; then
         :
      elif [ "$curr_arg" == "-h" ] || [ "$curr_arg" == "--help" ]; then
         arg_help=true
         break
      elif [ "$(echo "$curr_arg" | head -c 2)" == "--" ];then
         case "$curr_arg" in
         ##-----------------------Architecture--------------------------------##
         --architecture)
            i=$((i - 1))
            architecture="${BASH_ARGV[$i]}"
            arg_arch="true"
         ;;
         ##-----------------------Install Path of linux Script----------------##
         --bin)
            i=$((i - 1))
            arg_bin="${BASH_ARGV[$i]}"
         ;;
         ##-----------------------Config Path---------------------------------##
         --config)
            echo "WARNING: Do not change the default config path."
            i=$((i - 1))
            config_path="${BASH_ARGV[$i]}"
         ;;
         ##-----------------------System User Home----------------------------##
         --home)
            echo "WARNING: Do not change the default home path."
            i=$((i - 1))
            arg_home="${BASH_ARGV[$i]}"
         ;;
         ##-----------------------Image Path----------------------------------##
         --img)
            i=$((i - 1))
            img="${BASH_ARGV[$i]}"
            arg_img="true"
         ;;
         ##-----------------------Information-mode----------------------------##
         --info)
            arg_info="true"
         ;;
         ##-----------------------Initialize----------------------------------##
         --init)
            arg_init="true"
         ;;
         ##-----------------------Mount Path----------------------------------##
         --mnt)
            i=$((i - 1))
            mnt="${BASH_ARGV[$i]}"
            arg_mnt="true"
         ;;
         ##-----------------------Use native mount----------------------------##
         --native)
            arg_native="--native"
         ;;
         ##-----------------------System PATH---------------------------------##
         --path)
            i=$((i - 1))
            arg_path_abs="${BASH_ARGV[$i]}"
         ;;
         ##-----------------------System PATH---------------------------------##
         --pre-path)
            i=$((i - 1))
            arg_path_pre="${BASH_ARGV[$i]}"
         ;;
         ##-----------------------System PATH---------------------------------##
         --post-path)
            i=$((i - 1))
            arg_path_post="${BASH_ARGV[$i]}"
         ;;
         ##-----------------------System Name---------------------------------##
         --system)
            arg_system="true"
            i=$((i - 1))
            system="${BASH_ARGV[$i]}"
         ;;
         ##-----------------------System TERM---------------------------------##
         --term)
            i=$((i - 1))
            arg_term="${BASH_ARGV[$i]}"
         ;;
         ##-----------------------Install Path of linux Script----------------##
         --update)
            arg_update="--refresh"
         ;;
         ##-----------------------Unknown Argument----------------------------##
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
            ##-----------------------System Name------------------------------##
            s)
               arg_system="true"
               i=$((i - 1))
               system="${BASH_ARGV[$i]}"
            ;;
            ##---------------------Unknown------------------------------------##
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

         ##-----------------------Unknown Argument----------------------------##
         #echo -e "$0: unknown argument: $curr_arg\n"
         #"$0" -h
         #exit 2 #TODO set the standard return value for this case
      fi
   done

   unset curr_arg
} #end Fct



##---------------------------Start function_info------------------------------##
function function_info()
{
   if [ -n "$arg_info" ]; then
      echo "home:         $home"
      echo "config path:  $config_path"
      echo "config:       $config_path/config.$system"
      echo "system:       $system"
      echo "image:        $img"
      echo "mount point:  $mnt"
      echo "architecture: $architecture"
      echo "sdcard:       $sdcard"
      echo "intern:       $intern"
      echo "bin path:     $arg_bin"
      echo "init only:    $arg_init"

      exit 0
   fi
} #end Fct



##---------------------------Start function_help------------------------------##
function_help()
{
   name="$(basename "$0")"
   echo "LinuxOnAndroid"
   echo "Installs and prepares a Linux Operating-System parallel to Android"
   echo ""
   echo -e "$name [-h|--help]\n\tPrint this help"
   echo -e "$name [-s|--system] <system name>\n\tA name for the operating systen"
} #end Fct


function_main
