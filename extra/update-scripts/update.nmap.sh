#!/bin/bash
# See the file "license.terms" for information on usage and redistribution of
# this file, and for a DISCLAIMER OF ALL WARRANTIES.

#git svn pull
#svn co  .

check()
{
  if [ "$?" != "0" ]; then
    echo "---ERROR---"
    cd - > /dev/null 2>&1
    exit 1
  fi
}

if [ "$1" == "--init" ]; then
  #svn co  .
  :
elif [ "$1" == "--noupdate" ] || ( [ -f timestamp ] && [ "$((`date +%s` - `cat timestamp` <= 82800))" == "1" ] ); then
  echo "Updated short time ago"
  echo ""
else
  svn update
  check
  echo -n "`date +%s`" > timestamp
fi

echo "---------- Configure"
./configure --prefix=/usr/local
check

echo "---------- Make"
make
check

echo "---------- Install"
make install

