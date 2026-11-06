# Bug log — project 02

Bugs found by the verification environment in [`verif/`](verif/) (exact
reference model, SVA, coverage), in the order they were fixed. Every fix is
its own commit, so `git log -- 02-fp-fxp-add-mul/rtl` shows the change next
to this entry. Error counts are from the default regression
(`make verif`: 484 directed + 200 000 random vectors, seed 1).

| # | DUT | Found by | Effect before the fix |
|---|-----|----------|-----------------------|
| 1 | `FLP_Multiplier` | scoreboard + `a_exp_sum` (white-box SVA) | 77 149 / 200 493 wrong results (38 %); course TB 43 / 100 |
| 2 | `FLP_Multiplier`, `FLP_Multiplier_4` | scoreboard (all-ones mantissa operands) | 20 / 200 493 results 1 ULP low; course TB 100 / 100 |
| 3 | `FXP_mul` | scoreboard + `cp_sat` coverage | saturation never happened: 100 182 / 200 494 overflowing products wrapped around |
| 4 | `FLP_adder`, `FLP_adder_4`, `FLP_adder_7` | scoreboard (directed `x + x`) | every sum that carries out (≥ 2× the larger operand's leading bit) flushed to 0: `1.0 + 1.0 = 0`; 6 728 / 200 493 per adder; course TB 100 / 100 |
| 5 | `FLP_adder_4`, `FLP_adder_7` | scoreboard (back-to-back Inf operands) | Inf results took the sign of the operand *currently at the input*, not of the one in flight: 3 959 / 200 491 wrong |
| 6 | `FLP_adder`, `FLP_adder_4`, `FLP_adder_7` | scoreboard + `x_effsub_round` coverage | effective subtractions with a far-away small operand rounded 1 ULP high: 3 372 / 200 493 per adder |

---

## 1. `FLP_Multiplier`: exponent arithmetic silently became unsigned

**Symptom.** Products returned `0` or `±Inf` whenever one operand had a
large exponent and the other a small one, e.g. `0x558b4567 * 0x397b23c6`
gave `0x00000000` instead of `0x4f88a082`. The bound assertion
`a_exp_sum` (recomputes the exponent in 32-bit signed arithmetic) fired on
the same vectors: `exp_sum=875, expected -149`.

**Root cause.** In

```verilog
wire signed [10:0] exp_sum = exp_a_s + exp_b_s
                           + ((shift_to_46 == -7'sd1) ? 11'sd1 : 11'sd0)
                           - ((shift_to_46 > 7'sd0)  ? {{5{1'b0}}, shift_to_46[5:0]} : 11'sd0);
```

the concatenation `{{5{1'b0}}, ...}` is *unsigned*. One unsigned operand
makes the whole expression unsigned (IEEE 1800 §11.8.1), so the 10-bit
signed exponents `exp_a_s` / `exp_b_s` were **zero-extended** to 11 bits
instead of sign-extended. Any negative unbiased exponent (operand < 1.0)
turned into a large positive number.

**Fix.** Build the normalisation adjustment as a signed value first
(`norm_adj`, every operand signed) and add it to the signed exponents.

**Why the course testbench missed most of it.** It does catch it (43/100),
but only because its random operands happen to mix magnitudes; it gives
no hint *where* the error is. The white-box SVA pointed straight at the
exponent adder.

## 2. Multipliers: sticky bit lost when the product is normalised right

**Symptom.** After fix 1, both multipliers were still 1 ULP low on a few
products whose mantissas are all ones, e.g.
`0xc03fffff * 0x403fffff` gave `0xc10ffffe` instead of `0xc10fffff`.

**Root cause.** A 24×24-bit significand product lies in [1, 4). When it
is ≥ 2 the design shifts it right by one (`prod >> 1`) but the bit shifted
out was not ORed into the sticky bit. For `0xBFFFFF²` = `0x8FFFFE800001`
the shifted value has guard = 1 and all lower bits 0 — a perfect tie, so
ties-to-even kept the even value — but the dropped LSB was 1, so the exact
value was *above* the half-way point and had to round up.

**Fix.** `sticky |= prod[0]` when the right shift is taken (in
`FLP_Multiplier_4` the dropped bit is carried through the stage-1
register as `r1_shift_sticky`).

**Why the course testbench missed it.** It needs guard = 1 *and* the 22
lower bits all zero — about one random product in 2²³. The corpus here hits
it through mantissa patterns (all ones, single bits) rather than uniform
random values.

## 3. `FXP_mul`: the saturation logic could never fire

**Symptom.** Every product outside the Q15.16 range wrapped around instead
of clamping, e.g. `0x7ffffffc * 0x00020000` (≈ 32768 × 2) gave
`0xfffffff8` instead of `0x7fffffff`.

**Root cause.** The 64-bit product was rounded and then compared with the
32-bit limits — but it had already been narrowed to 32 bits:

```verilog
wire signed [WIDTH-1:0] keep    = product_full >>> FRAC;   // top bits dropped here
...
wire sat_hi = (rounded > SAT_MAX);  // a 32-bit value is never > the 32-bit max
```

`sat_hi` / `sat_lo` were constant 0, so synthesis would have removed the
whole saturation path.

**Fix.** Keep the shifted value at full width, round with one extra bit,
compare against the sign-extended limits, and only then narrow.

**Coverage note.** This is the textbook case for functional coverage: the
`cp_sat.sat` bin can only be hit when saturation is *expected*, and a
scoreboard is needed to notice that the DUT did not saturate. The course
testbench never exercised overflow (it also checked a different, 64-bit
interface — see the project README).

## 4. Adders: `1.0 + 1.0 = 0` — the same unsigned-expression trap

**Symptom.** Any addition whose significand sum carries out — the result
needs a 1-bit right shift — returned zero: `0x3f800000 + 0x3f800000`
(1 + 1) gave `0x00000000`, `3 + 1` gave `0x00800000`. All three adders.

**Root cause.**

```verilog
wire signed [9:0] exp_norm_pre = {{1{exp_big_s[8]}}, exp_big_s} - shift;
```

`shift` is `-1` for the right-shift case, but the concatenation on the left
is unsigned, so the subtraction is unsigned and `-1` is zero-extended to
`+127`: the exponent drops by 127 and the result underflows to 0. (Bug 1
in the multiplier is the same mistake.)

**Fix.** `$signed({exp_big_s[8], exp_big_s}) - shift`.

**Why the course testbench missed it.** Its 100 vectors are random bit
patterns; a carry-out needs equal signs *and* nearly equal exponents, which
none of them had. The directed corner matrix here contains `x + x` for
every corner value, so the bug showed up in the first 200 vectors.

## 5. Pipelined adders: Inf sign read from the wrong pipeline stage

**Symptom.** `+Inf + 1e-7` came out as `-Inf` in `FLP_adder_4` and
`FLP_adder_7` (never in the combinational `FLP_adder`), and only when the
*next* vector had a different sign.

**Root cause.** The last stage builds the Inf / NaN result from the
registered `is_inf` / `is_nan` flags, but takes the signs straight from the
module inputs:

```verilog
wire inf_sign = r1_a_inf ? a[31] : b[31];                 // a, b are already the next vector
... (r1_a_inf & r1_b_inf & (a[31] ^ b[31])) ? res_nan ...  // same for Inf - Inf
```

When the combinational adder was cut into stages, the flags were
registered but these two sign bits were not. In `FLP_adder_7` the signs
were 6 stages stale.

**Fix.** Carry `sign_a` / `sign_b` through the pipeline next to the flags.

**Why the course testbench missed it.** It has no Inf operands, and it
holds each input for a full cycle per vector, so even a stale read would
often see the same value. A stream that changes every cycle plus
special-value operands is what exposes stage-alignment mistakes.

## 6. Adders: effective subtraction rounded on the wrong side

**Symptom.** `0x47c00000 + 0xbb97ee63` (98304 − 0.0046) returned
`0x47c00000` unchanged; the correctly rounded result is `0x47bfffff`.
Always an effective subtraction, always 1 ULP too large.

**Root cause.** The datapath kept two bits below the result LSB (Q3.25)
and collected the bits shifted out during alignment into a separate
`sticky_from_align`, ORed in *after* the addition. For an addition that is
fine. For a subtraction it is not: the discarded bits make the true
difference slightly **smaller** than `big − truncated(small)`, but a sticky
bit ORed in afterwards says the value is slightly *larger*. Near a rounding
boundary the decision flips. In the example the truncated difference sits
exactly on the half-way point, the real one is just below it.

Two bits were also too few: after an effective subtraction the result can
need a 1-bit left shift, which consumes one of them, leaving no separate
round and sticky bits.

**Fix.** Standard guard/round/sticky datapath: the mantissa is widened to
29 bits (three bits below the LSB) and the alignment sticky is *jammed*
into bit 0 of the shifted operand before the add/subtract, so it takes
part in the subtraction as a borrow. Applied to all three adders.

**Why the course testbench missed it.** Random bit patterns rarely produce
a difference that lands within one alignment-sticky of a half-way point.
The coverage cross `x_effsub_round` (effective subtraction × rounding
outcome) is what this stimulus targets.
