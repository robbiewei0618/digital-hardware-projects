# 06 - reconfigurable FP32 / FP16 fused 4-term dot product (DP4)
#      combinational, 4-stage pipeline, and pipeline with clock gating
#   make legacy        course testbench (Icarus Verilog), FP32 and FP16
#   make legacy-ta16   FP16 against the course's original (non-fused) answers
#   make verif         exact fused reference, SVA + coverage (Verilator)
SHELL := /bin/bash
RUN   := ../common/mk/legacy_run.sh
TB    := DP4_testbench.v
R     := ../../rtl
OK    := "ALL TESTS PASSED"
F16   := -DFILE_ANS=\"data/ans16_fused.txt\"
.PHONY: all legacy legacy-ta16 verif clean
all: legacy verif

# FP16 is checked against data/ans16_fused.txt (single rounding, see
# tb/legacy/gen_answers_fused.py); FP32 against the course file.
legacy:
	@rc=0; \
	for d in DP4:TEST_DP4 DP4_pipeline:TEST_DP4_PIPELINE DP4_pipeline_CG:TEST_DP4_CG; do \
	  m=$${d%%:*}; def=$${d##*:}; \
	  $(RUN) $${m}_fp32 $(OK) "" tb/legacy -- -D$$def -DTEST_FP32 $(TB) $(R)/$$m.v || rc=1; \
	  $(RUN) $${m}_fp16 $(OK) "" tb/legacy -- -D$$def $(F16) $(TB) $(R)/$$m.v || rc=1; \
	done; exit $$rc

legacy-ta16:
	-@$(RUN) DP4_fp16_ta_answers $(OK) "" tb/legacy -- -DTEST_DP4 $(TB) $(R)/DP4.v; \
	  grep -E "Pass rate|FAILED" build/legacy/DP4_fp16_ta_answers.log | head -2

verif:
	$(MAKE) -C verif

clean:
	rm -rf build
	$(MAKE) -C verif clean
