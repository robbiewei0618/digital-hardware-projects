# Bug log — project 05

Found by the verification environment in [`verif/`](verif/) (exact
single-rounding reference in IEEE mode, SVA, coverage). The original
designs passed the course testbench, which accepts any result within
0.1 % relative error or 1 ULP.

| # | DUT (original) | Symptom | Example `a * b + c` → got / expected |
|---|----------------|---------|--------------------------------------|
| 1 | `FLP_FMA`, `FLP_FMA_4` | a zero product still decided the alignment | `0 * 7f7fffff + 00000001` → `29000000` / `00000001`; `0 * 0 + 3f800000` → `0` / `3f800000` |
| 2 | both | product shifted right (and jammed) when the addend exponent was larger → bits lost under cancellation | `f3fffff7 * 82ffffff + b77ffff6` → `21200000` / `21100000` (2×) |
| 3 | both | subnormal results rounded to 24 bits *then* shifted: double rounding | `07000040 * a716454a + 00000200` → `000001ff` / `00000200` |
| 4 | both | results below 2⁻¹⁴⁹ flushed before rounding | `00800000 * 00800000 + 80000001` → `80000000` / `80000001` |
| 5 | `FLP_FMA_4` | Inf addend took the product's sign | `00800000 * 00800000 + 7f800000` → `ff800000` / `7f800000` |
| 6 | both | every zero result was `+0` | `(-0) * 1 + (-0)` → `+0` / `-0` |

Regression on the originals (seed 1, 210 657 vectors): `FLP_FMA` 8 338
mismatches, `FLP_FMA_4` 10 735. Both now 0 (5 × 1 M vectors, seeds 1–5).

---

## Root causes

**1 — zero product.** A zero operand has exponent field 0, which the
design reads as 2⁻¹²⁶, so `0 * huge` got a large "product exponent". The
addend was then aligned *below* a product that does not exist and only
survived as a sticky bit; when both multiplicands were zero the result was
forced to 0 without looking at `C` at all.

**2 — the wrong operand moved.** The datapath shifted whichever operand had
the smaller exponent to the right with a sticky jam. When the addend
exponent exceeds the product exponent by a few bits and the two nearly
cancel, the product's low bits are exactly the ones that survive the
cancellation — and they had been ORed into one sticky bit.

**3 / 4 — subnormals.** The result was normalised and rounded as if the
exponent were unbounded, and only then shifted right into the subnormal
range (`{1'b1, frac} >> sub_shift`), truncating a second time. Anything
below 2⁻¹⁴⁹ was flushed by an exponent compare before rounding, so a value
just above half the smallest subnormal became 0.

**5 — pipeline.** Same pattern as project 02 bug 5: a sign used in the last
stage was not carried along with its Inf flag.

## Fix: one datapath, standard FMA alignment

Rather than patch two separate implementations, the arithmetic now lives
once in `rtl/fma_datapath.v`; `FLP_FMA` chains its four stages and
`FLP_FMA_4` registers between them (latency 4, as before). The originals
are in `rtl/archive/`.

* the product never moves; the addend is placed at its exact weight in a
  79-bit frame, pinned on top only when it is so large that the product is
  pure sticky, shifted into a sticky bit only when it is entirely below the
  frame — and a zero product anchors the frame on `C`;
* sticky bits are jammed into bit 0 *before* the addition;
* normalisation stops at the subnormal exponent, then the result is rounded
  once;
* specials (NaN, Inf, Inf·0, Inf − Inf) and zero signs follow IEEE 754.

## 7. A bug in the rewrite, found by the long regression

The first version of the new datapath passed 210 k vectors but failed 15 of
1 M with seed 1 — always `subnormal * large + c`, e.g.
`fb800000 * 80000001 + a666f4f1` → `30fffff8` instead of `30fffff9`. With a
subnormal operand the 48-bit product has leading zeros, so its leading one
sits low in the frame; after a 1-bit cancellation the result LSB fell next
to frame bit 0, where the jammed addend sticky lives, and the rounding
decision used it. Fix: normalise the product (leading one back to bit 46/47,
exponent adjusted) before alignment. A targeted stimulus scenario
(`subnormal × huge`, often a power-of-two multiplicand) was added so the
default 200 k-vector run catches this class (4 hits on the broken version).
