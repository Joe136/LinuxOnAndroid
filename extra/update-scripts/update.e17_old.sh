#!/bin/bash
# See the file "license.terms" for information on usage and redistribution of
# this file, and for a DISCLAIMER OF ALL WARRANTIES.

#git svn pull
#svn co http://svn.enlightenment.org/svn/e/trunk .

E_ROOT_DIR=`pwd`



##---------------------------Start check--------------------------------------##
check()
{
  if [ "$?" != "0" ]; then
    echo "---ERROR---"
    cd - > /dev/null 2>&1
    exit 1
  fi
}
##---------------------------End check----------------------------------------##



##---------------------------Print Config-------------------------------------##
[[ -n "$NO_PRIMARY" ]] && echo "## No Primary Modules"
[[ -n "$NO_CXX" ]] && echo "## No CXX Modules"
[[ -n "$WAIT" ]] && echo "## Wait after configure"
[[ "$WAIT" == "break" ]] && echo "## No Compilation"



##---------------------------Update-------------------------------------------##
if [ "$1" == "init" ]; then
  #svn co http://svn.enlightenment.org/svn/e/trunk .
  #git clone ??? ./
  :
elif [ "$1" == "noupdate" ] || ( [ -f timestamp ] && [ "$((`date +%s` - `cat timestamp` <= 82800))" == "1" ] ); then
  echo "Updated short time ago"
  echo ""
#else
  #svn update
  #check
  #echo -n "`date +%s`" > timestamp
fi



##---------------------------Prepare------------------------------------------##
mkdir -p build
mkdir -p "/usr/local" && mkdir -p "/usr/local/lib" && mkdir -p "/usr/local/lib/pkgconfig"
export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"
export LD_LIBRARY_PATH="/usr/local/lib/:/lib/:/usr/lib/:$LD_LIBRARY_PATH"



##---------------------------Primary Modules----------------------------------##
#Compile the primary part
#make -f Makefile.linux all INSTALLROOT=/usr/local; check

#Compile/Install all primary parts
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

if [ -z "$NO_PRIMARY" ]; then
  echo "## ---------- Primary Modules ---------- ##"
  for pkg in $PKG; do
    echo "## ----------$pkg---------- ##"
    [[ "$WAIT" != "" ]] && make -f Makefile.linux "$E_ROOT_DIR/build/$pkg/stamps/configure" INSTALLROOT=/usr/local && check && echo "---WAIT---" && read
    if [[ "$WAIT" != "break" ]]; then
      echo point1
      make -f Makefile.linux $pkg-compile INSTALLROOT=/usr/local; check
    else
      echo "---DO_NOT_MAKE---"
    fi
  done
fi

unset PKG



#----------------------------CXX Modules--------------------------------------##
PKG="eflxx
     einaxx
     evasxx
     eetxx
     edjexx
     ecorexx
     emotionxx
     elementaryxx
     eflxx_examples"

if [ -z "$NO_CXX" ]; then
  echo "## ---------- CXX Modules ---------- ##"
  for pkg in $PKG; do
    echo "## ----------$pkg---------- ##"
    cd "BINDINGS/cxx/$pkg"
    #sh autogen.sh --prefix=/usr/local "--build=$E_ROOT_DIR/build"; check
    sh autogen.sh --prefix=/usr/local; check
    [[ "$WAIT" != "" ]] && echo "---WAIT---" && read
    if [[ "$WAIT" != "break" ]]; then
      make; check
      make install; check
    else
      echo "---DO_NOT_MAKE---"
    fi
    cd - > /dev/null 2>&1
  done
fi

unset PKG


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

echo ""
echo "[DONE]"

