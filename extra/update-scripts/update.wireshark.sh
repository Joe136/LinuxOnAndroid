#!/bin/bash

check()
{
  if [ "$?" != "0" ]; then
    echo "---ERROR---"
    cd - > /dev/null 2>&1
    exit 1
  fi
}

if [ "$1" == "--init" ]; then
  svn co http://anonsvn.wireshark.org/wireshark/trunk/ .
elif [ "$1" == "--noupdate" ] || ( [ -f timestamp ] && [ "$((`date +%s` - `cat timestamp` <= 82800))" == "1" ] ); then
  echo "Updated short time ago"
  echo ""
else
  svn update
  check
  echo -n "`date +%s`" > timestamp
fi

echo "---------- Automake"
./autogen.sh
check

echo "---------- Configure"
./configure --disable-wireshark
check

echo "---------- Make"
make
check

echo "---------- Install"
make install
check

