//==============================================================================
// Top: DP4_pipeline  (4-stage pipeline, stage1~stage4 modules)
//==============================================================================

module DP4_pipeline (
    input         clk,
    input         rst_n,
    input  [31:0] x1, x2, x3, x4,
    input  [31:0] y1, y2, y3, y4,
    input         precision,
    output [31:0] z
);

    // -------------------------------------------------------------------------
    // Stage 1 outputs (combinational)
    // -------------------------------------------------------------------------
    wire signed [56:0] sm1_s1, sm2_s1, sm3_s1, sm4_s1;
    wire signed [9:0]  emax_s1;
    wire               sticky_align_s1;

    // -------------------------------------------------------------------------
    // Stage 1: combinational
    // -------------------------------------------------------------------------
    stage1 u_stage1 (
        .x1(x1), .x2(x2), .x3(x3), .x4(x4),
        .y1(y1), .y2(y2), .y3(y3), .y4(y4),
        .precision(precision),
        .sm1_s1(sm1_s1),
        .sm2_s1(sm2_s1),
        .sm3_s1(sm3_s1),
        .sm4_s1(sm4_s1),
        .emax_s1(emax_s1),
        .sticky_align_s1(sticky_align_s1)
    );

    // -------------------------------------------------------------------------
    // Pipeline reg: Stage1 -> Stage2
    // -------------------------------------------------------------------------
    reg signed [56:0] sm1_s2, sm2_s2, sm3_s2, sm4_s2;
    reg signed [9:0]  emax_s2;
    reg               precision_s2;
    reg               sticky_align_s2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sm1_s2         <= 57'sd0;
            sm2_s2         <= 57'sd0;
            sm3_s2         <= 57'sd0;
            sm4_s2         <= 57'sd0;
            emax_s2        <= 10'sd0;
            precision_s2   <= 1'b0;
            sticky_align_s2<= 1'b0;
        end else begin
            sm1_s2         <= sm1_s1;
            sm2_s2         <= sm2_s1;
            sm3_s2         <= sm3_s1;
            sm4_s2         <= sm4_s1;
            emax_s2        <= emax_s1;
            precision_s2   <= precision;
            sticky_align_s2<= sticky_align_s1;
        end
    end

    // -------------------------------------------------------------------------
    // Stage 2 outputs (combinational)
    // -------------------------------------------------------------------------
    wire signed [58:0] sum_s2;

    // -------------------------------------------------------------------------
    // Stage 2: combinational
    // -------------------------------------------------------------------------
    stage2 u_stage2 (
        .sm1_s2(sm1_s2),
        .sm2_s2(sm2_s2),
        .sm3_s2(sm3_s2),
        .sm4_s2(sm4_s2),
        .sum_s2(sum_s2)
    );

    // -------------------------------------------------------------------------
    // Pipeline reg: Stage2 -> Stage3
    // -------------------------------------------------------------------------
    reg signed [58:0] sum_s3;
    reg signed [9:0]  emax_s3;
    reg               precision_s3;
    reg               sticky_align_s3;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum_s3          <= 59'sd0;
            emax_s3         <= 10'sd0;
            precision_s3    <= 1'b0;
            sticky_align_s3 <= 1'b0;
        end else begin
            sum_s3          <= sum_s2;
            emax_s3         <= emax_s2;
            precision_s3    <= precision_s2;
            sticky_align_s3 <= sticky_align_s2;
        end
    end

    // -------------------------------------------------------------------------
    // Stage 3 outputs (combinational)
    // -------------------------------------------------------------------------
    wire               sign_s3;
    wire [58:0]        norm_s3;
    wire signed [9:0]  exp_adj_s3;
    wire               is_zero_s3;
    wire               ovf_s3;
    wire               udf_s3;

    // -------------------------------------------------------------------------
    // Stage 3: combinational
    // -------------------------------------------------------------------------
    stage3 u_stage3 (
        .sum_s3(sum_s3),
        .emax_s3(emax_s3),
        .precision_s3(precision_s3),
        .sign_s3(sign_s3),
        .norm_s3(norm_s3),
        .exp_adj_s3(exp_adj_s3),
        .is_zero_s3(is_zero_s3),
        .ovf_s3(ovf_s3),
        .udf_s3(udf_s3)
    );

    // -------------------------------------------------------------------------
    // Pipeline reg: Stage3 -> Stage4
    // -------------------------------------------------------------------------
    reg [58:0]        norm_s4;
    reg signed [9:0]  exp_adj_s4;
    reg               sign_s4;
    reg               is_zero_s4;
    reg               ovf_s4;
    reg               udf_s4;
    reg               prec_s4;
    reg               sticky_s4;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            norm_s4   <= 59'd0;
            exp_adj_s4<= 10'sd0;
            sign_s4   <= 1'b0;
            is_zero_s4<= 1'b0;
            ovf_s4    <= 1'b0;
            udf_s4    <= 1'b0;
            prec_s4   <= 1'b0;
            sticky_s4 <= 1'b0;
        end else begin
            norm_s4   <= norm_s3;
            exp_adj_s4<= exp_adj_s3;
            sign_s4   <= sign_s3;
            is_zero_s4<= is_zero_s3;
            ovf_s4    <= ovf_s3;
            udf_s4    <= udf_s3;
            prec_s4   <= precision_s3;
            sticky_s4 <= sticky_align_s3;
        end
    end

    // -------------------------------------------------------------------------
    // Stage 4 outputs (combinational)
    // -------------------------------------------------------------------------
    wire [31:0] z_comb;

    // -------------------------------------------------------------------------
    // Stage 4: combinational
    // -------------------------------------------------------------------------
    stage4 u_stage4 (
        .norm_s4(norm_s4),
        .exp_adj_s4(exp_adj_s4),
        .sign_s4(sign_s4),
        .is_zero_s4(is_zero_s4),
        .ovf_s4(ovf_s4),
        .udf_s4(udf_s4),
        .prec_s4(prec_s4),
        .sticky_s4(sticky_s4),
        .z_comb(z_comb)
    );

    // -------------------------------------------------------------------------
    // Final output register (Stage 4 -> z)
    // -------------------------------------------------------------------------
    reg [31:0] z_reg;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            z_reg <= 32'd0;
        else
            z_reg <= z_comb;
    end

    assign z = z_reg;

endmodule

//==============================================================================
// Stage 1: Unpack, Multiply, Alignment, Sticky, Signed Mantissas
//==============================================================================

module stage1 (
    input  [31:0] x1, x2, x3, x4,
    input  [31:0] y1, y2, y3, y4,
    input         precision,
    output signed [56:0] sm1_s1,
    output signed [56:0] sm2_s1,
    output signed [56:0] sm3_s1,
    output signed [56:0] sm4_s1,
    output signed [9:0]  emax_s1,
    output               sticky_align_s1
);

    // Unpack wires
    wire s_x1_s1, s_x2_s1, s_x3_s1, s_x4_s1;
    wire s_y1_s1, s_y2_s1, s_y3_s1, s_y4_s1;
    wire [7:0] e_x1_s1, e_x2_s1, e_x3_s1, e_x4_s1;
    wire [7:0] e_y1_s1, e_y2_s1, e_y3_s1, e_y4_s1;
    wire [23:0] m_x1_s1, m_x2_s1, m_x3_s1, m_x4_s1;
    wire [23:0] m_y1_s1, m_y2_s1, m_y3_s1, m_y4_s1;
    wire zero_x1_s1, zero_x2_s1, zero_x3_s1, zero_x4_s1;
    wire zero_y1_s1, zero_y2_s1, zero_y3_s1, zero_y4_s1;

    // FLP_unpack (same as原本)
    FLP_unpack unpack_x1 (.flp(x1), .precision(precision), .sign(s_x1_s1), .exp(e_x1_s1), .mant(m_x1_s1), .is_zero(zero_x1_s1));
    FLP_unpack unpack_x2 (.flp(x2), .precision(precision), .sign(s_x2_s1), .exp(e_x2_s1), .mant(m_x2_s1), .is_zero(zero_x2_s1));
    FLP_unpack unpack_x3 (.flp(x3), .precision(precision), .sign(s_x3_s1), .exp(e_x3_s1), .mant(m_x3_s1), .is_zero(zero_x3_s1));
    FLP_unpack unpack_x4 (.flp(x4), .precision(precision), .sign(s_x4_s1), .exp(e_x4_s1), .mant(m_x4_s1), .is_zero(zero_x4_s1));

    FLP_unpack unpack_y1 (.flp(y1), .precision(precision), .sign(s_y1_s1), .exp(e_y1_s1), .mant(m_y1_s1), .is_zero(zero_y1_s1));
    FLP_unpack unpack_y2 (.flp(y2), .precision(precision), .sign(s_y2_s1), .exp(e_y2_s1), .mant(m_y2_s1), .is_zero(zero_y2_s1));
    FLP_unpack unpack_y3 (.flp(y3), .precision(precision), .sign(s_y3_s1), .exp(e_y3_s1), .mant(m_y3_s1), .is_zero(zero_y3_s1));
    FLP_unpack unpack_y4 (.flp(y4), .precision(precision), .sign(s_y4_s1), .exp(e_y4_s1), .mant(m_y4_s1), .is_zero(zero_y4_s1));

    // Sign of products
    wire s_p1_s1 = s_x1_s1 ^ s_y1_s1;
    wire s_p2_s1 = s_x2_s1 ^ s_y2_s1;
    wire s_p3_s1 = s_x3_s1 ^ s_y3_s1;
    wire s_p4_s1 = s_x4_s1 ^ s_y4_s1;

    // Zero detection for products
    wire zero_p1_s1 = zero_x1_s1 | zero_y1_s1;
    wire zero_p2_s1 = zero_x2_s1 | zero_y2_s1;
    wire zero_p3_s1 = zero_x3_s1 | zero_y3_s1;
    wire zero_p4_s1 = zero_x4_s1 | zero_y4_s1;

    // Exponent for products: ex + ey - bias
    wire signed [9:0] e_p1_s1 = zero_p1_s1 ? 10'sd0 :
        ($signed({2'b0, e_x1_s1}) + $signed({2'b0, e_y1_s1}) - (precision ? 10'sd15 : 10'sd127));
    wire signed [9:0] e_p2_s1 = zero_p2_s1 ? 10'sd0 :
        ($signed({2'b0, e_x2_s1}) + $signed({2'b0, e_y2_s1}) - (precision ? 10'sd15 : 10'sd127));
    wire signed [9:0] e_p3_s1 = zero_p3_s1 ? 10'sd0 :
        ($signed({2'b0, e_x3_s1}) + $signed({2'b0, e_y3_s1}) - (precision ? 10'sd15 : 10'sd127));
    wire signed [9:0] e_p4_s1 = zero_p4_s1 ? 10'sd0 :
        ($signed({2'b0, e_x4_s1}) + $signed({2'b0, e_y4_s1}) - (precision ? 10'sd15 : 10'sd127));

    // Max exponent
    wire signed [9:0] emax_12_s1 = (e_p1_s1 > e_p2_s1) ? e_p1_s1 : e_p2_s1;
    wire signed [9:0] emax_34_s1 = (e_p3_s1 > e_p4_s1) ? e_p3_s1 : e_p4_s1;
    assign emax_s1 = (emax_12_s1 > emax_34_s1) ? emax_12_s1 : emax_34_s1;

    // Mantissa products (48-bit)
    wire [47:0] m_p1_s1 = zero_p1_s1 ? 48'd0 : (m_x1_s1 * m_y1_s1);
    wire [47:0] m_p2_s1 = zero_p2_s1 ? 48'd0 : (m_x2_s1 * m_y2_s1);
    wire [47:0] m_p3_s1 = zero_p3_s1 ? 48'd0 : (m_x3_s1 * m_y3_s1);
    wire [47:0] m_p4_s1 = zero_p4_s1 ? 48'd0 : (m_x4_s1 * m_y4_s1);

    // Exponent diff to emax
    wire signed [9:0] diff1_s1 = emax_s1 - e_p1_s1;
    wire signed [9:0] diff2_s1 = emax_s1 - e_p2_s1;
    wire signed [9:0] diff3_s1 = emax_s1 - e_p3_s1;
    wire signed [9:0] diff4_s1 = emax_s1 - e_p4_s1;

    // Shift amounts (saturate at 56)
    wire [6:0] shift1_s1 = (diff1_s1 >= 10'sd56) ? 7'd56 : diff1_s1[6:0];
    wire [6:0] shift2_s1 = (diff2_s1 >= 10'sd56) ? 7'd56 : diff2_s1[6:0];
    wire [6:0] shift3_s1 = (diff3_s1 >= 10'sd56) ? 7'd56 : diff3_s1[6:0];
    wire [6:0] shift4_s1 = (diff4_s1 >= 10'sd56) ? 7'd56 : diff4_s1[6:0];

    // Extend mantissa to 56 bits (padding 8 LSBs)
    wire [55:0] m_p1_ext_s1 = {m_p1_s1, 8'b0};
    wire [55:0] m_p2_ext_s1 = {m_p2_s1, 8'b0};
    wire [55:0] m_p3_ext_s1 = {m_p3_s1, 8'b0};
    wire [55:0] m_p4_ext_s1 = {m_p4_s1, 8'b0};

    // Right shift with saturation at 56
    wire [55:0] m_aligned1_s1 = (shift1_s1 >= 7'd56) ? 56'd0 : (m_p1_ext_s1 >> shift1_s1);
    wire [55:0] m_aligned2_s1 = (shift2_s1 >= 7'd56) ? 56'd0 : (m_p2_ext_s1 >> shift2_s1);
    wire [55:0] m_aligned3_s1 = (shift3_s1 >= 7'd56) ? 56'd0 : (m_p3_ext_s1 >> shift3_s1);
    wire [55:0] m_aligned4_s1 = (shift4_s1 >= 7'd56) ? 56'd0 : (m_p4_ext_s1 >> shift4_s1);

    // Sticky calculation using hardware-friendly prefix OR
    wire sticky1_s1, sticky2_s1, sticky3_s1, sticky4_s1;

    sticky_prefix_56bit STK1 (.data(m_p1_ext_s1), .shift_amt(shift1_s1), .sticky(sticky1_s1));
    sticky_prefix_56bit STK2 (.data(m_p2_ext_s1), .shift_amt(shift2_s1), .sticky(sticky2_s1));
    sticky_prefix_56bit STK3 (.data(m_p3_ext_s1), .shift_amt(shift3_s1), .sticky(sticky3_s1));
    sticky_prefix_56bit STK4 (.data(m_p4_ext_s1), .shift_amt(shift4_s1), .sticky(sticky4_s1));

    assign sticky_align_s1 = sticky1_s1 | sticky2_s1 | sticky3_s1 | sticky4_s1;

    // Signed aligned mantissas (Q-format, with sign)
    assign sm1_s1 = s_p1_s1 ? -$signed({1'b0, m_aligned1_s1}) : $signed({1'b0, m_aligned1_s1});
    assign sm2_s1 = s_p2_s1 ? -$signed({1'b0, m_aligned2_s1}) : $signed({1'b0, m_aligned2_s1});
    assign sm3_s1 = s_p3_s1 ? -$signed({1'b0, m_aligned3_s1}) : $signed({1'b0, m_aligned3_s1});
    assign sm4_s1 = s_p4_s1 ? -$signed({1'b0, m_aligned4_s1}) : $signed({1'b0, m_aligned4_s1});

endmodule

//==============================================================================
// Stage 2: Sum four partial products
//==============================================================================

module stage2 (
    input  signed [56:0] sm1_s2,
    input  signed [56:0] sm2_s2,
    input  signed [56:0] sm3_s2,
    input  signed [56:0] sm4_s2,
    output signed [58:0] sum_s2
);
    assign sum_s2 = sm1_s2 + sm2_s2 + sm3_s2 + sm4_s2;
endmodule

//==============================================================================
// Stage 3: Normalization (LOD_59bit, shift, exponent adjust, ovf/udf)
//==============================================================================

module stage3 (
    input  signed [58:0] sum_s3,
    input  signed [9:0]  emax_s3,
    input                precision_s3,
    output               sign_s3,
    output [58:0]        norm_s3,
    output signed [9:0]  exp_adj_s3,
    output               is_zero_s3,
    output               ovf_s3,
    output               udf_s3
);

    assign sign_s3 = sum_s3[58];

    wire [58:0] abs_sum_s3 = sign_s3 ? -sum_s3 : sum_s3;
    assign is_zero_s3 = (abs_sum_s3 == 59'd0);

    wire [5:0] lzc_s3;
    LOD_59bit lod (.in(abs_sum_s3), .lzc(lzc_s3));

    wire [5:0] lzc_lim_s3 = (lzc_s3 >= 6'd59) ? 6'd58 : lzc_s3;
    assign norm_s3 = abs_sum_s3 << lzc_lim_s3;

    // 指數調整：emax - lzc + 4
    wire signed [9:0] exp_adj_s3_int = emax_s3 - $signed({4'b0, lzc_lim_s3}) + 10'sd4;
    assign exp_adj_s3 = exp_adj_s3_int;

    assign ovf_s3  = (exp_adj_s3_int >= (precision_s3 ? 10'sd31 : 10'sd255));
    assign udf_s3  = (exp_adj_s3_int <= 10'sd0);

endmodule

//==============================================================================
// Stage 4: Rounding (FP32 / FP16) + Packing
//==============================================================================

module stage4 (
    input  [58:0]       norm_s4,
    input  signed [9:0] exp_adj_s4,
    input               sign_s4,
    input               is_zero_s4,
    input               ovf_s4,
    input               udf_s4,
    input               prec_s4,
    input               sticky_s4,
    output [31:0]       z_comb
);

    // 安全轉換 exponent
    wire [7:0] exp_u32 = (exp_adj_s4 <= 10'sd0)   ? 8'd0   :
                         (exp_adj_s4 >= 10'sd255) ? 8'd254 :
                         exp_adj_s4[7:0];

    wire [4:0] exp_u16 = (exp_adj_s4 <= 10'sd0)   ? 5'd0   :
                         (exp_adj_s4 >= 10'sd31)  ? 5'd30  :
                         exp_adj_s4[4:0];

    // FP32 rounding
    wire [25:0] m32_in = norm_s4[58:33];
    wire        st32   = |norm_s4[32:0] | sticky_s4;
    wire [22:0] m32_out;
    wire [7:0]  e32_out;

    FLP_round_fp32 r32 (
        .mant_in(m32_in),
        .sticky(st32),
        .exp_in(exp_u32),
        .sign(sign_s4),
        .mant_out(m32_out),
        .exp_out(e32_out)
    );

    // FP16 rounding
    wire [12:0] m16_in = norm_s4[58:46];
    wire        st16   = |norm_s4[45:0] | sticky_s4;
    wire [9:0]  m16_out;
    wire [4:0]  e16_out;

    FLP_round_fp16 r16 (
        .mant_in(m16_in),
        .sticky(st16),
        .exp_in(exp_u16),
        .sign(sign_s4),
        .mant_out(m16_out),
        .exp_out(e16_out)
    );

    // Packing
    FLP_pack packer (
        .sign(sign_s4),
        .exp_fp32(e32_out),
        .mant_fp32(m32_out),
        .exp_fp16(e16_out),
        .mant_fp16(m16_out),
        .precision(prec_s4),
        .is_zero(is_zero_s4 | udf_s4),
        .is_overflow(ovf_s4),
        .flp(z_comb)
    );

endmodule

//==============================================================================
// Submodules (unchanged logic)
//==============================================================================

//------------------------------------------------------------------------------
// FLP_unpack
//------------------------------------------------------------------------------

module FLP_unpack (
    input  [31:0] flp,
    input         precision,
    output        sign,
    output [7:0]  exp,
    output [23:0] mant,
    output        is_zero
);
    wire [15:0] fp16 = flp[31:16];
    assign sign = precision ? fp16[15] : flp[31];
    wire [7:0] e = precision ? {3'b0, fp16[14:10]} : flp[30:23];
    wire [22:0] m = precision ? {fp16[9:0], 13'b0} : flp[22:0];
    assign is_zero = (e == 8'd0);
    assign exp = e;
    assign mant = is_zero ? 24'd0 : {1'b1, m};
endmodule

//------------------------------------------------------------------------------
// LOD_59bit (Leading Zero Detection in custom form)
//------------------------------------------------------------------------------

module LOD_59bit (
    input  [58:0] in,
    output [5:0]  lzc
);
    wire [5:0] p [58:0];
    wire [58:0] v;

    assign v = in;

    // base case
    assign p[0] = v[0] ? 6'd58 : 6'd59;

    genvar i;
    generate
        for (i = 1; i < 59; i = i + 1) begin : GEN_LOD
            assign p[i] = v[i] ? (6'd58 - i[5:0]) : p[i-1];
        end
    endgenerate

    assign lzc = p[58];
endmodule

//------------------------------------------------------------------------------
// FLP_round_fp32
//------------------------------------------------------------------------------

module FLP_round_fp32 (
    input  [25:0] mant_in,
    input         sticky,
    input  [7:0]  exp_in,
    input         sign,
    output [22:0] mant_out,
    output [7:0]  exp_out
);
    wire [22:0] frac = mant_in[24:2];
    wire g = mant_in[1];
    wire r = mant_in[0];
    wire lsb = frac[0];
    
    wire rnd_up = g & (r | sticky | lsb);
    
    wire [23:0] rounded = {1'b0, frac} + (rnd_up ? 24'd1 : 24'd0);
    wire ovf = rounded[23];
    
    assign mant_out = ovf ? 23'd0 : rounded[22:0];
    assign exp_out = ovf ? (exp_in + 8'd1) : exp_in;
endmodule

//------------------------------------------------------------------------------
// FLP_round_fp16
//------------------------------------------------------------------------------

module FLP_round_fp16 (
    input  [12:0] mant_in,
    input         sticky,
    input  [4:0]  exp_in,
    input         sign,
    output [9:0]  mant_out,
    output [4:0]  exp_out
);
    wire [9:0] frac = mant_in[11:2];
    wire g = mant_in[1];
    wire r = mant_in[0];
    wire lsb = frac[0];
    
    wire rnd_up = g & (r | sticky | lsb);
    
    wire [10:0] rounded = {1'b0, frac} + (rnd_up ? 11'd1 : 11'd0);
    wire ovf = rounded[10];
    
    assign mant_out = ovf ? 10'd0 : rounded[9:0];
    assign exp_out = ovf ? (exp_in + 5'd1) : exp_in;
endmodule

//------------------------------------------------------------------------------
// FLP_pack
//------------------------------------------------------------------------------

module FLP_pack (
    input         sign,
    input  [7:0]  exp_fp32,
    input  [22:0] mant_fp32,
    input  [4:0]  exp_fp16,
    input  [9:0]  mant_fp16,
    input         precision,
    input         is_zero,
    input         is_overflow,
    output [31:0] flp
);
    wire of32 = is_overflow || (exp_fp32 >= 8'd255);
    wire of16 = is_overflow || (exp_fp16 >= 5'd31);
    
    wire [31:0] fp32 = is_zero ? {sign, 31'b0} :
                       of32 ? {sign, 8'hFF, 23'b0} :
                       {sign, exp_fp32, mant_fp32};
    
    wire [15:0] fp16 = is_zero ? {sign, 15'b0} :
                       of16 ? {sign, 5'h1F, 10'b0} :
                       {sign, exp_fp16, mant_fp16};
    
    assign flp = precision ? {fp16, 16'h0000} : fp32;
endmodule

//------------------------------------------------------------------------------
// sticky_prefix_56bit - DC-friendly prefix OR based sticky generator
//------------------------------------------------------------------------------

module sticky_prefix_56bit (
    input  [55:0] data,
    input  [6:0]  shift_amt,
    output        sticky
);

    wire [55:0] prefix;

    // prefix[i] = OR(data[i:0])
    assign prefix[0] = data[0];

    genvar k;
    generate
        for (k = 1; k < 56; k = k + 1) begin : GEN_PREFIX
            assign prefix[k] = prefix[k-1] | data[k];
        end
    endgenerate

    assign sticky =
        (shift_amt == 0)   ? 1'b0     :
        (shift_amt >= 56)  ? prefix[55] :
                             prefix[shift_amt-1];

endmodule
