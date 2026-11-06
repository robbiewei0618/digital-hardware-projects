# Computer Arithmetic in Verilog — RTL and Verification

[![CI](https://github.com/robbiewei0618/digital-hardware-projects/actions/workflows/ci.yml/badge.svg)](https://github.com/robbiewei0618/digital-hardware-projects/actions/workflows/ci.yml)
![Simulators](https://img.shields.io/badge/simulators-Icarus%2012%20%7C%20Verilator%205.054-blue)

Six graduate-course projects on computer arithmetic, from integer adders to an
IEEE-754 fused multiply-add and a reconfigurable FP32/FP16 dot-product unit.
Each project keeps its RTL, synthesis scripts and report, and now also has:

* the **course testbench**, made portable so it runs on Icarus Verilog (`make legacy`);
* a new **self-checking verification environment** on Verilator (`make verif`):
  an exact reference model, a latency-aware scoreboard, SystemVerilog
  assertions and functional coverage.

The new environments found **16 RTL bugs and one wrong course answer file**
that the course testbenches had passed. Each bug is fixed in its own commit and
written up in the project's `BUGS.md` — symptom, root cause, fix, and why the
original test did not see it.

<!-- results:begin -->
| Project | Checker | Checks | Errors | Result |
|---|---|---:|---:|:---:|
| 01-adder-modeling-styles | adders (7 DUTs) | 200,000 | 0 | ✅ |
| 02-fp-fxp-add-mul | FXP_adder | 200,494 | 0 | ✅ |
| 02-fp-fxp-add-mul | FXP_mul | 200,494 | 0 | ✅ |
| 02-fp-fxp-add-mul | FLP_adder | 200,493 | 0 | ✅ |
| 02-fp-fxp-add-mul | FLP_adder_4 | 200,491 | 0 | ✅ |
| 02-fp-fxp-add-mul | FLP_adder_7 | 200,487 | 0 | ✅ |
| 02-fp-fxp-add-mul | FLP_Multiplier | 200,493 | 0 | ✅ |
| 02-fp-fxp-add-mul | FLP_Multiplier_4 | 200,492 | 0 | ✅ |
| 03-sign-extension-multipliers | multipliers_8x8 | 65,536 | 0 | ✅ |
| 03-sign-extension-multipliers | multipliers_16x8 | 16,777,216 | 0 | ✅ |
| 03-sign-extension-multipliers | multipliers_16x16 | 2,000,049 | 0 | ✅ |
| 04-truncated-multipliers | exact (op/row/arr) | 65,536 | 0 | ✅ |
| 04-truncated-multipliers | trunc_const_row (error/ULP: min -0.5039  max 0.8750  mean 0.3086) | 65,536 | 0 | ✅ |
| 04-truncated-multipliers | trunc_var_array (error/ULP: min -0.4727  max 0.8477  mean 0.1865) | 65,536 | 0 | ✅ |
| 04-truncated-multipliers | exact (op/row/arr) | 2,000,049 | 0 | ✅ |
| 04-truncated-multipliers | trunc_const_row (error/ULP: min -0.6875  max 0.9375  mean 0.1996) | 2,000,049 | 0 | ✅ |
| 04-truncated-multipliers | trunc_var_array (error/ULP: min -0.5999  max 0.8011  mean 0.1100) | 2,000,049 | 0 | ✅ |
| 05-fused-multiply-add | FXP_FMA | 210,658 | 0 | ✅ |
| 05-fused-multiply-add | FLP_FMA | 210,657 | 0 | ✅ |
| 05-fused-multiply-add | FLP_FMA_4 | 210,654 | 0 | ✅ |
| 06-multiprecision-dot-product | DP4 | 196,097 | 0 | ✅ |
| 06-multiprecision-dot-product | DP4 (window) | 3,912 | 0 | ✅ |
| 06-multiprecision-dot-product | DP4_pipeline | 196,094 | 0 | ✅ |
| 06-multiprecision-dot-product | DP4_pipeline (window) | 3,912 | 0 | ✅ |
| 06-multiprecision-dot-product | DP4_pipeline_CG | 196,094 | 0 | ✅ |
| 06-multiprecision-dot-product | DP4_pipeline_CG (window) | 3,912 | 0 | ✅ |

| Project | Course testbenches (Icarus) | Functional coverage | SVA failures |
|---|---|---|---:|
| 01-adder-modeling-styles | 1/1 pass | cg_add 100.0 % | 0 |
| 02-fp-fxp-add-mul | 6/6 pass | cg_fadd 100.0 %, cg_fmul 100.0 %, cg_fxmul 100.0 % | 0 |
| 03-sign-extension-multipliers | 3/3 pass | cg_mul 100.0 % | 0 |
| 04-truncated-multipliers | 2/2 pass | cg_trunc 100.0 % | 0 |
| 05-fused-multiply-add | 4/4 pass | cg_fma 100.0 % | 0 |
| 06-multiprecision-dot-product | 6/6 pass | cg_dp4 100.0 % | 0 |
<!-- results:end -->

*Generated from `make test` by `scripts/summarize.py` (seed 1). CI re-runs everything on every push.*

## The projects

| # | Folder | Designs | What the new verification does | Bugs found |
|---|--------|---------|--------------------------------|-----------:|
| 01 | [`01-adder-modeling-styles`](01-adder-modeling-styles) | 32-bit adder as behavioural / dataflow / gate-level ripple-carry, each also registered | random + carry-chain-steered operands, registered-vs-combinational SVA, carry-run coverage | 0 (testbench bug fixed) |
| 02 | [`02-fp-fxp-add-mul`](02-fp-fxp-add-mul) | FP32 adder (comb., 3- and 7-stage), FP32 multiplier (comb., 2-stage), FXP adder, Q15.16 multiplier | exact reference, directed special-value matrix + biased random, white-box and metamorphic SVA | **7** — [BUGS.md](02-fp-fxp-add-mul/BUGS.md) |
| 03 | [`03-sign-extension-multipliers`](03-sign-extension-multipliers) | signed multipliers: operator, row, sign-extension-reduced row, modified Baugh-Wooley, radix-4 Booth (+ optimised) | exhaustive 8×8 and 16×8, random 16×16, six-way equivalence assertion, Booth-digit coverage | 0 |
| 04 | [`04-truncated-multipliers`](04-truncated-multipliers) | unsigned truncated multipliers with constant / variable correction, array and row multipliers | exhaustive 8×8 error analysis (min/max/mean in ULP), random 16×16 | **1** — [BUGS.md](04-truncated-multipliers/BUGS.md) |
| 05 | [`05-fused-multiply-add`](05-fused-multiply-add) | FXP FMA, FP32 FMA (comb.) and 4-stage FMA | 10 648 corner triples + cancellation / alignment / subnormal scenarios, IEEE mode incl. subnormal results | **6** (+1 in the rewrite) — [BUGS.md](05-fused-multiply-add/BUGS.md) |
| 06 | [`06-multiprecision-dot-product`](06-multiprecision-dot-product) | FP32/FP16 fused 4-term dot product: comb., 4-stage, clock-gated | precision switching every cycle, exact check for same-sign terms, window error bound under cancellation | **2** + wrong course answers — [BUGS.md](06-multiprecision-dot-product/BUGS.md) |

Highlights from the bug logs:

* `1.0 + 1.0 = 0` in all three FP adders, and products of mixed-magnitude
  operands returning 0 or Inf: two instances of the same Verilog trap — one
  unsigned operand (a concatenation) makes the whole expression unsigned, so
  negative exponents were zero-extended (02 #1, #4).
* Pipelined adders took the Inf sign from the *next* input vector because two
  sign bits were never registered (02 #5).
* A Q15.16 multiplier whose saturation logic could never fire (02 #3) — the
  kind of hole functional coverage exists for.
* The course's FP16 answer file was itself wrong for 484 of 1000 vectors: it
  rounds after every product and partial sum, while the hardware is fused. An
  exact rational re-computation showed the design was right (06 #0).

## How the verification works

**Reference model** — [`common/fpref`](common/fpref) is a small C library
(DPI-C) that evaluates add, multiply, fused multiply-add and the fused
4-term dot product *exactly* in a 640-bit integer and rounds once, for binary32
and binary16, with IEEE, flush-to-zero or denormals-are-zero behaviour and
rounding flags for coverage. The model is checked before it is trusted:
`make selftest` compares 2 M random and corner vectors against the host FPU
(`+`, `*`, `fmaf`) and the FTZ / binary16 paths against exact rational
arithmetic in Python.

**Stimulus** — directed corner matrices (signed zeros, subnormal and normal
limits, ±1, max finite, Inf, quiet and signalling NaN) followed by biased
random scenarios: cancellation, controlled exponent gaps, exponent sums at the
underflow/overflow edges, constructed rounding ties, subnormal × huge.
Generation is procedural (`$urandom` with weights) rather than `randomize()`:
Verilator solves class constraints with an external SMT solver at about 5 ms
per call, too slow for 10⁵–10⁶ vectors per run.

**Scoreboard** — every DUT of a project sees the same stream every cycle;
results are compared bit-exactly at each DUT's own latency, so a pipeline that
is one stage off fails immediately.

**Assertions** — an output contract per DUT (no X, flush-to-zero where the
design promises it, canonical NaN), white-box checks bound into the RTL (e.g.
the multiplier exponent recomputed independently; normalisation invariants),
and metamorphic checks (a second instance with swapped operands must agree).

**Coverage** — operand-class crosses, rounding outcome × effective operation,
alignment distance, cancellation depth, flush/overflow, precision switching;
every unreachable bin is excluded with the reason in the code.

## Running it

Needs Icarus Verilog (≥ 11), Verilator (≥ 5.0, built with `--timing`
support), GCC and Python 3.

```bash
make test          # selftest + every course testbench + every verification run
make legacy        # course testbenches only (Icarus)
make verif         # new verification only (Verilator)
make -C 02-fp-fxp-add-mul/verif SEED=7 NUM=1000000    # one project, other seed / length
```

## Repository layout

```
common/fpref/    exact IEEE-754 reference model (C, DPI) + its self-tests
common/verif/    shared SV package (DPI imports, generators, scoreboard) and output SVA
common/mk/       shared Verilator rules, course-testbench runner
NN-project/
  rtl/           final designs (rtl/archive/: earlier iterations, kept for history)
  tb/legacy/     course testbench and vectors, runnable with Icarus
  verif/         new testbench, assertions, coverage
  syn/ apr/      Design Compiler / PrimeTime / Innovus scripts (and netlists where kept)
  docs/          course report, waveforms, design notes
  BUGS.md        what the verification found
```

## Synthesis results

From the original course reports (Synopsys Design Compiler, TSRI N16 ADFP
library, delay-optimised run). They describe the designs **before** the fixes
above; most fixes are a few gates, but the FMA and DP4 datapaths were
restructured and have not been re-synthesised.

| Design | Area (µm²) | Critical path (ns) | Power (mW) |
|---|---:|---:|---:|
| FP32 adder, combinational | 1035.4 | 0.88 | 0.685 |
| FP32 adder, 7-stage | 1099.6 | 0.45 / stage | 2.370 |
| FP32 multiplier, combinational | 1303.8 | 0.82 | 2.011 |
| FP32 multiplier, pipelined | 1482.2 | 0.62 / stage | 1.864 |
| 16×16 truncated multiplier, constant correction | 648.8 | 0.46 | 1.109 |
| 16×16 truncated multiplier, variable correction | 524.4 | 0.61 | 0.857 |
| 16×16 array multiplier (full width) | 847.0 | 0.60 | 1.378 |

Full tables (area / delay / balanced constraints, per-stage delays, power
breakdown) are in each project's `docs/report.docx`.
