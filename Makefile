DESTDIR ?= /usr/local

######################################################################
# Core count
CORES ?= 1

# Basic feature detection
OS = $(shell uname)
ARCH ?= $(shell uname -m)

ifeq ($(ARCH), i686)
	ARCH = i386
endif

ifeq ($(ARCH), i386)
	MSIZE = 32
endif

ifeq ($(ARCH), x86_64)
	MSIZE = 64
endif

######################################################################

# Comment next line if you want System Default/GNU BFD LD instead
LD = gold
CFLAGS ?= -Os -Wall -ansi -pedantic
LDFLAGS ?= -s
DDIR = docs
DSRC = $(shell ls src/docs/*)
SRC = $(shell ls src/*.c)
OBJ = $(SRC:.c=.o)
SDEPS = $(SRC:.c=.d)
HDR = INC.h
IDIR = include
INC = $(IDIR)/$(HDR)
EDIR = bin
EXE = PROJ.exe
LNK = LIB
LDIR = lib
LSRC = $(shell ls src/lib/*.c)
LOBJ = $(LSRC:.c=.o)
LSDEPS = $(LSRC:.c=.d)
LIB = $(LDIR)/lib$(LNK).a
TDIR = t
TSRC = $(shell ls t/*.c)
TOBJ = $(TSRC:.c=.o)
TSDEPS = $(TSRC:.c=.d)
TEXE = $(TOBJ:.o=.exe)

# Since LDFLAGS defaults to "-s", probably better to override unless
# you have a default you would like to maintain
ifeq ($(WITH_DEBUG), 1)
	CFLAGS += -g
	LDFLAGS += -g
endif

# Since LDFLAGS defaults to "-s", probably better to override unless
# you have a default you would like to maintain
ifeq ($(WITH_PROFILING), 1)
	CFLAGS += -pg
	LDFLAGS += -pg
endif

TMPCI = $(shell cat tmp.ci.pid)
TMPCT = $(shell cat tmp.ct.pid)
TMPCD = $(shell cat tmp.cd.pid)

# DEPS
# DEPS = libDEP.a
# LIBDEP = -Ldeps/DEP -lDEP

# TDEPS
TAP ?= ptap
LIBTAP = -lptap

%.o: %.c $(INC) Makefile
	$(CC) $(CFLAGS) -MMD -MP -I$(IDIR) -c $< -o $@

%.exe: %.o $(LIB) Makefile
	$(LD) $< -L$(LDIR) -l$(LNK) $(LDFLAGS) $(LIBDEP) -o $@

t/%.exe: t/%.o $(LIB) Makefile
	$(LD) $< -L$(LDIR) -l$(LNK) $(LDFLAGS) $(LIBDEP) $(LIBTAP) -o $@

######################################################################
######################## DO NOT MODIFY BELOW #########################
######################################################################

.PHONY = all test runtest clean start_ci stop_ci start_ct stop_ct
.PHONY = start_cd stop_cd install uninstall showconfig gstat gpush
.PHONY = tarball

# Pick one
# all: $(LIB) $(EXE)
# all: $(LIB)
# all: $(EXE)

$(LIB): $(LOBJ)
	$(AR) -rcs $@ $^

test: $(LIB) $(TEXE) Makefile

runtest: $(TEXE)
	for T in $^ ; do $(TAP) $$T ; done

start_ci:
	watch time -p make clean all & echo $$! > tmp.ci.pid
#	while ! inotifywait -e modify $(SRC) $(LSRC) $(TSRC); do make clean all; done

stop_ci:
	kill -9 $(TMPCI)

start_ct:
	watch time -p make test & echo $$! > tmp.ct.pid

stop_ct:
	kill -9 $(TMPCT)

start_cd:
	watch time -p make install & echo $$! > tmp.cd.pid

stop_cd:
	kill -9 $(TMPCD)

clean:
	rm -f $(OBJ) $(EXE) $(LOBJ) $(LIB) $(TOBJ) $(TEXE) *.tmp $(SDEPS) $(LSDEPS) $(TSDEPS)

#install: $(INC) $(LIB)
install: $(EXE)
	mkdir -p $(INSTALL_PATH)/bin $(INSTALL_PATH)/include $(INSTALL_PATH)/lib
	rm -f .footprint
#	@for T in $(INC) $(LIB); \
	@for T in $(EXE); \
	do ( \
		echo $(INSTALL_PATH)/$$T >> .footprint; \
		cp -v --parents $$T $(INSTALL_PATH) \
	); done

uninstall: .footprint
	@for T in `cat .footprint`; do rm -v $$T; done

-include $(SDEPS) $(LSDEPS) $(TSDEPS)

showconfig:
	@echo "OS="$(OS)
	@echo "ARCH="$(ARCH)
	@echo "MSIZE="$(MSIZE)
	@echo "DESTDIR="$(DESTDIR)
	@echo "CFLAGS="$(CFLAGS)
	@echo "LDFLAGS="$(LDFLAGS)
	@echo "SDEPS="$(SDEPS)
	@echo "LSDEPS="$(LSDEPS)
	@echo "TSDEPS="$(TSDEPS)
	@echo "DDIR="$(DDIR)
	@echo "DSRC="$(DSRC)
	@echo "SRC="$(SRC)
	@echo "OBJ="$(OBJ)
	@echo "HDR="$(HDR)
	@echo "IDIR="$(IDIR)
	@echo "INC="$(INC)
	@echo "EDIR="$(EDIR)
	@echo "EXE="$(EXE)
	@echo "LDIR="$(LDIR)
	@echo "LSRC="$(LSRC)
	@echo "LOBJ="$(LOBJ)
	@echo "LNK="$(LNK)
	@echo "LIB="$(LIB)
	@echo "TSRC="$(TSRC)
	@echo "TOBJ="$(TOBJ)
	@echo "TEXE="$(TEXE)
	@echo "TMPCI="$(TMPCI)
	@echo "TMPCT="$(TMPCT)
	@echo "TMPCD="$(TMPCD)

gstat:
	git status

gpush:
	git commit
	git push

tarball:
	cd ../. && tar jcvf NewProj.$(shell date +%Y%m%d%H%M%S).tar.bz2 NewProj/
