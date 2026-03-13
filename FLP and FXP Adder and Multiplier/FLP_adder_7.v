// ============================================================
// File: FLP_adder_7.v
// 7 級 pipeline（更細分以提高頻率）
// s0: Unpack/特殊值/去bias/建 mant
// s1: 比較交換（選出 exp_big/mant_big / exp_small/mant_small）
// s2: 計算 Δexp、alignment（含 alignment sticky）
// s3: 有號加法 → 取絕對值
// s4: LZC → 計算 shift / 做 normalize（含 normalize右移 sticky）
// s5: round(ties-to-even) → re-normalize
// s6: pack（含 OF/UF/特殊值）
// ============================================================
module FLP_adder_7 (
  input  wire        clk,
  input  wire        rst,
  input  wire [31:0] a,
  input  wire [31:0] b,
  output reg  [31:0] d
);
  localparam BIAS = 8'd127;

  // -------- s0 --------
  wire        s0_sign_a    = a[31];
  wire        s0_sign_b    = b[31];
  wire [7:0]  s0_exp_a_raw = a[30:23];
  wire [7:0]  s0_exp_b_raw = b[30:23];
  wire [22:0] s0_frac_a    = a[22:0];
  wire [22:0] s0_frac_b    = b[22:0];

  wire s0_a_is_zero = (s0_exp_a_raw==8'd0) && (s0_frac_a==23'd0);
  wire s0_b_is_zero = (s0_exp_b_raw==8'd0) && (s0_frac_b==23'd0);
  wire s0_a_is_inf  = (s0_exp_a_raw==8'hFF) && (s0_frac_a==23'd0);
  wire s0_b_is_inf  = (s0_exp_b_raw==8'hFF) && (s0_frac_b==23'd0);
  wire s0_a_is_nan  = (s0_exp_a_raw==8'hFF) && (s0_frac_a!=23'd0);
  wire s0_b_is_nan  = (s0_exp_b_raw==8'hFF) && (s0_frac_b!=23'd0);

  wire signed [8:0] s0_exp_a_s = (s0_exp_a_raw==8'd0) ? 9'sd1 - $signed({1'b0,BIAS})
                                                      : $signed({1'b0,s0_exp_a_raw}) - $signed({1'b0,BIAS});
  wire signed [8:0] s0_exp_b_s = (s0_exp_b_raw==8'd0) ? 9'sd1 - $signed({1'b0,BIAS})
                                                      : $signed({1'b0,s0_exp_b_raw}) - $signed({1'b0,BIAS});

  wire [27:0] s0_mant_a_u = {2'b00, (s0_exp_a_raw==8'd0)?1'b0:1'b1, s0_frac_a, 2'b00};
  wire [27:0] s0_mant_b_u = {2'b00, (s0_exp_b_raw==8'd0)?1'b0:1'b1, s0_frac_b, 2'b00};

  wire signed [27:0] s0_mant_a_s = s0_sign_a ? -$signed(s0_mant_a_u) : $signed(s0_mant_a_u);
  wire signed [27:0] s0_mant_b_s = s0_sign_b ? -$signed(s0_mant_b_u) : $signed(s0_mant_b_u);

  reg        r1_a_is_zero, r1_b_is_zero, r1_a_is_inf, r1_b_is_inf, r1_a_is_nan, r1_b_is_nan;
  reg signed [8:0]  r1_exp_a_s, r1_exp_b_s;
  reg signed [27:0] r1_mant_a_s, r1_mant_b_s;
  always @(posedge clk) begin
    if (rst) begin
      r1_a_is_zero<=0; r1_b_is_zero<=0; r1_a_is_inf<=0; r1_b_is_inf<=0; r1_a_is_nan<=0; r1_b_is_nan<=0;
      r1_exp_a_s<=0; r1_exp_b_s<=0; r1_mant_a_s<=0; r1_mant_b_s<=0;
    end else begin
      r1_a_is_zero<=s0_a_is_zero; r1_b_is_zero<=s0_b_is_zero;
      r1_a_is_inf <=s0_a_is_inf ; r1_b_is_inf <=s0_b_is_inf ;
      r1_a_is_nan <=s0_a_is_nan ; r1_b_is_nan <=s0_b_is_nan ;
      r1_exp_a_s  <=s0_exp_a_s;   r1_exp_b_s  <=s0_exp_b_s;
      r1_mant_a_s <=s0_mant_a_s;  r1_mant_b_s <=s0_mant_b_s;
    end
  end

  // -------- s1（交換）--------
  wire swap1 = (r1_exp_a_s < r1_exp_b_s);
  wire signed [8:0]  s1_exp_big_s   = swap1 ? r1_exp_b_s : r1_exp_a_s;
  wire signed [8:0]  s1_exp_small_s = swap1 ? r1_exp_a_s : r1_exp_b_s;
  wire signed [27:0] s1_mant_big    = swap1 ? r1_mant_b_s: r1_mant_a_s;
  wire signed [27:0] s1_mant_small  = swap1 ? r1_mant_a_s: r1_mant_b_s;

  reg        r2_a_is_zero, r2_b_is_zero, r2_a_is_inf, r2_b_is_inf, r2_a_is_nan, r2_b_is_nan;
  reg signed [8:0]  r2_exp_big_s, r2_exp_small_s;
  reg signed [27:0] r2_mant_big, r2_mant_small;
  always @(posedge clk) begin
    if (rst) begin
      r2_a_is_zero<=0; r2_b_is_zero<=0; r2_a_is_inf<=0; r2_b_is_inf<=0; r2_a_is_nan<=0; r2_b_is_nan<=0;
      r2_exp_big_s<=0; r2_exp_small_s<=0; r2_mant_big<=0; r2_mant_small<=0;
    end else begin
      r2_a_is_zero<=r1_a_is_zero; r2_b_is_zero<=r1_b_is_zero;
      r2_a_is_inf <=r1_a_is_inf ; r2_b_is_inf <=r1_b_is_inf ;
      r2_a_is_nan <=r1_a_is_nan ; r2_b_is_nan <=r1_b_is_nan ;
      r2_exp_big_s<=s1_exp_big_s; r2_exp_small_s<=s1_exp_small_s;
      r2_mant_big <=s1_mant_big;  r2_mant_small  <=s1_mant_small;
    end
  end

  // -------- s2（對齊 + alignment sticky）--------
  wire signed [8:0]  s2_de_s = r2_exp_big_s - r2_exp_small_s;
  wire        [8:0]  s2_de   = $unsigned(s2_de_s);
  wire               s2_ge_26= (s2_de >= 9'd26);

  wire [27:0] s2_small_mag = r2_mant_small[27] ? (~r2_mant_small + 28'd1) : r2_mant_small;
  function [27:0] low_mask28;
    input [4:0] n; integer k;
    begin
      low_mask28 = 28'd0;
      for (k=0; k<28; k=k+1)
        if (k < n) low_mask28[k] = 1'b1;
    end
  endfunction

  wire [27:0] s2_small_mag_shift = s2_ge_26 ? 28'd0 : (s2_small_mag >> s2_de[4:0]);
  wire signed [27:0] s2_small_al =
      r2_mant_small[27] ? -$signed(s2_small_mag_shift) : $signed(s2_small_mag_shift);

  wire s2_sticky_align =
      s2_ge_26 ? (|s2_small_mag) :
      (s2_de[4:0]==5'd0) ? 1'b0 :
      |(s2_small_mag & low_mask28(s2_de[4:0]));

  reg        r3_a_is_zero, r3_b_is_zero, r3_a_is_inf, r3_b_is_inf, r3_a_is_nan, r3_b_is_nan;
  reg signed [8:0]  r3_exp_big_s;
  reg signed [27:0] r3_mant_big, r3_mant_small_al;
  reg               r3_sticky_align;
  always @(posedge clk) begin
    if (rst) begin
      r3_a_is_zero<=0; r3_b_is_zero<=0; r3_a_is_inf<=0; r3_b_is_inf<=0; r3_a_is_nan<=0; r3_b_is_nan<=0;
      r3_exp_big_s<=0; r3_mant_big<=0; r3_mant_small_al<=0; r3_sticky_align<=0;
    end else begin
      r3_a_is_zero<=r2_a_is_zero; r3_b_is_zero<=r2_b_is_zero;
      r3_a_is_inf <=r2_a_is_inf ; r3_b_is_inf <=r2_b_is_inf ;
      r3_a_is_nan <=r2_a_is_nan ; r3_b_is_nan <=r2_b_is_nan ;
      r3_exp_big_s<=r2_exp_big_s;
      r3_mant_big<=r2_mant_big; r3_mant_small_al<=s2_small_al;
      r3_sticky_align<=s2_sticky_align;
    end
  end

  // -------- s3（有號加法 → 絕對值）--------
  wire signed [27:0] s3_sum_s = r3_mant_big + r3_mant_small_al;
  wire               s3_sign  = s3_sum_s[27];
  wire [27:0]        s3_abs   = s3_sign ? (~s3_sum_s + 28'd1) : s3_sum_s;

  reg        r4_a_is_zero, r4_b_is_zero, r4_a_is_inf, r4_b_is_inf, r4_a_is_nan, r4_b_is_nan;
  reg        r4_sign;
  reg [27:0] r4_abs;
  reg signed [8:0] r4_exp_big_s;
  reg        r4_sticky_align;
  always @(posedge clk) begin
    if (rst) begin
      r4_a_is_zero<=0; r4_b_is_zero<=0; r4_a_is_inf<=0; r4_b_is_inf<=0; r4_a_is_nan<=0; r4_b_is_nan<=0;
      r4_sign<=0; r4_abs<=0; r4_exp_big_s<=0; r4_sticky_align<=0;
    end else begin
      r4_a_is_zero<=r3_a_is_zero; r4_b_is_zero<=r3_b_is_zero;
      r4_a_is_inf <=r3_a_is_inf ; r4_b_is_inf <=r3_b_is_inf ;
      r4_a_is_nan <=r3_a_is_nan ; r4_b_is_nan <=r3_b_is_nan ;
      r4_sign<=s3_sign; r4_abs<=s3_abs; r4_exp_big_s<=r3_exp_big_s;
      r4_sticky_align<=r3_sticky_align;
    end
  end

  // -------- s4（LZC→shift→normalize + normalize 右移 sticky）--------
  function [5:0] lzc28;
    input [27:0] x; integer i; reg found;
    begin
      lzc28 = 6'd28; found=1'b0;
      for (i=27;i>=0 && !found;i=i-1)
        if (x[i]) begin lzc28=6'd27-i; found=1'b1; end
    end
  endfunction

  wire [5:0]        s4_lzc   = lzc28(r4_abs);
  wire signed [6:0] s4_shift = $signed({1'b0,s4_lzc}) - 7'sd2;
  wire [27:0] s4_norm_pre =
      (s4_shift == -7'sd1) ? (r4_abs >> 1) :
      (s4_shift >  7'sd0)  ? (r4_abs << s4_shift[5:0]) :
                             r4_abs;
  wire signed [9:0] s4_exp_pre = {{1{r4_exp_big_s[8]}}, r4_exp_big_s} - s4_shift;
  wire s4_sticky_norm = (s4_shift == -7'sd1) ? r4_abs[0] : 1'b0;

  reg        r5_a_is_zero, r5_b_is_zero, r5_a_is_inf, r5_b_is_inf, r5_a_is_nan, r5_b_is_nan;
  reg        r5_sign;
  reg [27:0] r5_norm_pre;
  reg signed [9:0] r5_exp_pre;
  reg        r5_sticky_all;
  always @(posedge clk) begin
    if (rst) begin
      r5_a_is_zero<=0; r5_b_is_zero<=0; r5_a_is_inf<=0; r5_b_is_inf<=0; r5_a_is_nan<=0; r5_b_is_nan<=0;
      r5_sign<=0; r5_norm_pre<=0; r5_exp_pre<=0; r5_sticky_all<=0;
    end else begin
      r5_a_is_zero<=r4_a_is_zero; r5_b_is_zero<=r4_b_is_zero;
      r5_a_is_inf <=r4_a_is_inf ; r5_b_is_inf <=r4_b_is_inf ;
      r5_a_is_nan <=r4_a_is_nan ; r5_b_is_nan <=r4_b_is_nan ;
      r5_sign<=r4_sign; r5_norm_pre<=s4_norm_pre; r5_exp_pre<=s4_exp_pre;
      r5_sticky_all<= r4_sticky_align | s4_sticky_norm;
    end
  end

  // -------- s5（round → renorm）--------
  wire lsb_keep = r5_norm_pre[2];
  wire guard    = r5_norm_pre[1];
  wire sticky_r = r5_norm_pre[0] | r5_sticky_all;

  wire round_up = guard & (sticky_r | lsb_keep);
  wire [27:0] s5_round = round_up ? (r5_norm_pre + 28'd4) : r5_norm_pre;

  wire s5_need_renorm = s5_round[26];
  wire [27:0] s5_mant_final = s5_need_renorm ? (s5_round >> 1) : s5_round;
  wire signed [9:0] s5_exp_final_s = s5_need_renorm ? (r5_exp_pre + 10'sd1) : r5_exp_pre;

  reg        r6_a_is_zero, r6_b_is_zero, r6_a_is_inf, r6_b_is_inf, r6_a_is_nan, r6_b_is_nan;
  reg        r6_sign;
  reg [27:0] r6_mant_final;
  reg signed [9:0] r6_exp_final_s;
  always @(posedge clk) begin
    if (rst) begin
      r6_a_is_zero<=0; r6_b_is_zero<=0; r6_a_is_inf<=0; r6_b_is_inf<=0; r6_a_is_nan<=0; r6_b_is_nan<=0;
      r6_sign<=0; r6_mant_final<=0; r6_exp_final_s<=0;
    end else begin
      r6_a_is_zero<=r5_a_is_zero; r6_b_is_zero<=r5_b_is_zero;
      r6_a_is_inf <=r5_a_is_inf ; r6_b_is_inf <=r5_b_is_inf ;
      r6_a_is_nan <=r5_a_is_nan ; r6_b_is_nan <=r5_b_is_nan ;
      r6_sign<=r5_sign; r6_mant_final<=s5_mant_final; r6_exp_final_s<=s5_exp_final_s;
    end
  end

  // -------- s6（pack）--------
  wire signed [10:0] s6_exp_bias_s11 = {{1{r6_exp_final_s[9]}}, r6_exp_final_s} + 11'sd127;
  wire s6_overflow  = (s6_exp_bias_s11 >= 11'sd255);
  wire s6_underflow = (s6_exp_bias_s11 <= 11'sd0);

  wire [7:0]  s6_exp_biased = s6_exp_bias_s11[7:0];
  wire [23:0] s6_mant24     = r6_mant_final[25:2];

  wire s6_inf_sign = r6_a_is_inf ? a[31] : b[31];
  wire s6_both_zero = r6_a_is_zero & r6_b_is_zero;

  wire [31:0] s6_res_normal    = { r6_sign, s6_exp_biased, s6_mant24[22:0] };
  wire [31:0] s6_res_zero      = { r6_sign, 8'd0,          23'd0 };
  wire [31:0] s6_res_inf       = { s6_inf_sign,8'hFF,      23'd0 };
  wire [31:0] s6_res_overflow  = { r6_sign, 8'hFF,         23'd0 };
  wire [31:0] s6_res_underflow = { r6_sign, 8'd0,          23'd0 };
  wire [31:0] s6_res_nan       = { 1'b0,    8'hFF,         23'h400000 };

  wire [31:0] s6_res_comb =
      (r6_a_is_nan | r6_b_is_nan | (r6_a_is_inf & r6_b_is_inf & (a[31]^b[31]))) ? s6_res_nan :
      (r6_a_is_inf | r6_b_is_inf) ? s6_res_inf :
      (s6_both_zero | (r6_mant_final==28'd0)) ? s6_res_zero :
      s6_overflow  ? s6_res_overflow :
      s6_underflow ? s6_res_underflow :
                     s6_res_normal;

  always @(posedge clk) begin
    if (rst) d <= 32'h0;
    else     d <= s6_res_comb;
  end
endmodule
