# 02 — IEEE-754 FP32 adders and multipliers, fixed-point add/multiply

| File | Function | Latency |
|---|---|---:|
| `rtl/FLP_adder.v` | FP32 adder, combinational | 0 |
| `rtl/FLP_adder_4.v` | FP32 adder, pipelined | 3 |
| `rtl/FLP_adder_7.v` | FP32 adder, 7-stage pipeline | 7 |
| `rtl/FLP_Multiplier.v` | FP32 multiplier, combinational (`FLP_mul` + wrapper) | 0 |
| `rtl/FLP_Multiplier_4.v` | FP32 multiplier, pipelined | 2 |
| `rtl/FXP_adder.v` | 32-bit two's-complement adder | 0 |
| `rtl/FXP_mul.v` | Q15.16 multiplier, round-to-nearest-even, saturating | 0 |

All FP units: round-to-nearest-even, subnormal inputs, results that are tiny
after rounding flush to a signed zero, overflow to ±Inf, canonical qNaN.
`rtl/archive/` keeps the earlier adder iterations (the `_84` / `_95` files
were named after their course-testbench scores).

## Verification
* `make legacy` — course testbench once per DUT. Its pipeline check assumes
  `PIPE−1` register stages, so the 7-stage adder and the 2-stage multiplier get
  their real depth passed in (`PIPE_OVERRIDE`). `FXP_mul` is Q15.16 while the
  course testbench expects a raw 64-bit product, so it is checked only by
  `make verif`.
* `make verif` — all seven DUTs on one operand stream, bit-exact against
  `common/fpref`: a 484-pair special-value matrix plus 200 000 biased random
  vectors. SVA: output contract, commutativity (operand-swapped second
  instance), white-box exponent / normalisation checks bound into the RTL.
  Coverage: operand-class cross, rounding outcome × effective subtraction,
  alignment distance, flush / overflow, FXP saturation and ties — 100 %.

**[BUGS.md](BUGS.md)** — seven bugs, e.g. `1.0 + 1.0 = 0` in every adder.
