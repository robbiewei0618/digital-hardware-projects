#!/usr/bin/env python3
"""Regenerate the DP4 answer files with a *fused* reference.

The course answer generator (gen_answers.py) rounds every FP16 product and
every partial sum to FP16 (np.float16 at each step). The DP4 hardware is a
fused dot product: it keeps the four products exact, adds them exactly and
rounds once. For FP16 the two disagree on 484 of the 1000 course vectors.

This script computes x1*y1 + x2*y2 + x3*y3 + x4*y4 exactly with rational
arithmetic and rounds once (round-to-nearest-even, flush-to-zero, like the
RTL). It writes data/ans16_fused.txt / data/ans32_fused.txt in the same
"dec <value>  float16 <hex>" format the course testbench reads.
"""
from fractions import Fraction as F
import sys

FMT = {16: (5, 10), 32: (8, 23)}

def decode(bits, h):
    eb, mb = FMT[bits]; bias = (1 << (eb - 1)) - 1
    s = h >> (eb + mb); e = (h >> mb) & ((1 << eb) - 1); m = h & ((1 << mb) - 1)
    v = F(m, 1 << mb) * F(2) ** (1 - bias) if e == 0 else (1 + F(m, 1 << mb)) * F(2) ** (e - bias)
    return -v if s else v

def round_ftz(bits, v):
    eb, mb = FMT[bits]; bias = (1 << (eb - 1)) - 1
    if v == 0: return 0
    s = 1 if v < 0 else 0; a = abs(v); e = 0
    while a >= 2: a /= 2; e += 1
    while a < 1: a *= 2; e -= 1
    q = a * (1 << mb); fl = int(q); r = q - fl
    if r > F(1, 2) or (r == F(1, 2) and fl & 1): fl += 1
    if fl == 2 << mb: fl = 1 << mb; e += 1
    be = e + bias
    if be >= (1 << eb) - 1: return (s << (eb + mb)) | (((1 << eb) - 1) << mb)
    if be <= 0: return s << (eb + mb)
    return (s << (eb + mb)) | (be << mb) | (fl - (1 << mb))

def main():
    for bits in (16, 32):
        out = []
        for line in open(f'data/FP{bits}.txt'):
            v = [int(t, 16) for t in line.split()]
            if len(v) != 8: continue
            r = round_ftz(bits, sum(decode(bits, v[k]) * decode(bits, v[k + 4]) for k in range(4)))
            out.append(f'dec {float(decode(bits, r)):15.7e}  float{bits} {r:0{bits // 4}x}\n')
        open(f'data/ans{bits}_fused.txt', 'w').writelines(out)
        print(f'wrote data/ans{bits}_fused.txt ({len(out)} answers)')

if __name__ == '__main__':
    main()
