#!/bin/bash
# See the file "license.terms" for information on usage and redistribution of
# this file, and for a DISCLAIMER OF ALL WARRANTIES.

if [ "$1" == "--init" ]; then
  svn co svn://www.tug.org/texlive/trunk/Build/source/ ./
  find . -name "*.test" | awk '{ system ("mv " $0 " " $0 ".bak") }'
elif [ "$1" != "--noupdate" ]; then
  svn update
  find . -name "*.test" | awk '{ system ("mv -f " $0 " " $0 ".bak") }'
fi

export TL_INSTALL_DEST="/usr/local/latex/texlive"

#mkdir -p /usr/local/latex/share
#mkdir -p /usr/local/latex/share/texmf
#mkdir -p /usr/local/latex/share/texmf-config
#mkdir -p /usr/local/latex/share/texmf-dist
#mkdir -p /usr/local/latex/share/texmf-etc
#mkdir -p /usr/local/latex/share/texmf-local
#mkdir -p /usr/local/latex/share/texmf-var

# For Debug
#export TL_MAKE=" "

export prefix2='${prefix}'

export PATH="$PATH:$TL_INSTALL_DEST/bin"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$TL_INSTALL_DEST/lib:$TL_INSTALL_DEST/lib/arm-linux-gnueabihf:$TL_INSTALL_DEST/lib/gcc/arm-linux-gnueabihf"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$TL_INSTALL_DEST/lib/arm-linux-gnueabihf/pkgconfig"

export TL_CONFIGURE_ARGS="--datarootdir='${prefix2}/share'
                          --datadir='${prefix2}/share'
                          --x-includes=\"$TL_INSTALL_DEST/include\"
                          --x-libraries=\"$TL_INSTALL_DEST/lib/arm-linux-gnueabihf\"
                          --enable-tex-synctex
                          --disable-multiplatform
                          --disable-native-texlive-build
                          --enable-compiler-warnings=all
                          --disable-missing
                          --disable-fast-install"


./Build --no-clean
# For Debug
#./Build

#[[ "$?" == "0" ]] && make
#[[ "$?" == "0" ]] && make install

