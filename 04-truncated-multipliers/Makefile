# 04 - unsigned truncated multipliers (constant / variable correction)
#   make legacy   course testbench (Icarus Verilog), 8x8 and 16x16
#   make verif    exhaustive 8x8 error analysis, random 16x16, SVA + coverage
SHELL := /bin/bash
RUN   := ../common/mk/legacy_run.sh
RTL   := $(addprefix ../../,$(wildcard rtl/*.v))
OK    := "ALL TESTS PASSED"
BAD   := "Unable to open|FAIL"
.PHONY: all legacy verif clean
all: legacy verif

legacy:
	@rc=0; \
	$(RUN) trunc_8x8   $(OK) $(BAD) tb/legacy -- TB.v $(RTL) || rc=1; \
	$(RUN) trunc_16x16 $(OK) $(BAD) tb/legacy -- -Ptb_truncated_mul.N=16 \
	  -Ptb_truncated_mul.A_FILE=\"data/16x16_a.txt\" -Ptb_truncated_mul.B_FILE=\"data/16x16_b.txt\" \
	  -Ptb_truncated_mul.ANS_FILE=\"data/16x16_ans.txt\" TB.v $(RTL) || rc=1; \
	exit $$rc

verif:
	$(MAKE) -C verif

clean:
	rm -rf build
	$(MAKE) -C verif clean
