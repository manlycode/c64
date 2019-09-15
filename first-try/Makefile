TARGETS = main
EXECUTABLES = main.prg
TOOLSDIR := /usr/local/bin
AS := $(TOOLSDIR)/ca65
LD := $(TOOLSDIR)/ld65
CL := $(TOOLSDIR)/cl65
LIB_PATH := /usr/local/Cellar/cc65/2.18/share/cc65/lib
INC_PATH := /usr/local/Cellar/cc65/2.18/share/cc65/asminc
CFG_PATH := /usr/local/Cellar/cc65/2.18/share/cc65/cfg
ASFLAGS := -g -t c64
LDFLAGS := -t c64
LABELS_POSTFIX := labels.txt
VICETOOLS := $(HOME)/bin/vice/tools
C1541 := $(VICETOOLS)/c1541
VICE := $(HOME)/bin/vice/tools/x64

SRCDIR := src
BINDIR := bin
LIST_POSTFIX := listing.txt
MAP_POSTFIX := map.txt

# ---------------------------------------------------------------
# Build Tasks
# ---------------------------------------------------------------
.PHONY: all
all: main.prg

.PHONY: clean
clean:
	-rm -rf bin/*
	-rm -rf release/*
	-rm -rf src/*.o

bin:
	mkdir bin

release:
	mkdir release

release/first-try.d64: bin/main.prg release
	$(C1541) \
    -format firsttry,id d64 $@\
    -attach $@ \
    -write bin/main.prg main


bin/%.prg: $(SRCDIR)/%.asm
	$(CL) -o $@ --cfg-path $(CFG_PATH) --asm-include-dir $(INC_PATH) --lib c64.lib -L $(LIB_PATH) -u __EXEHDR__ -t c64 -C c64-asm.cfg $^

%: release/%.d64
	$(VICE) $<
