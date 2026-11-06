# 01 - 32-bit adder in three modeling styles (+ registered versions)
#   make legacy   course testbench (Icarus Verilog)
#   make verif    self-checking SV testbench with SVA + coverage (Verilator)
SHELL  := /bin/bash
RUN    := ../common/mk/legacy_run.sh
RTL    := $(wildcard rtl/*.v)
.PHONY: all legacy verif clean
all: legacy verif

legacy:
	@$(RUN) adder_styles "All test patterns completed" "Mismatch" tb/legacy -- \
	  testbench.v $(addprefix ../../,$(RTL))

verif:
	$(MAKE) -C verif

clean:
	rm -rf build
	$(MAKE) -C verif clean
