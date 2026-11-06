#!/usr/bin/env python3
"""Generate test vectors for the truncated multipliers.

Writes data/<N>x<N>_{a,b,ans}.txt (hex, one value per line) where
ans = floor(a*b / 2^N), the exact upper half of the unsigned product.
The truncated designs are allowed to differ from ans by less than one
output ULP; the full-width designs must match it exactly.

The repository ships the original 8x8 vectors from the course; the 16x16
set was missing and is produced by this script (fixed seed, reproducible):
    python3 gen_testdata.py 16
"""
import random
import sys

def main(n, count=100, seed=2025):
    rng = random.Random(seed)
    top = (1 << n) - 1
    corners = [(0, 0), (top, top), (top, 1), (1, top), (1 << (n - 1), 1 << (n - 1)),
               (top, 1 << (n - 1)), (0x5555 & top, 0xAAAA & top), (top, 0)]
    vecs = corners + [(rng.randrange(1 << n), rng.randrange(1 << n)) for _ in range(count - len(corners))]
    w = (n + 3) // 4
    with open(f'data/{n}x{n}_a.txt', 'w') as fa, open(f'data/{n}x{n}_b.txt', 'w') as fb, \
         open(f'data/{n}x{n}_ans.txt', 'w') as fs:
        for a, b in vecs:
            fa.write(f'{a:0{w}X}\n'); fb.write(f'{b:0{w}X}\n'); fs.write(f'{(a * b) >> n:0{w}X}\n')
    print(f'wrote {len(vecs)} vectors to data/{n}x{n}_*.txt')

if __name__ == '__main__':
    main(int(sys.argv[1]) if len(sys.argv) > 1 else 16)
