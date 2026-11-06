# =============================================================================
# Computer-arithmetic RTL projects - top-level regression
#   make test      fpref self-test + every course testbench + every verif env
#   make legacy    only the course testbenches   (needs: iverilog)
#   make verif     only the new verification     (needs: verilator >= 5.0)
#   make selftest  check the reference model against the host FPU / rationals
# =============================================================================
SHELL    := /bin/bash
PROJECTS := 01-adder-modeling-styles 02-fp-fxp-add-mul 03-sign-extension-multipliers \
            04-truncated-multipliers 05-fused-multiply-add 06-multiprecision-dot-product
.PHONY: test legacy verif selftest clean

test: selftest legacy verif

legacy:
	@rc=0; for p in $(PROJECTS); do echo "== $$p"; $(MAKE) -s -C $$p legacy || rc=1; done; exit $$rc

verif:
	@rc=0; for p in $(PROJECTS); do echo "== $$p"; $(MAKE) -s -C $$p verif || rc=1; done; exit $$rc

selftest:
	@mkdir -p build
	gcc -O2 -Wall -Wextra -o build/fpref_selftest common/fpref/selftest.c common/fpref/fpref.c -lm
	./build/fpref_selftest 2000000
	gcc -O2 -shared -fPIC -o build/libfpref.so common/fpref/fpref.c
	python3 common/fpref/fpref_oracle.py build/libfpref.so 5000

clean:
	rm -rf build
	@for p in $(PROJECTS); do $(MAKE) -s -C $$p clean; done
