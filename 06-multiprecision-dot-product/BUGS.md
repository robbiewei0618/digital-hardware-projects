# Bug log — project 06

Found by the verification environment in [`verif/`](verif/). Counts are
from 100 000 random vectors (FP32 and FP16 mixed cycle by cycle), seed 1.

| # | Where | Found by | Effect |
|---|-------|----------|--------|
| 0 | course answer file `ans16.txt` | exact rational reference | 484 / 1000 FP16 answers are not the fused result — the **reference** was wrong, not the DUT |
| 1 | `DP4` (v1), `DP4_pipeline_CG` (v1) | window-bound checker + `a_ftz16` SVA | far-away products added with the wrong weight; FP16 subnormal results; cancelling sums returned ±Inf |
| 2 | all three | scoreboard | flush-to-zero decided *before* rounding: 2 / 100 000 results just below the smallest normal flushed instead of rounding up |

Documented behaviour (not bugs, checked as such by the testbench): the
DP4 has no Inf/NaN inputs, reads subnormal inputs as zero, flushes tiny
results to zero, returns `+0` for every zero result, and keeps a finite
alignment window (see "window bound" below).

---

## 0. The course's FP16 answers are not a fused dot product

`tb/legacy/gen_answers.py` (course script) evaluates FP16 as
`round(round(round(p1)+round(p2)) + round(round(p3)+round(p4)))` — every
product and partial sum is rounded to FP16. The hardware is *fused*: exact
products, exact sum, one rounding. The two differ on 484 of the 1000 course
vectors, so the course testbench scored the (correct) design at 51.6 %.

An exact rational re-computation (`tb/legacy/gen_answers_fused.py`) agrees
with the RTL on all 1000 vectors; it produced `data/ans16_fused.txt`,
which `make legacy` now uses. `make legacy-ta16` still shows the old result.

## 1. Combinational and clock-gated versions had a weaker datapath

The three designs were three separate implementations. `DP4_pipeline` was
the most refined one; the combinational `DP4` and `DP4_pipeline_CG` still
had the earlier datapath, with these defects:

* **Alignment shift saturated instead of flushing.**
  ```verilog
  wire [6:0] shift1 = (diff1 > max_shift) ? max_shift : diff1[6:0];
  wire [51:0] m_aligned1 = m_p1_ext >> shift1;
  ```
  A product 60 binades below the largest was shifted by only 51 — added
  with a weight 2⁹ too large — instead of becoming a sticky bit. Invisible
  while the large terms dominate; when they cancel, the misplaced small term
  *is* the result. (Patching only this removed 254 of the 368 violations in
  `DP4`.)
* **FP16 results could be subnormal** (`a_ftz16` assertion, 341 hits),
  although the design flushes FP32 tiny results.
* **Cancelling sums returned ±Inf** in `DP4_pipeline_CG` and `DP4`, and the
  CG version also produced NaN encodings for underflowing FP16/FP32 results
  (1 773 exact mismatches, 14 011 window violations, 1 261 SVA failures).

**Fix.** Instead of repairing two diverging copies, the datapath of
`DP4_pipeline` became the single source `rtl/dp4_datapath.v`
(`dp4_stage1`…`dp4_stage4`). `DP4` chains the four stages without
registers, `DP4_pipeline` registers between them, and `DP4_pipeline_CG`
uses the same registers with enables (valid bit travelling with the data,
output forced to `+0` for idle all-zero vectors). The three now produce
bit-identical results; the originals are in `rtl/archive/`.

## 2. Flush-to-zero before rounding

`stage4` flushed every result with exponent ≤ 0 *before* rounding. A value
in `[(1 − 2⁻ᵖ)·2^emin, 2^emin)` rounds up to the smallest normal number
under round-to-nearest, so it must not be flushed. Seen twice in FP16, e.g.
`x = 9ffb 85d7 9800 9739, y = 9c01 a7ff 9625 a336` gave `0000` instead of
`0400`. Fixed by flushing only if the exponent is still 0 after rounding.

---

## The window bound

A fused dot product with a finite alignment window cannot be correctly
rounded in every case: if `x1*y1 = −x2*y2` exactly and `x3*y3` is 80
binades smaller, the result is `x3*y3 + x4*y4`, whose bits fell out of the
window. Exact hardware would need a ~560-bit (Kulisch) accumulator for FP32.

So the testbench splits the check:

* products of **one sign** (no cancellation possible): the result must be
  the correctly rounded value, bit for bit;
* **mixed signs**: correctly rounded, *or* within
  `ulp(result) + 4·2^(Emax − 48)` of the exact value, where `Emax` is the
  exponent of the largest product (`fpref_dot4_window_ok`, computed exactly).

After the fixes, 3 911 of 200 006 random results (2 %, all with
cancellation) use the window allowance; none exceeds the bound.
