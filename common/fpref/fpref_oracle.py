#!/usr/bin/env python3
"""Independent cross-check of fpref's FTZ mode and binary16 path with exact
rational arithmetic (fractions.Fraction). Slow, so it runs a few thousand
random vectors; the C selftest covers IEEE mode against the host FPU."""
import ctypes, random, sys
from fractions import Fraction as F

FMT = {0: (8, 23), 1: (5, 10)}

def decode(fmt, x):
    eb, mb = FMT[fmt]; bias = (1 << (eb - 1)) - 1
    s = (x >> (eb + mb)) & 1; e = (x >> mb) & ((1 << eb) - 1); m = x & ((1 << mb) - 1)
    if e == (1 << eb) - 1: return None
    v = F(m, 1 << mb) * F(2) ** (1 - bias) if e == 0 else (1 + F(m, 1 << mb)) * F(2) ** (e - bias)
    return -v if s else v

def round_ftz(fmt, v):
    eb, mb = FMT[fmt]; bias = (1 << (eb - 1)) - 1
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

def rand_op(fmt, rng):
    eb, mb = FMT[fmt]; w = 1 + eb + mb
    k = rng.random()
    if k < 0.3:   # small exponents -> exercise underflow / FTZ boundary
        e = rng.randrange(0, 4) if fmt else rng.randrange(0, 40)
        return (rng.getrandbits(1) << (w - 1)) | (e << mb) | rng.getrandbits(mb)
    if k < 0.4:   # large exponents -> overflow
        e = (1 << eb) - 2 - rng.randrange(0, 3)
        return (rng.getrandbits(1) << (w - 1)) | (e << mb) | rng.getrandbits(mb)
    while True:
        x = rng.getrandbits(w)
        if (x >> mb) & ((1 << eb) - 1) != (1 << eb) - 1: return x

def main(n):
    lib = ctypes.CDLL(sys.argv[1])
    for fn in ('fpref_mul', 'fpref_add'):
        getattr(lib, fn).restype = ctypes.c_uint32
    lib.fpref_fma.restype = ctypes.c_uint32
    lib.fpref_dot4.restype = ctypes.c_uint32
    rng = random.Random(1); bad = 0
    for i in range(n):
        for fmt in (0, 1):
            a, b, c = (rand_op(fmt, rng) for _ in range(3))
            xs = [rand_op(fmt, rng) for _ in range(8)]
            A, B, C = decode(fmt, a), decode(fmt, b), decode(fmt, c)
            tests = [
                ('mul', lib.fpref_mul(fmt, a, b, 1, None), round_ftz(fmt, A * B)),
                ('add', lib.fpref_add(fmt, a, b, 1, None), round_ftz(fmt, A + B)),
                ('fma', lib.fpref_fma(fmt, a, b, c, 1, None), round_ftz(fmt, A * B + C)),
                ('dot4', lib.fpref_dot4(fmt, *xs, 1, None),
                 round_ftz(fmt, sum(decode(fmt, xs[k]) * decode(fmt, xs[k + 4]) for k in range(4)))),
            ]
            for name, got, exp in tests:
                sign = 1 << (31 if fmt == 0 else 15)
                both_zero = ((got | exp) & ~sign) == 0   # zero-sign rules are checked by selftest.c
                if got != exp and not both_zero:
                    bad += 1
                    if bad < 10: print(name, fmt, hex(a), hex(b), hex(c), 'ref', hex(got), 'oracle', hex(exp))
    print(f'fpref oracle check: {n} iterations x 2 formats x 4 ops, {bad} mismatches')
    sys.exit(1 if bad else 0)

if __name__ == '__main__':
    main(int(sys.argv[2]) if len(sys.argv) > 2 else 3000)
