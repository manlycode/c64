TARGETS := multi-sprite
EXECUTABLES := multi-sprite.prg
CC65_DIR := vendor/cc65
TOOLSDIR := $(CC65_DIR)/bin
AS := $(TOOLSDIR)/ca65
LD := $(TOOLSDIR)/ld65
CL := $(TOOLSDIR)/cl65
LIB_PATH := $(CC65_DIR)/lib
INC_PATH := $(CC65_DIR)/asminc
INC_LIB_PATH := $(CC65_DIR)/libsrc
# CFG_PATH := $(CC65_DIR)/cfg
CFG_PATH := ./
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
all: multi-sprite

%: release/%.d64
	/Applications/C64Debugger.app/Contents/MacOS/C64Debugger -pass -autorundisk -d64 $< 

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
    -format multisprite,id d64 $@\
    -attach $@ \
    -write bin/multi-sprite.prg multi-sprite


bin/%.prg: $(SRCDIR)/%.asm
	$(CL) \
    -o $@ \
    --asm-include-dir $(INC_PATH) \
    --cfg-path $(CFG_PATH) \
    --asm-include-dir $(INC_LIB_PATH) \
    --lib-path c64.lib \
    -Ln multi-sprite.sym \
    -m multi-sprite.map \
    -L $(LIB_PATH) \
    -u __EXEHDR__ \
    -t c64 \
    -C ./c64-asm.cfg $^

# %: release/%.d64
# 	$(VICE) \
#     $<

%: bin/%.prg
	/Applications/VirtualC64.app/Contents/MacOS/VirtualC64 $<


.PHONY: clean
clean:
	-rm -rf bin/*
	-rm -rf release/*
	-rm -rf src/*.o

