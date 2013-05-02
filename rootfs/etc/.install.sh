#!/system/bin/sh
# See the file "license.terms" for information on usage and redistribution of
# this file, and for a DISCLAIMER OF ALL WARRANTIES.

#  TODO Install anything here

echo "  Installing user-configs ..."
if [ -e "$mnt/etc/bash.bashrc" ] && [ ! -e "$mnt/etc/bash.bashrc.bak" ]; then
  mv "$mnt/etc/bash.bashrc" "$mnt/etc/bash.bashrc.bak"
fi
cp -f "bash.bashrc" "$mnt/etc/bash.bashrc"
chmod 644 "$mnt/etc/bash.bashrc"
chown root:root "$mnt/etc/bash.bashrc"

if [ -e "$mnt/etc/bash.bash_aliases" ] && [ ! -e "$mnt/etc/bash.bash_aliases.bak" ]; then
  mv "$mnt/etc/bash.bash_aliases" "$mnt/etc/bash.bash_aliases.bak"
fi
cp -f "bash.bashrc_aliases" "$mnt/etc/bash.bashrc_aliases"
chmod 644 "$mnt/etc/bash.bashrc_aliases"
chown root:root "$mnt/etc/bash.bashrc_aliases"

#cp -f "bash.bashrc" "$mnt/root/.bashrc"
#cp -f "bash.bash_aliases" "$mnt/root/.bash_aliases"
#chmod 640 "$mnt/root/.bashrc"
#chmod 640 "$mnt/root/.bash_aliases"
#chown root:root "$mnt/root/.bashrc"
#chown root:root "$mnt/root/.bash_aliases"

echo -n "$system" > "$mnt/etc/debian_chroot"


for d in */.install.sh; do
  cd "$d"
  sh "$d/.install.sh"
  cd - > /dev/null
done
