#!/system/bin/sh
# See the file "license.terms" for information on usage and redistribution of
# this file, and for a DISCLAIMER OF ALL WARRANTIES.

#  TODO Install anything here

for d in */.install.sh; do
  cd "$d"
  sh "$d/.install.sh"
  cd - > /dev/null
done
