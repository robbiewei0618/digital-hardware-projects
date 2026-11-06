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
