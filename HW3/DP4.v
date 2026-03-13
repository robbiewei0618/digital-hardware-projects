//==============================================================================
// 模組: DP4 - 修正邊界條件邏輯（硬體友好版：移除 function automatic）
//==============================================================================
module DP4 (
    input  [31:0] x1, x2, x3, x4,
    input  [31:0] y1, y2, y3, y4,
    input         precision,
    output [31:0] z
);

    // =========================================================================
    // 階段1-2: 解包和乘法
    // =========================================================================
    wire s_x1, s_x2, s_x3, s_x4, s_y1, s_y2, s_y3, s_y4;
    wire [7:0] e_x1, e_x2, e_x3, e_x4, e_y1, e_y2, e_y3, e_y4;
    wire [23:0] m_x1, m_x2, m_x3, m_x4, m_y1, m_y2, m_y3, m_y4;
    wire zero_x1, zero_x2, zero_x3, zero_x4, zero_y1, zero_y2, zero_y3, zero_y4;
    
    FLP_unpack unpack_x1 (.flp(x1), .precision(precision), .sign(s_x1), .exp(e_x1), .mant(m_x1), .is_zero(zero_x1));
    FLP_unpack unpack_x2 (.flp(x2), .precision(precision), .sign(s_x2), .exp(e_x2), .mant(m_x2), .is_zero(zero_x2));
    FLP_unpack unpack_x3 (.flp(x3), .precision(precision), .sign(s_x3), .exp(e_x3), .mant(m_x3), .is_zero(zero_x3));
    FLP_unpack unpack_x4 (.flp(x4), .precision(precision), .sign(s_x4), .exp(e_x4), .mant(m_x4), .is_zero(zero_x4));
    FLP_unpack unpack_y1 (.flp(y1), .precision(precision), .sign(s_y1), .exp(e_y1), .mant(m_y1), .is_zero(zero_y1));
    FLP_unpack unpack_y2 (.flp(y2), .precision(precision), .sign(s_y2), .exp(e_y2), .mant(m_y2), .is_zero(zero_y2));
    FLP_unpack unpack_y3 (.flp(y3), .precision(precision), .sign(s_y3), .exp(e_y3), .mant(m_y3), .is_zero(zero_y3));
    FLP_unpack unpack_y4 (.flp(y4), .precision(precision), .sign(s_y4), .exp(e_y4), .mant(m_y4), .is_zero(zero_y4));
    
    wire s_p1 = s_x1 ^ s_y1;
    wire s_p2 = s_x2 ^ s_y2;
    wire s_p3 = s_x3 ^ s_y3;
    wire s_p4 = s_x4 ^ s_y4;
    
    wire zero_p1 = zero_x1 | zero_y1;
    wire zero_p2 = zero_x2 | zero_y2;
    wire zero_p3 = zero_x3 | zero_y3;
    wire zero_p4 = zero_x4 | zero_y4;
    
    wire signed [9:0] e_p1_s = zero_p1 ? 10'sd0 : ($signed({2'b0, e_x1}) + $signed({2'b0, e_y1}) - (precision ? 10'sd15 : 10'sd127));
    wire signed [9:0] e_p2_s = zero_p2 ? 10'sd0 : ($signed({2'b0, e_x2}) + $signed({2'b0, e_y2}) - (precision ? 10'sd15 : 10'sd127));
    wire signed [9:0] e_p3_s = zero_p3 ? 10'sd0 : ($signed({2'b0, e_x3}) + $signed({2'b0, e_y3}) - (precision ? 10'sd15 : 10'sd127));
    wire signed [9:0] e_p4_s = zero_p4 ? 10'sd0 : ($signed({2'b0, e_x4}) + $signed({2'b0, e_y4}) - (precision ? 10'sd15 : 10'sd127));
    
    wire [47:0] m_p1 = zero_p1 ? 48'd0 : (m_x1 * m_y1);
    wire [47:0] m_p2 = zero_p2 ? 48'd0 : (m_x2 * m_y2);
    wire [47:0] m_p3 = zero_p3 ? 48'd0 : (m_x3 * m_y3);
    wire [47:0] m_p4 = zero_p4 ? 48'd0 : (m_x4 * m_y4);
    
    // =========================================================================
    // 階段3: 對齊（修正邊界邏輯）
    // =========================================================================
    wire signed [9:0] emax_12 = (e_p1_s > e_p2_s) ? e_p1_s : e_p2_s;
    wire signed [9:0] emax_34 = (e_p3_s > e_p4_s) ? e_p3_s : e_p4_s;
    wire signed [9:0] emax = (emax_12 > emax_34) ? emax_12 : emax_34;
    
    wire signed [9:0] diff1 = emax - e_p1_s;
    wire signed [9:0] diff2 = emax - e_p2_s;
    wire signed [9:0] diff3 = emax - e_p3_s;
    wire signed [9:0] diff4 = emax - e_p4_s;
    
    wire [6:0] max_shift = precision ? 7'd25 : 7'd51;
    wire [6:0] shift1 = (diff1 > {3'b0, max_shift}) ? max_shift : diff1[6:0];
    wire [6:0] shift2 = (diff2 > {3'b0, max_shift}) ? max_shift : diff2[6:0];
    wire [6:0] shift3 = (diff3 > {3'b0, max_shift}) ? max_shift : diff3[6:0];
    wire [6:0] shift4 = (diff4 > {3'b0, max_shift}) ? max_shift : diff4[6:0];
    
    // 根據精度擴展
    wire [51:0] m_p1_ext = precision ? {m_p1[47:26], 30'b0} : {m_p1, 4'b0};
    wire [51:0] m_p2_ext = precision ? {m_p2[47:26], 30'b0} : {m_p2, 4'b0};
    wire [51:0] m_p3_ext = precision ? {m_p3[47:26], 30'b0} : {m_p3, 4'b0};
    wire [51:0] m_p4_ext = precision ? {m_p4[47:26], 30'b0} : {m_p4, 4'b0};
    
    // FP16截斷sticky
    wire trunc_sticky1_16 = |m_p1[25:0];
    wire trunc_sticky2_16 = |m_p2[25:0];
    wire trunc_sticky3_16 = |m_p3[25:0];
    wire trunc_sticky4_16 = |m_p4[25:0];
    wire trunc_sticky_16 = trunc_sticky1_16 | trunc_sticky2_16 | trunc_sticky3_16 | trunc_sticky4_16;
    
    // ========= 這裡是原本的 calc_align_sticky()，改成硬體友好寫法 =========
    // mask = 低 shift 位為 1，其餘為 0，然後做 AND + OR reduction
    
    localparam [51:0] FULL_ONES_52 = 52'hFFFFFFFFFFFFF;  // 52 bits 全 1
    
    wire [51:0] mask1 = (shift1 == 7'd0) ? 52'd0 : (FULL_ONES_52 >> (52 - shift1));
    wire [51:0] mask2 = (shift2 == 7'd0) ? 52'd0 : (FULL_ONES_52 >> (52 - shift2));
    wire [51:0] mask3 = (shift3 == 7'd0) ? 52'd0 : (FULL_ONES_52 >> (52 - shift3));
    wire [51:0] mask4 = (shift4 == 7'd0) ? 52'd0 : (FULL_ONES_52 >> (52 - shift4));
    
    wire align_sticky1 = |(m_p1_ext & mask1);
    wire align_sticky2 = |(m_p2_ext & mask2);
    wire align_sticky3 = |(m_p3_ext & mask3);
    wire align_sticky4 = |(m_p4_ext & mask4);
    
    wire align_sticky = align_sticky1 | align_sticky2 | align_sticky3 | align_sticky4;
    // ========= 到這裡為止，邏輯等價於原本的 calc_align_sticky() =========
    
    // 執行右移對齊
    wire [51:0] m_aligned1 = m_p1_ext >> shift1;
    wire [51:0] m_aligned2 = m_p2_ext >> shift2;
    wire [51:0] m_aligned3 = m_p3_ext >> shift3;
    wire [51:0] m_aligned4 = m_p4_ext >> shift4;
    
    // =========================================================================
    // 階段4: 加法
    // =========================================================================
    wire signed [54:0] sm1 = s_p1 ? -$signed({3'b0, m_aligned1}) : $signed({3'b0, m_aligned1});
    wire signed [54:0] sm2 = s_p2 ? -$signed({3'b0, m_aligned2}) : $signed({3'b0, m_aligned2});
    wire signed [54:0] sm3 = s_p3 ? -$signed({3'b0, m_aligned3}) : $signed({3'b0, m_aligned3});
    wire signed [54:0] sm4 = s_p4 ? -$signed({3'b0, m_aligned4}) : $signed({3'b0, m_aligned4});
    
    wire signed [54:0] sum = sm1 + sm2 + sm3 + sm4;
    wire sign_result = sum[54];
    wire [54:0] abs_sum = sum[54] ? -sum : sum;
    
    // =========================================================================
    // 階段5: 正規化
    // =========================================================================
    wire [5:0] lzc;
    LOD_55bit lod (.in(abs_sum), .lzc(lzc));
    
    wire [54:0] normalized = abs_sum << lzc;
    
    wire signed [9:0] exp_adjusted_raw = emax - $signed({4'b0, lzc}) + 10'sd4;
    
    wire [9:0] max_exp = precision ? 10'd31 : 10'd255;
    wire overflow  = (exp_adjusted_raw >= $signed({1'b0, max_exp}));
    wire underflow = (exp_adjusted_raw <= 10'sd0) | (abs_sum == 55'd0);
    
    wire [7:0] exp_adjusted = underflow ? 8'd0 : exp_adjusted_raw[7:0];
    wire result_zero = underflow;
    
    // =========================================================================
    // 階段6: 舍入（優化sticky範圍）
    // =========================================================================
    wire [25:0] mant_to_round;
    wire sticky;
    
    assign mant_to_round = normalized[54:29];
    
    assign sticky = precision ?
        (|normalized[28:0] | align_sticky | trunc_sticky_16) :  // FP16
        (|normalized[28:0] | align_sticky);                     // FP32
    
    wire [23:0] mant_rounded;
    wire [7:0] exp_final;
    
    FLP_round rounder (
        .mant_in(mant_to_round),
        .sticky(sticky),
        .exp_in(exp_adjusted),
        .sign(sign_result),
        .precision(precision),
        .mant_out(mant_rounded),
        .exp_out(exp_final)
    );
    
    // =========================================================================
    // 階段7: 打包
    // =========================================================================
    FLP_pack packer (
        .sign(sign_result),
        .exp(exp_final),
        .mant(mant_rounded),
        .precision(precision),
        .is_zero(result_zero),
        .is_overflow(overflow),
        .flp(z)
    );

endmodule

// -----------------------------------------------------------------------------
// 子模組維持不變
// -----------------------------------------------------------------------------
module FLP_unpack (
    input  [31:0] flp,
    input         precision,
    output        sign,
    output [7:0]  exp,
    output [23:0] mant,
    output        is_zero
);
    wire [15:0] fp16_data = flp[31:16];
    assign sign = precision ? fp16_data[15] : flp[31];
    wire [7:0] exp_raw = precision ? {3'b0, fp16_data[14:10]} : flp[30:23];
    wire [22:0] mant_raw = precision ? {fp16_data[9:0], 13'b0} : flp[22:0];
    assign is_zero = (exp_raw == 8'd0);
    assign exp = exp_raw;
    assign mant = is_zero ? 24'd0 : {1'b1, mant_raw};
endmodule


module LOD_55bit (
    input  [54:0] in,
    output [5:0]  lzc
);
    wire [5:0] p [54:0];
    wire [54:0] v;

    assign v = in;

    // base case
    assign p[0] = v[0] ? 6'd54 : 6'd55;

    genvar i;
    generate
        for (i = 1; i < 55; i = i + 1) begin : GEN_LOD
            assign p[i] = v[i] ? (6'd54 - i[5:0]) : p[i-1];
        end
    endgenerate

    assign lzc = p[54];
endmodule
module FLP_round (
    input  [25:0] mant_in,
    input         sticky,
    input  [7:0]  exp_in,
    input         sign,
    input         precision,
    output [23:0] mant_out,
    output [7:0]  exp_out
);
    wire [23:0] mant_trunc;
    wire guard, round_bit, lsb;

    // ---------- mantissa truncation & G/R/LSB keep same ----------
    assign mant_trunc = precision ? {mant_in[25:15], 13'b0} : mant_in[25:2];
    assign guard      = precision ? mant_in[14] : mant_in[1];
    assign round_bit  = precision ? mant_in[13] : mant_in[0];
    assign lsb        = precision ? mant_in[15] : mant_in[2];

    // ---------- only fix: FP16 sticky must include mant_in[12:0] ----------
    wire sticky_eff = precision ?
                      (sticky | (|mant_in[12:0])) :   // FP16: add truncated bits inside mant_in
                      sticky;                          // FP32: unchanged

    // Round-to-nearest-even
    wire round_up = guard & (round_bit | sticky_eff | lsb);

    wire [24:0] rounding_increment = precision ? 25'h2000 : 25'h1;
    wire [24:0] mant_rounded_temp  = {1'b0, mant_trunc} + (round_up ? rounding_increment : 25'd0);

    wire       mant_overflow = mant_rounded_temp[24];
    wire [7:0] max_exp       = precision ? 8'd30 : 8'd254;
    wire       will_overflow = mant_overflow & (exp_in == max_exp);

    assign mant_out = will_overflow ? 24'd0 :
                      (mant_overflow ? mant_rounded_temp[24:1] : mant_rounded_temp[23:0]);

    assign exp_out  = will_overflow ? (max_exp + 8'd1) :
                      (mant_overflow ? (exp_in + 8'd1) : exp_in);
endmodule


module FLP_pack (
    input         sign,
    input  [7:0]  exp,
    input  [23:0] mant,
    input         precision,
    input         is_zero,
    input         is_overflow,
    output [31:0] flp
);
    wire [31:0] fp32_final = is_zero     ? {sign, 31'b0} :
                             is_overflow ? {sign, 8'hFF, 23'b0} :
                                           {sign, exp[7:0], mant[22:0]};
    wire [15:0] fp16_final = is_zero     ? {sign, 15'b0} :
                             is_overflow ? {sign, 5'h1F, 10'b0} :
                                           {sign, exp[4:0], mant[22:13]};
    assign flp = precision ? {fp16_final, 16'h0000} : fp32_final;
endmodule
