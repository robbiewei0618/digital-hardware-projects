# 05 — Fused multiply-add

| File | Function | Latency |
|---|---|---:|
| `rtl/FXP_FMA.v` | fixed-point `(a·b + c)[63:32]` (course definition) | 0 |
| `rtl/FLP_FMA.v` | FP32 `A·B + C`, one rounding | 0 |
| `rtl/FLP_FMA_4.v` | FP32 FMA, 4-stage pipeline | 4 |
| `rtl/fma_datapath.v` | shared datapath: unpack/multiply/align → add → normalise → round/pack | |

Round-to-nearest-even with IEEE-754 subnormal inputs **and results**, Inf/NaN
rules (Inf·0, Inf − Inf), canonical qNaN, signed zeros.

The original FP designs are in `rtl/archive/` (`FLP_FMA_v1.v`,
`FLP_FMA_4_v1.v`, plus two earlier iterations); their chat-style design notes,
which had been pasted after `endmodule`, are in `docs/`.

## Verification
* `make legacy` — course testbench, normal and special vector sets. It
  accepts any result within 0.1 % relative error or 1 ULP, which is why the
  originals passed.
* `make verif` — bit-exact against `fpref_fma` (IEEE mode): all 10 648
  triples of 22 corner values, then 200 000 vectors across cancellation
  (`c ≈ −a·b`), controlled product/addend gaps, products on a rounding tie
  with a tiny addend, subnormal × huge, and subnormal results. SVA: output
  contract and `a·b + c == b·a + c`. Coverage: a × b × c class cross, gap ×
  effective subtraction, rounding outcome, massive cancellation, tiny /
  overflow — 100 %. Long runs: 5 seeds × 1 M vectors clean.

**[BUGS.md](BUGS.md)** — six defects in the original FMAs (8 338 / 10 735
mismatches), and the shared datapath that replaced them.
