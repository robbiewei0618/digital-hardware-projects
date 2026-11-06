# 02 - IEEE-754 FP adders/multipliers (combinational + pipelined) and FXP add/mul
#   make legacy   course testbench, once per DUT (Icarus Verilog)
#   make verif    exact-reference testbench with SVA + coverage (Verilator)
SHELL := /bin/bash
RUN   := ../common/mk/legacy_run.sh
TB    := ALU_testbench.v
R     := ../../rtl
SCORE := "Score: 100|All testdata correct"
.PHONY: all legacy verif clean
all: legacy verif

# The course TB compares a pipelined output (PIPE-2) cycles after the input,
# i.e. it assumes PIPE-1 register stages. FLP_adder_7 has 7 and
# FLP_Multiplier_4 has 2, so their depth is passed explicitly.
# FXP_mul is a Q15.16 rounding/saturating multiplier; the course TB expects a
# raw 64-bit product, so it is checked only by `make verif`.
legacy:
	@rc=0; \
	$(RUN) FXP_adder        $(SCORE) "" tb/legacy -- -DFXP_adder        $(TB) $(R)/FXP_adder.v        || rc=1; \
	$(RUN) FLP_adder        $(SCORE) "" tb/legacy -- -DFLP_adder        $(TB) $(R)/FLP_adder.v        || rc=1; \
	$(RUN) FLP_adder_4      $(SCORE) "" tb/legacy -- -DFLP_adder_4      $(TB) $(R)/FLP_adder_4.v      || rc=1; \
	$(RUN) FLP_adder_7      $(SCORE) "" tb/legacy -- -DFLP_adder_7 -DPIPE_OVERRIDE=8 $(TB) $(R)/FLP_adder_7.v || rc=1; \
	$(RUN) FLP_Multiplier   $(SCORE) "" tb/legacy -- -DFLP_Multiplier   $(TB) $(R)/FLP_Multiplier.v   || rc=1; \
	$(RUN) FLP_Multiplier_4 $(SCORE) "" tb/legacy -- -DFLP_Multiplier_4 -DPIPE_OVERRIDE=3 $(TB) $(R)/FLP_Multiplier_4.v || rc=1; \
	exit $$rc

verif:
	$(MAKE) -C verif

clean:
	rm -rf build
	$(MAKE) -C verif clean
