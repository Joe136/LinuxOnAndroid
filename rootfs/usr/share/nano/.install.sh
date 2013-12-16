#!/system/bin/sh
# See the file "license.terms" for information on usage and redistribution of
# this file, and for a DISCLAIMER OF ALL WARRANTIES.

#  TODO Install anything here

mkdir -p "$mnt/usr/share/nano"

for file in *; do
  cp -f "$file" "$mnt/usr/share/nano"
  chmod 644 "$mnt/usr/share/nano/$file"
  chown root:root "$mnt/usr/share/nano/$file"
done

for d in */.install.sh; do
  cd "$d"
  sh "./.install.sh"
  cd - > /dev/null
done
