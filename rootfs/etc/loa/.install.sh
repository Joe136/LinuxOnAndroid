#!/system/bin/sh
# See the file "license.terms" for information on usage and redistribution of
# this file, and for a DISCLAIMER OF ALL WARRANTIES.

echo '      Creating /etc/loa/*.conf files ...'
mkdir -p "$mnt/etc/loa"

touch "$mnt/etc/loa/android.conf"
touch "$mnt/etc/loa/mkdisk.conf"
touch "$mnt/etc/loa/ssh.conf"
touch "$mnt/etc/loa/vnc.conf"

for d in */.install.sh; do
  cd "${d:0:${#d}-12}"
  sh .install.sh
  cd - > /dev/null
done
