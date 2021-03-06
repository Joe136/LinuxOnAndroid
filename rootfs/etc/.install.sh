#!/system/bin/sh
# See the file "license.terms" for information on usage and redistribution of
# this file, and for a DISCLAIMER OF ALL WARRANTIES.

pwd
echo $system
exit
echo "      Installing user-configs ..."
# bashrc
unset second_line
if [ "$ignore_bashrc" != "true" ]; then
  if [ -e "$mnt/etc/bash.bashrc" ]; then
    second_line="$(cat "$mnt/etc/bash.bashrc" | head -n 2 | tail -n 1)"
    echo "$second_line" | grep -qe "exclude" && ignore_bashrc="true"
  
    if [ "$ignore_bashrc" != "true" ] && ( ! echo "$second_line" | grep -qe "LinuxOnAndroid" ) && [ ! -e "$mnt/etc/bash.bashrc.bak" ]; then
      mv "$mnt/etc/bash.bashrc" "$mnt/etc/bash.bashrc.bak"
    fi
  fi

  cp -f "bash.bashrc" "$mnt/etc/bash.bashrc"
  chmod 644 "$mnt/etc/bash.bashrc"
  chown root:root "$mnt/etc/bash.bashrc"
else
  echo "         Ignoring bash.bashrc"
fi

# bash_aliases
unset second_line
if [ "$ignore_bash_aliases" != "true" ]; then
  if [ -e "$mnt/etc/bash.bash_aliases" ]; then
    second_line="$(cat "$mnt/etc/bash.bash_aliases" | head -n 2 | tail -n 1)"
    echo "$second_line" | grep -qe "exclude" && ignore_bash_aliases="true"
  
    if [ "$ignore_bash_aliases" != "true" ] && ( ! echo "$second_line" | grep -qe "LinuxOnAndroid" ) && [ ! -e "$mnt/etc/bash.bash_aliases.bak" ]; then
      mv "$mnt/etc/bash.bash_aliases" "$mnt/etc/bash.bash_aliases.bak"
    fi
  fi

  cp -f "bash.bashrc_aliases" "$mnt/etc/bash.bashrc_aliases"
  chmod 644 "$mnt/etc/bash.bashrc_aliases"
  chown root:root "$mnt/etc/bash.bashrc_aliases"
else
  echo "         Ignoring bash.bash_aliases"
fi

# debian_chroot
if [ "$ignore_debian_chroot" != "true" ]; then
  echo -n "$system" > "$mnt/etc/debian_chroot"
fi

# resolv.conf
if [ "$ignore_dns_server" != "true" ]; then
  echo "nameserver 8.8.8.8" > "$mnt/etc/resolv.conf"
  echo "nameserver 8.8.4.4" >> "$mnt/etc/resolv.conf"
  chmod 644 "$mnt/etc/resolv.conf"
  chown root:root "$mnt/etc/resolv.conf"
  #echo "  Setting localhost on /etc/hosts "
  #echo "127.0.0.1 localhost" > "$mnt/etc/hosts"
fi

# nanorc
if [ -e "$mnt/etc/nanorc" ]; then
  second_line="$(cat "$mnt/etc/nanorc" | head -n 2 | tail -n 1)"
  if [ "$second_line" != "# LinuxOnAndroid" ]; then
    cat "$mnt/etc/nanorc" | head -n 1 > "$mnt/etc/nanorc.build"
    echo "# LinuxOnAndroid" >> "$mnt/etc/nanorc.build"
    cat "$mnt/etc/nanorc" | tail -n $(($(cat "$mnt/etc/nanorc" | wc -l) - 1)) >> "$mnt/etc/nanorc.build"
    cat "nanorc.build" >> "$mnt/etc/nanorc.build"
    mv "$mnt/etc/nanorc.build" "$mnt/etc/nanorc"
  fi
#else
#  cp -f "nanorc" "$mnt/etc/nanorc"
#  chmod 644 "$mnt/etc/nanorc"
#  chown root:root "$mnt/etc/nanorc"
fi


for d in */.install.sh; do
  cd "${d:0:${#d}-12}"
  sh .install.sh
  cd - > /dev/null
done
