# Build all components, execute this from the chrooted linux
# See the file "license.terms" for information on usage and redistribution of
# this file, and for a DISCLAIMER OF ALL WARRANTIES.

SUBDIR = chroot-break

%.dir:
	make -C $(@:.dir=) all

%.dir.rm:
	make -C $(@:.dir.rm=) clean

%.dir.install:
	make -C $(@:.dir.install=) install

all: $(SUBDIR:=.dir)

clean: $(SUBDIR:=.dir.rm)

install: all $(SUBDIR:=.dir.install)

