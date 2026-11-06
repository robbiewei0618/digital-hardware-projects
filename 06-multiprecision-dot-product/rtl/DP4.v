// =============================================================================
// DP4 - combinational FP32/FP16 fused dot product
//   z = x1*y1 + x2*y2 + x3*y3 + x4*y4, one rounding (RNE)
//   precision = 0: binary32 operands; 1: binary16 operands in bits [31:16]
// The same four stages as DP4_pipeline (dp4_datapath.v) without registers.
// =============================================================================
module DP4 (
    input  [31:0] x1, x2, x3, x4,
    input  [31:0] y1, y2, y3, y4,
    input         precision,
    output [31:0] z
);
    wire signed [56:0] sm1, sm2, sm3, sm4;
    wire signed [9:0]  emax;
    wire               sticky_align;
    dp4_stage1 u_stage1 (
        .x1(x1), .x2(x2), .x3(x3), .x4(x4),
        .y1(y1), .y2(y2), .y3(y3), .y4(y4),
        .precision(precision),
        .sm1_s1(sm1), .sm2_s1(sm2), .sm3_s1(sm3), .sm4_s1(sm4),
        .emax_s1(emax), .sticky_align_s1(sticky_align)
    );

    wire signed [58:0] sum;
    dp4_stage2 u_stage2 (.sm1_s2(sm1), .sm2_s2(sm2), .sm3_s2(sm3), .sm4_s2(sm4), .sum_s2(sum));

    wire               sign, is_zero, ovf, udf;
    wire [58:0]        norm;
    wire signed [9:0]  exp_adj;
    dp4_stage3 u_stage3 (
        .sum_s3(sum), .emax_s3(emax), .precision_s3(precision),
        .sign_s3(sign), .norm_s3(norm), .exp_adj_s3(exp_adj),
        .is_zero_s3(is_zero), .ovf_s3(ovf), .udf_s3(udf)
    );

    dp4_stage4 u_stage4 (
        .norm_s4(norm), .exp_adj_s4(exp_adj), .sign_s4(sign),
        .is_zero_s4(is_zero), .ovf_s4(ovf), .udf_s4(udf),
        .prec_s4(precision), .sticky_s4(sticky_align),
        .z_comb(z)
    );
endmodule
