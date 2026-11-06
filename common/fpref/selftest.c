// selftest.c - checks the reference model against the host FPU (IEEE mode).
// The host computes binary32 add/mul/fmaf with a single RNE rounding and
// gradual underflow, which is exactly fpref's FPREF_IEEE mode.
// NaNs are compared by class only (payload/sign are implementation-defined).
#include "fpref.h"

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static uint64_t s = 0x9E3779B97F4A7C15ull;
static uint32_t rnd32(void) {               // xorshift64*
    s ^= s >> 12; s ^= s << 25; s ^= s >> 27;
    return (uint32_t)((s * 0x2545F4914F6CDD1Dull) >> 32);
}

// biased operand generator: specials, subnormals, extremes and random
static uint32_t gen(void) {
    static const uint32_t special[] = {
        0x00000000, 0x80000000, 0x7F800000, 0xFF800000, 0x7FC00000, 0x00000001,
        0x007FFFFF, 0x00800000, 0x7F7FFFFF, 0x3F800000, 0xBF800000, 0x3F800001,
        0x3FFFFFFF, 0x33800000, 0x34000000, 0x0C000000, 0x72000000};
    uint32_t r = rnd32();
    switch (r % 8) {
    case 0: return special[rnd32() % (sizeof special / sizeof special[0])] ^ (rnd32() & 0x80000000u);
    case 1: return rnd32() & 0x807FFFFFu;                         // subnormal / zero
    case 2: return (rnd32() & 0x80FFFFFFu) | 0x3F000000u;         // near 1
    case 3: return (rnd32() & 0x807FFFFFu) | ((rnd32() % 8) << 23); // tiny normal
    case 4: return (rnd32() & 0x807FFFFFu) | ((0xF8u + rnd32() % 7) << 23); // huge
    default: return rnd32();
    }
}

static float f(uint32_t x) { float v; memcpy(&v, &x, 4); return v; }
static uint32_t u(float v) { uint32_t x; memcpy(&x, &v, 4); return x; }
static int isnan32(uint32_t x) { return ((x >> 23) & 0xFF) == 0xFF && (x & 0x7FFFFF); }

static int same(uint32_t a, uint32_t b) {
    if (isnan32(a) || isnan32(b)) return isnan32(a) && isnan32(b);
    return a == b;
}

int main(int argc, char **argv) {
    long n = argc > 1 ? atol(argv[1]) : 2000000;
    long err = 0;
    for (long i = 0; i < n; i++) {
        uint32_t a = gen(), b = gen(), c = gen();
        volatile float fa = f(a), fb = f(b), fc = f(c);
        uint32_t h_add = u(fa + fb), h_mul = u(fa * fb), h_fma = u(fmaf(fa, fb, fc));
        uint32_t r_add = fpref_add(FPREF_FP32, a, b, FPREF_IEEE, 0);
        uint32_t r_mul = fpref_mul(FPREF_FP32, a, b, FPREF_IEEE, 0);
        uint32_t r_fma = fpref_fma(FPREF_FP32, a, b, c, FPREF_IEEE, 0);
        if (!same(h_add, r_add)) { if (err++ < 10) printf("ADD %08x %08x host %08x ref %08x\n", a, b, h_add, r_add); }
        if (!same(h_mul, r_mul)) { if (err++ < 10) printf("MUL %08x %08x host %08x ref %08x\n", a, b, h_mul, r_mul); }
        if (!same(h_fma, r_fma)) { if (err++ < 10) printf("FMA %08x %08x %08x host %08x ref %08x\n", a, b, c, h_fma, r_fma); }
        // dot4 with three zero terms degenerates to a*b + c*1
        uint32_t r_d4 = fpref_dot4(FPREF_FP32, a, c, 0, 0, b, 0x3F800000u, 0, 0, FPREF_IEEE, 0);
        if (!same(h_fma, r_d4) && !(isnan32(h_fma))) {
            // fmaf(a,b,c) == a*b + c*1 exactly (c*1 is exact), except -0 sign corner
            if (!(((h_fma | r_d4) & 0x7FFFFFFFu) == 0)) {
                if (err++ < 10) printf("DOT4 %08x %08x %08x host %08x ref %08x\n", a, b, c, h_fma, r_d4);
            }
        }
    }
    printf("fpref selftest: %ld vectors x 4 ops, %ld mismatches\n", n, err);
    return err ? 1 : 0;
}
