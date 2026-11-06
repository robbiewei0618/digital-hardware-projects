// =============================================================================
// FLP_FMA - binary32 fused multiply-add, combinational
//   R = A*B + C with a single rounding (RNE); subnormal inputs and results,
//   IEEE-754 Inf/NaN rules, canonical quiet NaN 0x7FC00000.
// Datapath: fma_datapath.v (shared with the pipelined FLP_FMA_4).
// The first version of this design is in archive/FLP_FMA_v1.v (see BUGS.md).
// =============================================================================
module FLP_FMA (
    input  [31:0] A,
    input  [31:0] B,
    input  [31:0] C,
    output [31:0] R
);
    wire [78:0]        p_al, c_al, mag;
    wire               sp, sc, zero_sign, special, sign, guard, sticky, is_zero;
    wire signed [10:0] e_frame, exp_b;
    wire [31:0]        special_res;
    wire [23:0]        sig;

    fma_stage1 u_s1 (.a(A), .b(B), .c(C), .p_al(p_al), .c_al(c_al), .sp(sp), .sc(sc),
                     .e_frame(e_frame), .zero_sign(zero_sign), .special(special),
                     .special_res(special_res));
    fma_stage2 u_s2 (.p_al(p_al), .c_al(c_al), .sp(sp), .sc(sc), .mag(mag), .sign(sign));
    fma_stage3 u_s3 (.mag(mag), .e_frame(e_frame), .sig(sig), .guard(guard), .sticky(sticky),
                     .exp_b(exp_b), .is_zero(is_zero));
    fma_stage4 u_s4 (.sig(sig), .guard(guard), .sticky(sticky), .exp_b(exp_b), .sign(sign),
                     .is_zero(is_zero), .zero_sign(zero_sign), .special(special),
                     .special_res(special_res), .r(R));
endmodule
