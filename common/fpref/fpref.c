// =============================================================================
// fpref.c - exact IEEE-754 reference model for design verification
//
// Every operation is evaluated *exactly* in a 640-bit fixed-point integer
// (LSB = 2^-320) and rounded once, so the same code serves ADD, MUL, fused
// multiply-add and the fused 4-term dot product, for binary32 and binary16.
//
//   value range needed for binary32:  products of two subnormals = 2^-298
//                                     sum of four max products   < 2^259
//
// Rounding: round-to-nearest-even only (all DUTs in this repo use RNE).
// Underflow handling is selected per call with mode bits:
//   FPREF_FTZ : a result whose biased exponent is <= 0 *after* rounding with
//               an unbounded exponent is flushed to a signed zero. This is
//               what the RTL in this repo implements (no subnormal outputs).
//   FPREF_DAZ : subnormal inputs are treated as signed zeros.
//   (neither) : full IEEE-754 gradual underflow.
//
// The optional flags word describes what happened while rounding, so the
// testbench can sample rounding coverage (see FPREF_F_* below).
// =============================================================================
#include "fpref.h"

#include <stdint.h>
#include <string.h>

#define LIMBS   10
#define LSB_EXP (-320)

typedef struct { uint64_t w[LIMBS]; } big_t;   // little-endian limbs

typedef struct {
    int ebits, mbits, bias;
} fmt_t;

static fmt_t get_fmt(int fmt) {
    fmt_t f;
    if (fmt == FPREF_FP16) { f.ebits = 5;  f.mbits = 10; }
    else if (fmt == FPREF_BF16) { f.ebits = 8;  f.mbits = 7; }
    else                   { f.ebits = 8;  f.mbits = 23; }
    f.bias = (1 << (f.ebits - 1)) - 1;
    return f;
}

// ----------------------------------------------------------------------------
// big integer helpers (unsigned magnitude)
// ----------------------------------------------------------------------------
static void big_zero(big_t *a) { memset(a, 0, sizeof *a); }

static int big_cmp(const big_t *a, const big_t *b) {
    for (int i = LIMBS - 1; i >= 0; i--) {
        if (a->w[i] != b->w[i]) return a->w[i] > b->w[i] ? 1 : -1;
    }
    return 0;
}

static void big_add(big_t *r, const big_t *a, const big_t *b) {
    unsigned __int128 c = 0;
    for (int i = 0; i < LIMBS; i++) {
        c += (unsigned __int128)a->w[i] + b->w[i];
        r->w[i] = (uint64_t)c;
        c >>= 64;
    }
}

static void big_sub(big_t *r, const big_t *a, const big_t *b) {   // a >= b
    uint64_t borrow = 0;
    for (int i = 0; i < LIMBS; i++) {
        uint64_t bi = b->w[i] + borrow;
        uint64_t nb = (bi < borrow) || (a->w[i] < bi);
        r->w[i] = a->w[i] - bi;
        borrow = nb;
    }
}

// r = m * 2^sh   (m < 2^64, 0 <= sh, result must fit)
static void big_from_shifted(big_t *r, uint64_t m, int sh) {
    big_zero(r);
    int limb = sh / 64, bit = sh % 64;
    if (limb < LIMBS) r->w[limb] = m << bit;
    if (bit && limb + 1 < LIMBS) r->w[limb + 1] = m >> (64 - bit);
}

static int big_bit(const big_t *a, int i) {
    if (i < 0 || i >= 64 * LIMBS) return 0;
    return (int)((a->w[i / 64] >> (i % 64)) & 1u);
}

static int big_msb(const big_t *a) {          // -1 if zero
    for (int i = LIMBS - 1; i >= 0; i--)
        if (a->w[i]) return i * 64 + 63 - __builtin_clzll(a->w[i]);
    return -1;
}

static int big_any_below(const big_t *a, int i) {   // OR of bits [i-1:0]
    if (i <= 0) return 0;
    int full = i / 64, rem = i % 64;
    for (int k = 0; k < full && k < LIMBS; k++) if (a->w[k]) return 1;
    if (full < LIMBS && rem) return (a->w[full] & ((1ull << rem) - 1)) != 0;
    return 0;
}

static uint64_t big_extract(const big_t *a, int lo, int n) { // bits [lo+n-1:lo], n<=63
    uint64_t v = 0;
    for (int k = n - 1; k >= 0; k--) v = (v << 1) | (uint64_t)big_bit(a, lo + k);
    return v;
}

// ----------------------------------------------------------------------------
// decoded operands and a signed exact accumulator (sign-magnitude)
// ----------------------------------------------------------------------------
typedef enum { K_ZERO, K_FINITE, K_INF, K_NAN } kind_t;

typedef struct {
    kind_t   kind;
    int      sign;
    uint64_t sig;   // integer significand (hidden bit included)
    int      exp;   // value = sig * 2^exp
    int      subnormal;
} op_t;

static op_t decode(fmt_t f, uint32_t x, int mode) {
    op_t o;
    uint32_t emask = (1u << f.ebits) - 1;
    uint32_t frac  = x & ((1u << f.mbits) - 1);
    uint32_t e     = (x >> f.mbits) & emask;
    o.sign = (x >> (f.ebits + f.mbits)) & 1;
    o.subnormal = 0;
    o.sig = 0; o.exp = 0;
    if (e == emask) { o.kind = frac ? K_NAN : K_INF; return o; }
    if (e == 0) {
        if (frac == 0 || (mode & FPREF_DAZ)) { o.kind = K_ZERO; return o; }
        o.kind = K_FINITE; o.subnormal = 1;
        o.sig = frac; o.exp = 1 - f.bias - f.mbits;
        return o;
    }
    o.kind = K_FINITE;
    o.sig = frac | (1ull << f.mbits);
    o.exp = (int)e - f.bias - f.mbits;
    return o;
}

typedef struct { big_t pos, neg; } acc_t;

static void acc_init(acc_t *a) { big_zero(&a->pos); big_zero(&a->neg); }

static void acc_add_term(acc_t *a, int sign, uint64_t sig, int exp) {
    big_t t, s;
    big_from_shifted(&t, sig, exp - LSB_EXP);
    if (sign) { big_add(&s, &a->neg, &t); a->neg = s; }
    else      { big_add(&s, &a->pos, &t); a->pos = s; }
}

static uint32_t pack(fmt_t f, int sign, uint32_t e, uint32_t frac) {
    return ((uint32_t)sign << (f.ebits + f.mbits)) | (e << f.mbits) | frac;
}

static uint32_t qnan(fmt_t f) {   // canonical quiet NaN, positive
    return pack(f, 0, (1u << f.ebits) - 1, 1u << (f.mbits - 1));
}

static uint32_t inf_of(fmt_t f, int sign) { return pack(f, sign, (1u << f.ebits) - 1, 0); }

// Round the exact accumulator to format f.
// zero_sign: sign to use if the exact result is zero.
static uint32_t round_acc(fmt_t f, const acc_t *a, int zero_sign, int mode, int *flags) {
    big_t mag;
    int sign;
    int c = big_cmp(&a->pos, &a->neg);
    if (c == 0) { if (flags) *flags |= FPREF_F_EXACT_ZERO; return pack(f, zero_sign, 0, 0); }
    if (c > 0) { big_sub(&mag, &a->pos, &a->neg); sign = 0; }
    else       { big_sub(&mag, &a->neg, &a->pos); sign = 1; }

    const int p = f.mbits + 1;                  // precision incl. hidden bit
    const int emin = 1 - f.bias;                // exponent of min normal
    const uint32_t emax_biased = (1u << f.ebits) - 2;

    int msb = big_msb(&mag);
    int E = msb + LSB_EXP;                      // value in [2^E, 2^(E+1))

    // position (bit index in mag) of the result LSB
    int lsb_pos;
    int ieee_sub = 0;
    if (!(mode & FPREF_FTZ) && E < emin) {      // IEEE gradual underflow
        lsb_pos = (emin - f.mbits) - LSB_EXP;
        ieee_sub = 1;
    } else {
        lsb_pos = msb - (p - 1);                // unbounded-exponent rounding
    }

    uint64_t keep;
    int guard, sticky;
    if (lsb_pos <= 0) {                         // exact: nothing below LSB_EXP
        keep = big_extract(&mag, 0, msb + 1) << (-lsb_pos);
        guard = 0; sticky = 0;
    } else {
        keep   = big_extract(&mag, lsb_pos, msb - lsb_pos + 1 > 0 ? msb - lsb_pos + 1 : 0);
        guard  = big_bit(&mag, lsb_pos - 1);
        sticky = big_any_below(&mag, lsb_pos - 1);
    }
    int inexact = guard | sticky;
    int round_up = guard && (sticky || (keep & 1));
    if (flags) {
        if (inexact)            *flags |= FPREF_F_INEXACT;
        if (round_up)           *flags |= FPREF_F_ROUND_UP;
        if (guard && !sticky)   *flags |= FPREF_F_TIE;
    }
    keep += (uint64_t)round_up;

    int Er;                                      // exponent of result LSB
    Er = lsb_pos + LSB_EXP;
    if (ieee_sub) {
        // keep is the subnormal significand; it may have rounded up to 2^mbits
        if (keep >> f.mbits) {                   // became the min normal
            return pack(f, sign, 1, (uint32_t)(keep & ((1ull << f.mbits) - 1)));
        }
        if (keep == 0) { if (flags) *flags |= FPREF_F_TINY; return pack(f, sign, 0, 0); }
        if (flags) *flags |= FPREF_F_TINY;
        return pack(f, sign, 0, (uint32_t)keep);
    }
    if (keep >> p) { keep >>= 1; Er += 1; }      // rounding carried out
    int Eres = Er + f.mbits;                     // exponent of leading bit
    int biased = Eres + f.bias;
    if (biased > (int)emax_biased) {
        if (flags) *flags |= FPREF_F_OVERFLOW;
        return inf_of(f, sign);
    }
    if (biased <= 0) {                           // FTZ (tininess after rounding)
        if (flags) *flags |= FPREF_F_TINY | FPREF_F_FLUSHED;
        return pack(f, sign, 0, 0);
    }
    return pack(f, sign, (uint32_t)biased, (uint32_t)(keep & ((1ull << f.mbits) - 1)));
}

// ----------------------------------------------------------------------------
// public API
// ----------------------------------------------------------------------------
uint32_t fpref_add(int fmt, uint32_t a, uint32_t b, int mode, int *flags) {
    fmt_t f = get_fmt(fmt);
    if (flags) *flags = 0;
    op_t x = decode(f, a, mode), y = decode(f, b, mode);
    if (x.kind == K_NAN || y.kind == K_NAN) return qnan(f);
    if (x.kind == K_INF && y.kind == K_INF) return (x.sign == y.sign) ? inf_of(f, x.sign) : qnan(f);
    if (x.kind == K_INF) return inf_of(f, x.sign);
    if (y.kind == K_INF) return inf_of(f, y.sign);
    acc_t acc; acc_init(&acc);
    if (x.kind == K_FINITE) acc_add_term(&acc, x.sign, x.sig, x.exp);
    if (y.kind == K_FINITE) acc_add_term(&acc, y.sign, y.sig, y.exp);
    // exact zero: -0 only if both operands are -0 (RNE)
    int zs = (x.kind == K_ZERO && y.kind == K_ZERO) ? (x.sign & y.sign) : 0;
    return round_acc(f, &acc, zs, mode, flags);
}

uint32_t fpref_mul(int fmt, uint32_t a, uint32_t b, int mode, int *flags) {
    fmt_t f = get_fmt(fmt);
    if (flags) *flags = 0;
    op_t x = decode(f, a, mode), y = decode(f, b, mode);
    int s = x.sign ^ y.sign;
    if (x.kind == K_NAN || y.kind == K_NAN) return qnan(f);
    if ((x.kind == K_INF && y.kind == K_ZERO) || (x.kind == K_ZERO && y.kind == K_INF)) return qnan(f);
    if (x.kind == K_INF || y.kind == K_INF) return inf_of(f, s);
    if (x.kind == K_ZERO || y.kind == K_ZERO) return pack(f, s, 0, 0);
    acc_t acc; acc_init(&acc);
    acc_add_term(&acc, s, x.sig * y.sig, x.exp + y.exp);
    return round_acc(f, &acc, s, mode, flags);
}

// fused: a*b + c, single rounding
uint32_t fpref_fma(int fmt, uint32_t a, uint32_t b, uint32_t c, int mode, int *flags) {
    fmt_t f = get_fmt(fmt);
    if (flags) *flags = 0;
    op_t x = decode(f, a, mode), y = decode(f, b, mode), z = decode(f, c, mode);
    int sp = x.sign ^ y.sign;
    if (x.kind == K_NAN || y.kind == K_NAN || z.kind == K_NAN) return qnan(f);
    int p_inf  = (x.kind == K_INF || y.kind == K_INF);
    int p_zero = (x.kind == K_ZERO || y.kind == K_ZERO);
    if (p_inf && p_zero) return qnan(f);
    if (p_inf) {
        if (z.kind == K_INF && z.sign != sp) return qnan(f);
        return inf_of(f, sp);
    }
    if (z.kind == K_INF) return inf_of(f, z.sign);
    acc_t acc; acc_init(&acc);
    if (!p_zero) acc_add_term(&acc, sp, x.sig * y.sig, x.exp + y.exp);
    if (z.kind == K_FINITE) acc_add_term(&acc, z.sign, z.sig, z.exp);
    int zs = (p_zero && z.kind == K_ZERO) ? (sp & z.sign) : 0;
    return round_acc(f, &acc, zs, mode, flags);
}

// fused 4-term dot product: x1*y1 + x2*y2 + x3*y3 + x4*y4, single rounding
uint32_t fpref_dot4(int fmt,
                    uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4,
                    uint32_t y1, uint32_t y2, uint32_t y3, uint32_t y4,
                    int mode, int *flags) {
    fmt_t f = get_fmt(fmt);
    if (flags) *flags = 0;
    uint32_t xs[4] = {x1, x2, x3, x4}, ys[4] = {y1, y2, y3, y4};
    acc_t acc; acc_init(&acc);
    int any_nan = 0, inf_pos = 0, inf_neg = 0, all_zero_sign = 1, nterms_zero = 0;
    for (int i = 0; i < 4; i++) {
        op_t x = decode(f, xs[i], mode), y = decode(f, ys[i], mode);
        int s = x.sign ^ y.sign;
        if (x.kind == K_NAN || y.kind == K_NAN) { any_nan = 1; continue; }
        int pi = (x.kind == K_INF || y.kind == K_INF), pz = (x.kind == K_ZERO || y.kind == K_ZERO);
        if (pi && pz) { any_nan = 1; continue; }
        if (pi) { if (s) inf_neg = 1; else inf_pos = 1; continue; }
        if (pz) { all_zero_sign &= s; nterms_zero++; continue; }
        all_zero_sign = 0;
        acc_add_term(&acc, s, x.sig * y.sig, x.exp + y.exp);
    }
    if (any_nan || (inf_pos && inf_neg)) return qnan(f);
    if (inf_pos) return inf_of(f, 0);
    if (inf_neg) return inf_of(f, 1);
    int zs = (nterms_zero == 4) ? all_zero_sign : 0;
    return round_acc(f, &acc, zs, mode, flags);
}

// Accuracy check for windowed (finite-accumulator) dot-product hardware.
// Returns 1 if the DUT result z satisfies
//     |z - S| <= ulp(RN(S)) + 4 * 2^(Emax - window_bits)
// where S is the exact dot product and Emax the exponent of the largest
// |x_i*y_i| (weight of its leading bit). Products below that window can only
// be represented by a sticky bit, so when large terms cancel exactly a
// hardware implementation can be off by up to this amount.
int fpref_dot4_window_ok(int fmt,
                         uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4,
                         uint32_t y1, uint32_t y2, uint32_t y3, uint32_t y4,
                         uint32_t z, int mode, int window_bits) {
    fmt_t f = get_fmt(fmt);
    uint32_t xs[4] = {x1, x2, x3, x4}, ys[4] = {y1, y2, y3, y4};
    acc_t acc; acc_init(&acc);
    int emax = -100000, any = 0;
    for (int i = 0; i < 4; i++) {
        op_t x = decode(f, xs[i], mode), y = decode(f, ys[i], mode);
        if (x.kind != K_FINITE || y.kind != K_FINITE) {
            if (x.kind == K_ZERO || y.kind == K_ZERO) continue;
            return 0;                              // Inf/NaN: no bound applies
        }
        uint64_t p = x.sig * y.sig;
        int e = x.exp + y.exp + 63 - __builtin_clzll(p);
        if (e > emax) emax = e;
        any = 1;
        acc_add_term(&acc, x.sign ^ y.sign, p, x.exp + y.exp);
    }
    op_t zd = decode(f, z, 0);
    if (zd.kind == K_NAN) return 0;
    if (zd.kind == K_INF)   // only if the window error itself can exceed the format
        return any && (emax - window_bits + 2) >= f.bias + 1;
    if (zd.kind == K_FINITE) acc_add_term(&acc, !zd.sign, zd.sig, zd.exp);   // S - z
    big_t diff;
    if (big_cmp(&acc.pos, &acc.neg) >= 0) big_sub(&diff, &acc.pos, &acc.neg);
    else                                  big_sub(&diff, &acc.neg, &acc.pos);
    // ulp of the correctly rounded result (normal-range minimum if tiny)
    int fl = 0;
    uint32_t r = fpref_dot4(fmt, x1, x2, x3, x4, y1, y2, y3, y4, mode, &fl);
    int er = (int)((r >> f.mbits) & ((1u << f.ebits) - 1));
    if (er == 0) er = 1;
    int ulp_exp = er - f.bias - f.mbits;
    big_t bound, t;
    big_from_shifted(&bound, 1, ulp_exp - LSB_EXP);
    if (any) {
        int w = emax - window_bits + 2;            // 4 * 2^(emax - W)
        if (w - LSB_EXP >= 0) { big_from_shifted(&t, 1, w - LSB_EXP); big_add(&bound, &bound, &t); }
    }
    return big_cmp(&diff, &bound) <= 0;
}

// classification helper used by the coverage models
int fpref_class(int fmt, uint32_t x) {
    fmt_t f = get_fmt(fmt);
    uint32_t emask = (1u << f.ebits) - 1;
    uint32_t frac  = x & ((1u << f.mbits) - 1);
    uint32_t e     = (x >> f.mbits) & emask;
    if (e == emask) return frac ? FPREF_C_NAN : FPREF_C_INF;
    if (e == 0)     return frac ? FPREF_C_SUBNORMAL : FPREF_C_ZERO;
    return FPREF_C_NORMAL;
}
