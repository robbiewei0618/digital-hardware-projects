// fpref.h - exact IEEE-754 reference model (see fpref.c)
#ifndef FPREF_H
#define FPREF_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// formats
#define FPREF_FP32 0
#define FPREF_FP16 1
#define FPREF_BF16 2

// mode bits
#define FPREF_IEEE 0x0
#define FPREF_FTZ  0x1   // flush tiny results (after rounding, unbounded exponent)
#define FPREF_DAZ  0x2   // treat subnormal inputs as zero

// flags returned by the reference model
#define FPREF_F_INEXACT    0x01
#define FPREF_F_ROUND_UP   0x02   // magnitude was incremented by rounding
#define FPREF_F_TIE        0x04   // exactly half-way (guard=1, sticky=0)
#define FPREF_F_TINY       0x08   // result below the normal range
#define FPREF_F_FLUSHED    0x10   // tiny result flushed to zero (FTZ)
#define FPREF_F_OVERFLOW   0x20
#define FPREF_F_EXACT_ZERO 0x40   // exact result is zero (e.g. x + -x)

// operand classes
#define FPREF_C_ZERO      0
#define FPREF_C_SUBNORMAL 1
#define FPREF_C_NORMAL    2
#define FPREF_C_INF       3
#define FPREF_C_NAN       4

uint32_t fpref_add(int fmt, uint32_t a, uint32_t b, int mode, int *flags);
uint32_t fpref_mul(int fmt, uint32_t a, uint32_t b, int mode, int *flags);
uint32_t fpref_fma(int fmt, uint32_t a, uint32_t b, uint32_t c, int mode, int *flags);
uint32_t fpref_dot4(int fmt,
                    uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4,
                    uint32_t y1, uint32_t y2, uint32_t y3, uint32_t y4,
                    int mode, int *flags);
int      fpref_class(int fmt, uint32_t x);

#ifdef __cplusplus
}
#endif
#endif
