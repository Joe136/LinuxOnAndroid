#!/bin/bash
# See the file "license.terms" for information on usage and redistribution of
# this file, and for a DISCLAIMER OF ALL WARRANTIES.

if [ "$1" != "--init" ]; then
  svn co svn://www.tug.org/texlive/trunk/ ./
fi

if [ "$1" != "--noupdate" ]; then
  svn update
fi

mkdir -p /usr/local/latex/share
mkdir -p /usr/local/latex/share/texmf
mkdir -p /usr/local/latex/share/texmf-coonfig
mkdir -p /usr/local/latex/share/texmf-dist
mkdir -p /usr/local/latex/share/texmf-etc
mkdir -p /usr/local/latex/share/texmf-local
mkdir -p /usr/local/latex/share/texmf-var

# For Debug
#export TL_MAKE=" "

export prefix2='${prefix}'

export PATH="$PATH:/usr/local/latex/bin"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/latex/lib:/usr/local/latex/lib/arm-linux-gnueabihf"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/usr/local/latex/lib/arm-linux-gnueabihf/pkgconfig"
export TL_INSTALL_DEST="/usr/local/latex"

export TL_CONFIGURE_ARGS="--datarootdir='${prefix2}/share'
                          --datadir='${prefix2}/share'
                          --x-includes=\"/usr/local/latex/include\"
                          --x-libraries=\"/usr/local/latex/lib/arm-linux-gnueabihf\"
                          --enable-tex-synctex
                          --disable-multiplatform
                          --disable-native-texlive-build
                          --enable-compiler-warnings=no
                          --disable-missing
                          --disable-fast-install"


./Build --no-clean
# For Debug
#./Build

#[[ "$?" == "0" ]] && make
[[ "$?" == "0" ]] && make install

