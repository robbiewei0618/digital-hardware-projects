# Bug log — project 04

| # | DUT | Found by | Effect |
|---|-----|----------|--------|
| 1 | `mul_trunc_var_array` | exhaustive 8×8 error analysis | error up to **+1.10 ULP** (8×8) / +1.17 ULP (16×16), violating the design's own "< 1 ULP" bound in 432 of 65 536 8×8 cases; mean error +0.44 ULP |
| — | course testbench | review | checked `|p − floor| < 2^(n−1)` in *output* units, i.e. any error up to 128 (8×8) or 32 768 (16×16) ULPs passed |

## 1. Variable-correction multiplier: correction constant one ULP too large

**Symptom.** `0x74 * 0x0b` = 1276; exact upper byte 4.98, design result
`6` (error +1.016 ULP). The exhaustive 8×8 run gives an error range of
[−0.22, +1.10] ULP with mean +0.44.

**Root cause.** In a variable-correction truncated multiplier the
partial-product bits of column `R−1` are added one column up (column `R`);
that term already estimates the discarded columns. What is still needed is
the rounding constant ½ ULP = 2^(N−1), i.e. `2^(K−1)` units of column `R`.
The design added `2^K − 1` (almost a whole ULP):

```verilog
wire [4:0] total_corr = var_corr + ((1 << K) - 1);
```

A bit-level Python model of the scheme reproduces the measured error
statistics exactly for `2^K − 1`, and gives [−0.47, +0.85] ULP for `2^(K−1)`.

**Fix.** `total_corr = var_corr + (1 << (K-1))`. After the fix:

| design | 8×8 (exhaustive) min / max / mean error | 16×16 (2 M random + corners) |
|--------|----------------------------------------|------------------------------|
| `mul_trunc_const_row` (unchanged) | −0.504 / +0.875 / +0.309 ULP | −0.688 / +0.938 / +0.200 ULP |
| `mul_trunc_var_array` | −0.473 / +0.848 / +0.187 ULP | −0.600 / +0.801 / +0.110 ULP |

**Why the course testbench missed it.** Its error bound was written in the
wrong unit (`1 ULP = 2^(n−1)`, compared against the n-bit output), so it
would have accepted errors of up to 2^(n−1) output LSBs; and 100 random
vectors would rarely hit the 0.7 % of operand pairs that exceed 1 ULP.
