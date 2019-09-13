TARGETS = main test
EXECUTABLES = main.nes test.nes
TOOLSDIR := /usr/local/bin
AS := $(TOOLSDIR)/ca65
LD := $(TOOLSDIR)/ld65
ASFLAGS := -g
LDFLAGS := -Ln $(LABELSNAME)
LABELS_POSTFIX := labels.txt
CONFIGNAME := ../cc65/cfg/c64-asm.cfg

SRCDIR := src
LIST_POSTFIX := listing.txt
MAP_POSTFIX := map.txt

TEMPDIR := $(shell mktemp -d)

# ---------------------------------------------------------------
# Build Tasks
# ---------------------------------------------------------------
.PHONY: all
all: test.nes main.nes

.PHONY: clean
clean:
	rm -f *.listing.txt *.map.txt *.o *.nes *.wch *.csv

bin:
	mkdir bin

%.o: $(SRCDIR)/%.asm $(SRCDIR)/*.s $(SRCDIR)/tests/*.s
	$(AS) $< $(ASFLAGS) -v -I $(SRCDIR) -l $*.$(LIST_POSTFIX) -o $@ --feature force_range

%.nes: %.o
	$(LD) -Ln $*.$(LABELS_POSTFIX) -C $(CONFIGNAME) -o $@ -m $*.$(MAP_POSTFIX) -vm $<
	python3 script/labels_to_nintaco.py $*

.PHONY: test
test: test.nes
	PYTHONPATH=script python script/run_rom/run_rom.py $< &

.PHONY: main
main: main.nes
	PYTHONPATH=script python script/run_rom/run_rom.py $< &

.PHONY: bootstrap
bootstrap: tools/fceux/fceux.exe tools/nesst/nesst.exe

.PHONY: clean-tools
clean-tools:
	rm -rf tools
