# 03 - signed multipliers: operator / row / sign-extension-reduced row /
#      modified Baugh-Wooley / Booth / optimised Booth
#   make legacy   course testbenches (Icarus Verilog), 8x8 / 16x8 / 16x16
#   make verif    exhaustive 8x8 + 16x8, random+corner 16x16 with SVA/coverage
SHELL := /bin/bash
RUN   := ../common/mk/legacy_run.sh
RTL   := $(addprefix ../../,$(wildcard rtl/*.v))
OK    := "ALL TESTS PASSED"
BAD   := "Unable to open|FAIL"
.PHONY: all legacy verif clean
all: legacy verif

legacy:
	@rc=0; \
	$(RUN) mult_8x8   $(OK) $(BAD) tb/legacy -- tb_with_file.v $(RTL) || rc=1; \
	$(RUN) mult_16x8  $(OK) $(BAD) tb/legacy -- -Ptb_with_file.M=16 -Ptb_with_file.N=8 \
	  -Ptb_with_file.A_FILE=\"data/16x8_a.txt\" -Ptb_with_file.B_FILE=\"data/16x8_b.txt\" \
	  -Ptb_with_file.ANS_FILE=\"data/16x8_ans.txt\" tb_with_file.v $(RTL) || rc=1; \
	$(RUN) mult_16x16 $(OK) $(BAD) tb/legacy -- -Ptb_with_file.M=16 -Ptb_with_file.N=16 \
	  -Ptb_with_file.A_FILE=\"data/16x16_a.txt\" -Ptb_with_file.B_FILE=\"data/16x16_b.txt\" \
	  -Ptb_with_file.ANS_FILE=\"data/16x16_ans.txt\" tb_with_file.v $(RTL) || rc=1; \
	exit $$rc

verif:
	$(MAKE) -C verif

clean:
	rm -rf build
	$(MAKE) -C verif clean
