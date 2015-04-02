DEST ?=
PREFIX ?= usr/local

INSTALL_PATH = $(DEST)/$(PREFIX)

######################################################################
# Core count
CORES ?= 1

# Basic feature detection
OS = $(shell uname)
ARCH ?= $(shell uname -m)

######################################################################

CFLAGS ?= -Os -Wall -ansi -pedantic
LDFLAGS ?= -s
DDIR = docs
DSRC = $(shell ls src/docs/*)
SRC = $(shell ls src/*.c)
OBJ = $(SRC:.c=.o)
HDR = INC.h
IDIR = include
INC = $(IDIR)/$(HDR)
EDIR = bin
EXE = PROJ.exe
LNK = LIB
LDIR = lib
LSRC = $(shell ls src/lib/*.c)
LOBJ = $(LSRC:.c=.o)
LIB = $(LDIR)/lib$(LNK).a
TDIR = t
TSRC = $(shell ls t/*.c)
TOBJ = $(TSRC:.c=.o)
TEXE = $(TOBJ:.o=.exe)

TMPCI = $(shell cat tmp.ci.pid)
TMPCT = $(shell cat tmp.ct.pid)
TMPCD = $(shell cat tmp.cd.pid)

# DEPS
# DEPS = libDEP.a
# LIBDEP = -Ldeps/DEP -lDEP

# TDEPS
TAP ?= ptap
LIBTAP = -lptap

.c.o:
	$(CC) $(CFLAGS) -I$(IDIR) -c $< -o $@

# all: $(LIB) $(EXE)
# all: $(LIB)
# all: $(EXE)

$(OBJ): Makefile $(INC)

$(LIB): $(LOBJ)
	$(AR) -rcs $@ $^

$(EXE): $(OBJ)
#	$(LD) $^ $(LDFLAGS) -o $(EDIR)/$@
	$(CC) $< -L$(LDIR) -l$(LNK) $(LDFLAGS) $(LIBDEP) -o $(EDIR)/$@

t/%.exe: t/%.o
	$(CC) $< -L$(LDIR) -l$(LNK) $(LDFLAGS) $(CFLAGS) $(LIBDEP) $(LIBTAP) -o $@

test: $(TEXE)

$(TOBJ): $(LIB)

$(TEXE): $(TOBJ)

runtest: $(TEXE)
	for T in $^ ; do $(TAP) $$T ; done

start_ci:
	watch time -p make clean all & echo $$! > tmp.ci.pid

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
	rm -f $(OBJ) $(EXE) $(LOBJ) $(LIB) $(TOBJ) $(TEXE)

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

showconfig:
	@echo "OS="$(OS)
	@echo "ARCH="$(ARCH)
	@echo "DEST="$(DEST)
	@echo "PREFIX="$(PREFIX)
	@echo "INSTALL_PATH="$(INSTALL_PATH)
	@echo "CFLAGS="$(CFLAGS)
	@echo "LDFLAGS="$(LDFLAGS)
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
