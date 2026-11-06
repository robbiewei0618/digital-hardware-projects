# 05 - fused multiply-add: FXP FMA, FP32 FMA (combinational) and 4-stage FMA
#   make legacy   course testbench (Icarus Verilog), normal + special vectors
#   make verif    exact single-rounding reference, SVA + coverage (Verilator)
SHELL := /bin/bash
RUN   := ../common/mk/legacy_run.sh
TB    := ALU_FLP_FMA_testbench.v
R     := ../../rtl
OK    := "ALL TESTS PASSED"
SPECIAL := -DTD=\"data_special\" -DDATA_NUM=14
.PHONY: all legacy verif clean
all: legacy verif

# FXP_FMA has no course vector set (the course files are FP32); it is
# checked by `make verif` against the course definition (a*b + c)[63:32].
legacy:
	@rc=0; \
	$(RUN) FLP_FMA_normal    $(OK) "" tb/legacy -- -DTEST_FLP_FMA   $(TB) $(R)/FLP_FMA.v   || rc=1; \
	$(RUN) FLP_FMA_special   $(OK) "" tb/legacy -- -DTEST_FLP_FMA   $(SPECIAL) $(TB) $(R)/FLP_FMA.v   || rc=1; \
	$(RUN) FLP_FMA_4_normal  $(OK) "" tb/legacy -- -DTEST_FLP_FMA_4 $(TB) $(R)/FLP_FMA_4.v || rc=1; \
	$(RUN) FLP_FMA_4_special $(OK) "" tb/legacy -- -DTEST_FLP_FMA_4 $(SPECIAL) $(TB) $(R)/FLP_FMA_4.v || rc=1; \
	exit $$rc

verif:
	$(MAKE) -C verif

clean:
	rm -rf build tb/legacy/output.txt
	$(MAKE) -C verif clean
