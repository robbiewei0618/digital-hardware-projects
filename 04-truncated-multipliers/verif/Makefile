# project 04 verification (Verilator): 8x8 exhaustive, 16x16 random + corners
SHELL  := /bin/bash
SIZES  := 8 16
.PHONY: all clean
all:
	@rc=0; for n in $(SIZES); do $(MAKE) -s -f size.mk N_W=$$n || rc=1; done; exit $$rc
clean:
	rm -rf build_* logs
