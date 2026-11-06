# 06 — Reconfigurable FP32 / FP16 fused dot product (DP4)

`z = x1·y1 + x2·y2 + x3·y3 + x4·y4` with one rounding. `precision = 0`:
binary32 operands; `precision = 1`: binary16 operands in bits [31:16] and
the result in `z[31:16]`.

| File | Function | Latency |
|---|---|---:|
| `rtl/DP4.v` | combinational | 0 |
| `rtl/DP4_pipeline.v` | 4-stage pipeline | 4 |
| `rtl/DP4_pipeline_CG.v` | 4-stage pipeline, idle stages clock-gated | 4 |
| `rtl/dp4_datapath.v` | shared stages: unpack/multiply/align, 4-way add, normalise, round/pack | |

Subnormal inputs read as zero, tiny results flush to zero, zero results are
`+0`, no Inf/NaN inputs. `syn/pt.tcl` is the PrimeTime power script;
`docs/` has the clock-gating diagram and the PrimeTime lab handout.

## Verification
* `make legacy` — course testbench for all three designs, FP32 and FP16. FP16
  uses `data/ans16_fused.txt`, an exact re-computation of the answers
  (`tb/legacy/gen_answers_fused.py`): the course file was not a fused result
  and marked the correct design 51.6 %. `make legacy-ta16` shows that run.
* `make verif` — one build per design, precision switching randomly every
  cycle and garbage in the unused FP16 half-words; pairwise cancellation,
  wide exponent spread, overflow / underflow edges. Same-sign products must
  be correctly rounded; with cancellation a result may instead stay within
  the alignment-window bound, computed exactly by `fpref_dot4_window_ok`
  (see BUGS.md). SVA: no X, FP32/FP16 flush-to-zero. Coverage: precision and
  precision switches, exponent spread, cancellation depth, rounding, flush /
  overflow per precision — 100 %.

**[BUGS.md](BUGS.md)** — the course's wrong FP16 answers, the weaker datapath
in the combinational and clock-gated versions (now one shared datapath), and
flush-to-zero before rounding.
