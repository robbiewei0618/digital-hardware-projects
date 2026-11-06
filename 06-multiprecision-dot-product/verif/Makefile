# project 06 verification (Verilator): one build per DUT because the three
# DUTs share the module name space (tb_top instantiates one of them).   make [SEED=n] [NUM=n]
SHELL  := /bin/bash
COMMON := $(abspath ../../common)
DUTS   := comb:DP4 pipe:DP4_pipeline cg:DP4_pipeline_CG
.PHONY: all
all:
	@rc=0; for d in $(DUTS); do k=$${d%%:*}; f=$${d##*:}; \
	  $(MAKE) -s -f dut.mk DUT=$$k RTL="../rtl/$$f.v ../rtl/dp4_datapath.v" || rc=1; done; exit $$rc
clean:
	rm -rf build_* logs
