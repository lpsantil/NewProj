vDEST ?=
PREFIX ?= /usr/local

CFLAGS = -Os -Wall -ansi -pedantic
LDFLAGS = -s
DDIR = docs
DSRC =
SRC = #$(shell ls src/*.c)
OBJ = $(SRC:.c=.o)
HDR = INC.h
IDIR = inc
INC = $(IDIR)/$(HDR)
EDIR = .
EXE = PROJ.exe
LNK = LIB
LDIR = .
LSRC = $(shell ls lib/*.c)
LOBJ = $(LSRC:.c=.o)
LIB = $(LDIR)/lib$(LNK).a
TDIR = t
TSRC = $(shell ls t/*.c)
TOBJ = $(TSRC:.c=.o)
TEXE = $(TOBJ:.o=.exe)

# DEPS
DEPS = libDEP.a
LIBDEP = -Ldeps/DEP -lDEP

# TDEPS
TDEPS = ptap libptap.a
TAP = deps/picotap/ptap
LIBTAP = -Ldeps/picotap -lptap

.c.o:
	$(CC) $(CFLAGS) -I$(IDIR) -c $< -o $@

# all: $(DEPS) $(LIB) $(EXE)

all: $(DEPS) $(LIB)

# all: $(DEPS) $(EXE)

# DEPS
libDEP.a: deps/DEP/libDEP.a
deps/DEP/libDEP.a:
	@cd deps/DEP && make
# TDEPS
ptap: deps/picotap/ptap
deps/picotap/ptap:
	@cd deps/picotap && make ptap
libptap.a: deps/picotap/libptap.a
deps/picotap/libptap.a:
	@cd deps/picotap && make libptap.a

$(OBJ): Makefile $(INC)

$(LIB): $(LOBJ)
	$(AR) -rcs $@ $^

$(EXE): $(OBJ)
	$(CC) $< -L$(LDIR) -l$(LNK) $(LDFLAGS) $(LIBDEP) -o $(EDIR)/$@

t/%.exe: t/%.o
	$(CC) $< -L$(LDIR) -l$(LNK) $(LDFLAGS) $(LIBTAP) -o $@

test: $(TDEPS) $(TEXE)

$(TOBJ): $(LIB)

$(TEXE): $(TOBJ)

runtest: $(TEXE)
	for T in $^ ; do $(TAP) $$T ; done

clean: clean_DEP clean_tap
	rm -f $(OBJ) $(EXE) $(LOBJ) $(LIB) $(TOBJ) $(TEXE)

clean_DEP:
	@cd deps/DEP && make clean

clean_tap:
	@cd deps/picotap && make clean

install: install_DEP
	mkdir -p $(DEST)/$(PREFIX)/bin $(DEST)/$(PREFIX)/include $(DEST)/$(PREFIX)/lib
	cp $(INC) $(DEST)/$(PREFIX)/include/
	cp $(LIB) $(DEST)/$(PREFIX)/lib/
	cp $(EXE) $(DEST)/$(PREFIX)/bin

install_DEP:
	@cd deps/DEP && make install

showconfig:
	@echo "DEST="$(DEST)
	@echo "PREFIX="$(PREFIX)
	@echo "CFLAGS="$(CFLAGS)
	@echo "LDFLAGS="$(LDFLAGS)
	@echo "DDIR="$(DDIR)
	@echo "DSRC="$(DSRC)
	@echo "SRC="$(SRC)
	@echo "HDR="$(HDR)
	@echo "IDIR="$(IDIR)
	@echo "INC="$(INC)
	@echo "OBJ="$(OBJ)
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

