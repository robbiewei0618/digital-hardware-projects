# project 03 verification (Verilator): one build per operand size.
#   make [NUM=n]    8x8 and 16x8 are exhaustive, 16x16 random + corners
SHELL  := /bin/bash
SIZES  := 8x8 16x8 16x16
.PHONY: all clean
all:
	@rc=0; for s in $(SIZES); do $(MAKE) -s -f size.mk SIZE=$$s || rc=1; done; exit $$rc
clean:
	rm -rf build_* logs
