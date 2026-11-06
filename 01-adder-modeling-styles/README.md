# 01 — 32-bit adder in three modelling styles

The first course exercise: one 32-bit adder (`{co, s} = a + b + ci`) written
three ways, each also with registered outputs, then synthesised under area /
delay / balanced constraints.

| File | Style |
|---|---|
| `rtl/adder_behavior.v`, `adder_behavior_reg.v` | behavioural `always` block |
| `rtl/adder_dataflow.v`, `adder_dataflow_reg.v` | continuous assignment |
| `rtl/adder_structure.v`, `RCA_32bit.v`, `FA.v`, `adder_structure_reg.v`, `D_FF.v` | gate-level ripple-carry adder |

`syn/netlists/` holds the synthesised netlists per constraint, `docs/` the
report and waveforms.

## Verification
* `make legacy` — course testbench (Icarus). It instantiated
  `adder_behavior_reg` twice and never tested `adder_behavior`; fixed.
* `make verif` — 200 000 random and carry-chain-steered vectors against a
  33-bit reference for all seven DUTs; an assertion that every registered
  adder equals last cycle's sum; coverage of the longest carry run (0 … 32
  bits) × carry-out. No RTL bugs.
