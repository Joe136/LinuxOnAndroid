#!/bin/sh
# See the file "license.terms" for information on usage and redistribution of
# this file, and for a DISCLAIMER OF ALL WARRANTIES.

set -e

iface="$1"

if ! ifconfig | grep -qe "^$iface"; then
  ifconfig "$iface" up
  was_down="true"
fi

scan="$(iwlist "$iface" scan)"
which=""


while read essid scheme; do
  echo "$iface : $essid : $scheme" 1>&2
  if echo "$scan" | grep -q -e "ESSID:\"$essid\""; then
    echo "$scheme"
    echo "Return $scheme" 1>&2
    exit 0
    break
  fi
done

if [ -n "$was_down" ]; then
  ifconfig "$iface" down
fi
exit 1

