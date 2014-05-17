
# See the file "license.terms" for information on usage and redistribution of
# this file, and for a DISCLAIMER OF ALL WARRANTIES.

## Program specification
APP_BINARY   = battery-notification

MAJOR        = 0
MINOR        = 1
PATCH        = 0

## Compiler specification
CC           = gcc
CPP          = g++

## Directory specification
srcdir       = .
prefix       = /usr
exec_prefix  = ${prefix}
bindir       = ${exec_prefix}/bin
# man1dir     = ${prefix}/man/man1

## 
NOWARNINGS   = #-Wno-comment -Wno-reorder -Wno-unused-variable -Wno-unused-result -Wno-sign-compare -Wno-maybe-uninitialized
WARNINGS     = -Wall -Werror $(NOWARNINGS)

## 
INCLUDES     = 
CPPFLAGS     = -std=c++11 -march=native -O3 -flto -fPIC -DLINUX -DVERSION=\"$(MAJOR).$(MINOR).$(PATCH)\" $(WARNINGS) $(INCLUDES)
CCFLAGS      = -std=gnu99 -march=native -O3       -fPIC -DLINUX -DVERSION=\"$(MAJOR).$(MINOR).$(PATCH)\" $(WARNINGS) $(INCLUDES)
CFLAGS       = -std=gnu99 -march=native -O3       -fPIC -DLINUX -DVERSION=\"$(MAJOR).$(MINOR).$(PATCH)\" $(WARNINGS) $(INCLUDES)
LDFLAGS      =            -march=native -O3 -static -Wl,-Bstatic  #-flto

## Get all .c, .cc, .cpp files and convert suffix to .o
OBJECTS     += $(shell ls *.cpp > /dev/null 2>&1 && ls *.cpp 2> /dev/null | xargs basename -s cpp | xargs -I {} echo -n "{}opp ")
OBJECTS     += $(shell ls *.cc  > /dev/null 2>&1 && ls *.cc  2> /dev/null | xargs basename -s cc  | xargs -I {} echo -n "{}oc ")
OBJECTS     += $(shell ls *.c   > /dev/null 2>&1 && ls *.c   2> /dev/null | xargs basename -s c   | xargs -I {} echo -n "{}o ")
DEPENDS      = $(shell ls *.h  2> /dev/null)


## Libraries
STATIC_LIBS  = 
DYNAMIC_LIBS = 


## Make commands
all: $(APP_BINARY)


## Cleanup
clean:
	@echo "Cleaning up directory."
	rm -f *.a *.o $(APP_BINARY) core *~ log errlog

clean-all: clean
	make clean -C htmlcxx


## Install
install:
	install $(APP_BINARY) $(bindir)


## Compile Application
$(APP_BINARY): $(OBJECTS)
	$(CPP) $(OBJECTS) -Wl,-Bstatic $(STATIC_LIBS) -Wl,-Bdynamic $(DYNAMIC_LIBS) $(LDFLAGS) -o $(APP_BINARY)


## Compile Objects
%.o: %.cpp
	$(CPP) $(CPPFLAGS) -c -o $@ $<

%.o: %.cpp %.h
	$(CPP) $(CPPFLAGS) -c -o $@ $<

%.o: %.cpp %.hpp
	$(CPP) $(CPPFLAGS) -c -o $@ $<

%.o: %.cc
	$(CC) $(CCFLAGS) -c -o $@ $<

%.o: %.cc %.h
	$(CC) $(CCFLAGS) -c -o $@ $<

%.o: %.c $(DEPENDS)
	$(CC) $(CFLAGS) -c -o $@ $<

%.o: %.c %.h $(DEPENDS)
	$(CC) $(CFLAGS) -c -o $@ $<


strip:
	strip -s $(APP_BINARY)


## Debugging
debug: CPPFLAGS += -O0 -ggdb
debug: CFLAGS   += -O0 -ggdb
debug: LDFLAGS  += -O0 -ggdb


debug: $(OBJECTS) $(APP_BINARY)

