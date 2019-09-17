TARGETS = first-try
EXECUTABLES = first-try.prg
CC65_DIR := vendor/cc65
TOOLSDIR := $(CC65_DIR)/bin
AS := $(TOOLSDIR)/ca65
LD := $(TOOLSDIR)/ld65
CL := $(TOOLSDIR)/cl65
LIB_PATH := $(CC65_DIR)/lib
INC_PATH := $(CC65_DIR)/asminc
INC_LIB_PATH := $(CC65_DIR)/libsrc
CFG_PATH := $(CC65_DIR)/cfg
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
all: clean first-try

.PHONY: clean
clean:
	-rm -rf bin/*
	-rm -rf release/*
	-rm -rf src/*.o

vendor/cc65:
	git submodule init

vendor/cc65/lib/c64.lib: vendor/cc65
	cd $< && make


bin:
	mkdir bin

release:
	mkdir release

release/%.d64: bin/%.prg release
	$(C1541) \
    -format firsttry,id d64 $@\
    -attach $@ \
    -write bin/first-try.prg first-try


bin/%.prg: $(SRCDIR)/%.asm
	$(CL) \
    -o $@ \
    --cfg-path $(CFG_PATH) \
    --asm-include-dir $(INC_PATH) \
    --asm-include-dir $(INC_LIB_PATH) \
    --lib c64.lib \
    -Ln first-try.sym \
    -m first-try.map \
    -L $(LIB_PATH) \
    -u __EXEHDR__ \
    -t c64 \
    -C c64-asm.cfg $^

# %: release/%.d64
# 	$(VICE) \
#     $<

# %: bin/%.prg
# 	/Applications/VirtualC64.app/Contents/MacOS/VirtualC64 $<

%: release/%.d64
	/Applications/C64Debugger.app/Contents/MacOS/C64Debugger -pass -autorundisk -d64 $< 
