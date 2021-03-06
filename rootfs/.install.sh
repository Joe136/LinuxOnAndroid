#!/system/bin/sh
# See the file "license.terms" for information on usage and redistribution of
# this file, and for a DISCLAIMER OF ALL WARRANTIES.

#  TODO Install anything here

for curr_arg in "$@"; do
  if echo "$curr_arg" | grep -qxe '--config='; then
	#readconfig "$(echo "$curr_arg" | grep -ove '--config=')"
    break
  fi
done

cd "etc"
sh .install.sh
cd - > /dev/null

exit

for d in */.install.sh; do
  cd "${d:0:${#d}-12}"
  sh .install.sh
  cd - > /dev/null
done
