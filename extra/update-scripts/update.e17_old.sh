#!/bin/bash
# See the file "license.terms" for information on usage and redistribution of
# this file, and for a DISCLAIMER OF ALL WARRANTIES.

#git svn pull
#svn co http://svn.enlightenment.org/svn/e/trunk .

check()
{
  if [ "$?" != "0" ]; then
    echo "---ERROR---"
    cd - > /dev/null 2>&1
    exit 1
  fi
}

if [ "$1" == "noupdate" ] || ( [ -f timestamp ] && [ "$((`date +%s` - `cat timestamp` <= 82800))" == "1" ] ); then
  echo "Updated short time ago"
  echo ""
#else
  #svn update
  #check
  #echo -n "`date +%s`" > timestamp
fi

mkdir -p /usr/local/lib/pkgconfig
export LD_LIBRARY_PATH="/usr/local/lib/:/lib/:/usr/lib/:$LD_LIBRARY_PATH"

#Compile the primary part
make -f Makefile.linux all INSTALLROOT=/usr/local; check

#Install all primary parts
PKG="efl
     eio
     edje
     e_dbus
     eeze
     emotion
     python-evas
     python-ecore
     python-edje
     python-e_dbus
     efx
     edbus
     efreet
     elementary
     terminology
     e
     clouseau"

for pkg in $PKG; do
make -f Makefile.linux $pkg-install INSTALLROOT=/usr/local; check
done

unset PKG



#BINDINGS/cxx/
PKG="eflxx
     einaxx
     evasxx
     eetxx
     edjexx
     ecorexx
     emotionxx
     elementaryxx
     eflxx_examples"
for pkg in $PKG; do
  cd "BINDINGS/cxx/$pkg"
  sh autogen.sh prefix=/usr/local; check
  make prefix=/usr/local; check
  make install prefix=/usr/local; check
  cd - > /dev/null 2>&1
done

#make -f Makefile.update eflxx-compile INSTALLROOT=/usr/local PACKAGE=eflxx PACKAGEPATH=BINDINGS/cxx/; check
#make -f Makefile.update einaxx-compile INSTALLROOT=/usr/local PACKAGE=einaxx PACKAGEPATH=BINDINGS/cxx/; check
#make -f Makefile.update evasxx-compile INSTALLROOT=/usr/local PACKAGE=evasxx PACKAGEPATH=BINDINGS/cxx/; check
#make -f Makefile.update eetxx-compile INSTALLROOT=/usr/local PACKAGE=eetxx PACKAGEPATH=BINDINGS/cxx/; check
#make -f Makefile.update edjexx-compile INSTALLROOT=/usr/local PACKAGE=edjexx PACKAGEPATH=BINDINGS/cxx/; check
#make -f Makefile.update ecorexx-compile INSTALLROOT=/usr/local PACKAGE=ecorexx PACKAGEPATH=BINDINGS/cxx/; check
#make -f Makefile.update emotionxx-compile INSTALLROOT=/usr/local PACKAGE=emotionxx PACKAGEPATH=BINDINGS/cxx/; check
#make -f Makefile.update elementaryxx-compile INSTALLROOT=/usr/local PACKAGE=elementaryxx PACKAGEPATH=BINDINGS/cxx/; check

#...
#make -f Makefile.update -compile INSTALLROOT=/usr/local PACKAGE= PACKAGEPATH=
#check
