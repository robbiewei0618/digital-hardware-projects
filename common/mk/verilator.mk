# =============================================================================
# common/mk/verilator.mk - shared Verilator flow for every project's verif/
#
# A project's verif/Makefile sets, *before* including this file:
#   COMMON     path to the repo's common/ directory
#   SRCS       SystemVerilog/Verilog sources (packages first)
#   CSRCS      C/C++ sources for DPI (optional)
#   TOP        top module (default tb_top)
#   RUN_ARGS   extra plusargs (optional)
# Targets: run (default), build, clean.      make SEED=7 NUM=50000
# =============================================================================
VERILATOR  ?= verilator
TOP        ?= tb_top
SEED       ?= 1
NUM        ?=
BUILD      ?= build
LOGDIR     ?= logs
RUN_ARGS   ?= +verilator+error+limit+1000000
JOBS       ?= $(shell nproc 2>/dev/null || echo 2)

VFLAGS := --binary --timing --assert --coverage-user -j $(JOBS) \
          --top-module $(TOP) -Mdir $(BUILD) -o V$(TOP) \
          -Wno-fatal -Wno-lint -Wno-style -Wno-COVERIGN -Wno-ZERODLY \
          -Wno-MULTIDRIVEN -Wno-SYMRSVDWORD -Wno-IGNOREDRETURN -Wno-STMTDLY \
          --timescale 1ns/1ps \
          -CFLAGS "-O1 -I$(COMMON)/fpref" $(EXTRA_VFLAGS)

SIMV := $(BUILD)/V$(TOP)
LOG  := $(LOGDIR)/$(TOP)_seed$(SEED).log

.PHONY: build run clean
run: $(SIMV)
	@mkdir -p $(LOGDIR)
	./$(SIMV) +verilator+seed+$(SEED) +verilator+coverage+file+$(LOGDIR)/coverage_seed$(SEED).dat $(if $(NUM),+NUM=$(NUM),) $(RUN_ARGS) 2>&1 | tee $(LOG); \
	  test $${PIPESTATUS[0]} -eq 0 && grep -q "TEST PASSED" $(LOG)

build: $(SIMV)
$(SIMV): $(SRCS) $(CSRCS) $(MAKEFILE_LIST)
	@mkdir -p $(BUILD)
	$(VERILATOR) $(VFLAGS) $(SRCS) $(CSRCS) > $(BUILD)/compile.log 2>&1 || (tail -40 $(BUILD)/compile.log; exit 1)
	@echo "built $(SIMV)"

clean:
	rm -rf $(BUILD) $(LOGDIR)
