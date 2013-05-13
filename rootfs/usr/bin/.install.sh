#!/system/bin/sh
# See the file "license.terms" for information on usage and redistribution of
# this file, and for a DISCLAIMER OF ALL WARRANTIES.

#  TODO Install anything here

echo "      Installing bin-scripts ..."
for file in *; do
  cp -f "$file" "$mnt/usr/bin/"
  chmod 755 "$mnt/usr/bin/$file"
done


for d in */.install.sh; do
  cd "$d"
  sh "./.install.sh"
  cd - > /dev/null
done
