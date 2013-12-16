#!/system/bin/sh
# See the file "license.terms" for information on usage and redistribution of
# this file, and for a DISCLAIMER OF ALL WARRANTIES.

if [ "$bashrc_bash_completition" == "true" ]; then
  echo "      Installing bash-completion ..."

  cp -f "android" "$mnt/etc/bash_completion.d/android"
  chmod 644 "$mnt/etc/bash_completion.d/android"
  chown root:root "$mnt/bash_completion.d/android"

  if [ "$include_bash_aliases" == "true" ]; then
    cp -f "apt-cache-aliases" "$mnt/etc/bash_completion.d/apt-cache-aliases"
    chmod 644 "$mnt/etc/bash_completion.d/apt-cache-aliases"
    chown root:root "$mnt/bash_completion.d/apt-cache-aliases"

    cp -f "apt-get-aliases" "$mnt/etc/bash_completion.d/apt-get-aliases"
    chmod 644 "$mnt/etc/bash_completion.d/apt-get-aliases"
    chown root:root "$mnt/bash_completion.d/apt-get-aliases"
  fi

  cp -f "mkdisk" "$mnt/etc/bash_completion.d/mkdisk"
  chmod 644 "$mnt/etc/bash_completion.d/mkdisk"
  chown root:root "$mnt/bash_completion.d/mkdisk"

  cp -f "update" "$mnt/etc/bash_completion.d/update"
  chmod 644 "$mnt/etc/bash_completion.d/update"
  chown root:root "$mnt/bash_completion.d/update"
fi


for d in */.install.sh; do
  cd "$d"
  sh "./.install.sh"
  cd - > /dev/null
done
