# 03 — Signed multipliers and sign-extension reduction

Six two's-complement M×N multipliers (parameterised, tested at 8×8, 16×8,
16×16):

| File | Architecture |
|---|---|
| `rtl/multiply_op.v` | Verilog `*` (reference) |
| `rtl/multiply_row.v` | row of sign-extended partial products |
| `rtl/multiply_row_opt.v` | row with sign-extension bits reduced to a constant |
| `rtl/multiply_mbw.v` | modified Baugh-Wooley |
| `rtl/multiply_booth.v` | radix-4 Booth recoding |
| `rtl/multiply_booth_opt.v` | radix-4 Booth with sign-extension reduction |

## Verification
* `make legacy` — course testbench with the course vectors at all three sizes.
  (The original `tb_16x16.v` / `tb_16x8.v` passed even when the vector files
  were missing, because `x === x`.)
* `make verif` — **exhaustive** at 8×8 (65 536 pairs) and 16×8 (16.8 M pairs),
  corner matrix + 2 M random pairs at 16×16; an assertion that all six
  implementations agree on every sample; coverage of operand corners
  (min, −1, 0, 1, max) and of every radix-4 Booth digit (−2 … +2) per group.
  No RTL bugs.
