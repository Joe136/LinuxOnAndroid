
# See the file "license.terms" for information on usage and redistribution of
# this file, and for a DISCLAIMER OF ALL WARRANTIES.

CC          = gcc
CFLAGS      = -std=gnu99 -O3 -Wall
LDFLAGS     = 
LIBS        = 

srcdir      = .
prefix      = /usr
exec_prefix = ${prefix}
bindir      = ${exec_prefix}/bin
# man1dir     = ${prefix}/man/man1

INSTALL         = /usr/bin/install
INSTALL_PROGRAM = ${INSTALL}
INSTALL_DATA    = ${INSTALL} -m 755

OBJ         = $(shell ls *.c 2> /dev/null | xargs basename -s .c)
INST        = chroot-break

%.la: %.c
	$(CC) -shared $(CFLAGS) $(LDFLAGS) $(LIBS) -o $(<:.c=.la) $<

%.rm:
	rm -f $(@:.rm=)

%.install:
	$(INSTALL_PROGRAM) $(@:.install=) $(bindir)/

all: $(srcdir)/$(OBJ)

clean: $(srcdir)/$(OBJ:=.rm)

install: all $(srcdir)/$(INST:=.install)
