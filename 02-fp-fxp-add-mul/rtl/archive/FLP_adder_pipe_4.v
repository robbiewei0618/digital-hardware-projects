// ============================================================
// File: FLP_adder_4.v
// 4 級 pipeline（每級說明見下）
// stage0: Unpack / 特殊值偵測 / 轉 Q3.25 / exponent 去 bias
// stage1: 交換 + 對齊（含 alignment sticky）
// stage2: 相加 → 絕對值 → LZC/shift → normalize（含 normalize右移丟棄位 sticky）
// stage3: round (ties-to-even) → re-normalize → pack（含 OF/UF/特殊值）
// ============================================================
module FLP_adder_4 (
  input  wire        clk,
  input  wire        rst,       // 同步高態 reset
  input  wire [31:0] a,
  input  wire [31:0] b,
  output reg  [31:0] d
);
  localparam BIAS = 8'd127;

  // ---------------- stage0 ----------------
  // Unpack + 特殊值 + mant/Q3.25 + exponent 去 bias
  // ---------------------------------------
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

  // 暫存（stage0 → stage1）
  reg        r1_a_is_zero, r1_b_is_zero, r1_a_is_inf, r1_b_is_inf, r1_a_is_nan, r1_b_is_nan;
  reg signed [8:0]  r1_exp_a_s, r1_exp_b_s;
  reg signed [27:0] r1_mant_a_s, r1_mant_b_s;

  always @(posedge clk) begin
    if (rst) begin
      r1_a_is_zero<=0; r1_b_is_zero<=0; r1_a_is_inf<=0; r1_b_is_inf<=0; r1_a_is_nan<=0; r1_b_is_nan<=0;
      r1_exp_a_s <= 0; r1_exp_b_s <= 0;
      r1_mant_a_s<= 0; r1_mant_b_s<= 0;
    end else begin
      r1_a_is_zero<= s0_a_is_zero; r1_b_is_zero<= s0_b_is_zero;
      r1_a_is_inf <= s0_a_is_inf ; r1_b_is_inf <= s0_b_is_inf ;
      r1_a_is_nan <= s0_a_is_nan ; r1_b_is_nan <= s0_b_is_nan ;
      r1_exp_a_s  <= s0_exp_a_s;   r1_exp_b_s  <= s0_exp_b_s;
      r1_mant_a_s <= s0_mant_a_s;  r1_mant_b_s <= s0_mant_b_s;
    end
  end

  // ---------------- stage1 ----------------
  // 交換 + 對齊（含 alignment sticky）
  // ---------------------------------------
  wire swap1 = (r1_exp_a_s < r1_exp_b_s);
  wire signed [8:0]  s1_exp_big_s   = swap1 ? r1_exp_b_s : r1_exp_a_s;
  wire signed [8:0]  s1_exp_small_s = swap1 ? r1_exp_a_s : r1_exp_b_s;
  wire signed [27:0] s1_mant_big    = swap1 ? r1_mant_b_s: r1_mant_a_s;
  wire signed [27:0] s1_mant_small  = swap1 ? r1_mant_a_s: r1_mant_b_s;

  wire signed [8:0]  s1_de_s = s1_exp_big_s - s1_exp_small_s;
  wire        [8:0]  s1_de   = $unsigned(s1_de_s);
  wire s1_de_ge_26 = (s1_de >= 9'd26);

  wire [27:0] s1_mant_small_mag = s1_mant_small[27] ? (~s1_mant_small + 28'd1) : s1_mant_small;

  function [27:0] low_mask28;
    input [4:0] n; integer k;
    begin
      low_mask28 = 28'd0;
      for (k=0; k<28; k=k+1)
        if (k < n) low_mask28[k] = 1'b1;
    end
  endfunction

  wire [27:0] s1_small_mag_shift = s1_de_ge_26 ? 28'd0 : (s1_mant_small_mag >> s1_de[4:0]);
  wire signed [27:0] s1_mant_small_al =
      s1_mant_small[27] ? -$signed(s1_small_mag_shift) : $signed(s1_small_mag_shift);

  wire s1_sticky_align =
      s1_de_ge_26               ? (|s1_mant_small_mag) :
      (s1_de[4:0]==5'd0)        ? 1'b0 :
      |(s1_mant_small_mag & low_mask28(s1_de[4:0]));

  // 暫存（stage1 → stage2）
  reg        r2_a_is_zero, r2_b_is_zero, r2_a_is_inf, r2_b_is_inf, r2_a_is_nan, r2_b_is_nan;
  reg signed [8:0]  r2_exp_big_s;
  reg signed [27:0] r2_mant_big, r2_mant_small_al;
  reg               r2_sticky_align;

  always @(posedge clk) begin
    if (rst) begin
      r2_a_is_zero<=0; r2_b_is_zero<=0; r2_a_is_inf<=0; r2_b_is_inf<=0; r2_a_is_nan<=0; r2_b_is_nan<=0;
      r2_exp_big_s<=0;
      r2_mant_big <=0; r2_mant_small_al<=0;
      r2_sticky_align<=0;
    end else begin
      r2_a_is_zero<= r1_a_is_zero; r2_b_is_zero<= r1_b_is_zero;
      r2_a_is_inf <= r1_a_is_inf ; r2_b_is_inf <= r1_b_is_inf ;
      r2_a_is_nan <= r1_a_is_nan ; r2_b_is_nan <= r1_b_is_nan ;
      r2_exp_big_s<= s1_exp_big_s;
      r2_mant_big <= s1_mant_big;
      r2_mant_small_al <= s1_mant_small_al;
      r2_sticky_align  <= s1_sticky_align;
    end
  end

  // ---------------- stage2 ----------------
  // 相加 → 絕對值 → LZC/shift → normalize（含 normalize右移 sticky）
  // ---------------------------------------
  wire signed [27:0] s2_sum_s = r2_mant_big + r2_mant_small_al;
  wire               s2_sign  = s2_sum_s[27];
  wire [27:0]        s2_abs   = s2_sign ? (~s2_sum_s + 28'd1) : s2_sum_s;

  function [5:0] lzc28;
    input [27:0] x; integer i; reg found;
    begin
      lzc28 = 6'd28; found=1'b0;
      for (i=27;i>=0 && !found;i=i-1)
        if (x[i]) begin lzc28=6'd27-i; found=1'b1; end
    end
  endfunction

  wire [5:0]           s2_lzc   = lzc28(s2_abs);
  wire signed [6:0]    s2_shift = $signed({1'b0,s2_lzc}) - 7'sd2;
  wire [27:0] s2_norm_pre =
      (s2_shift == -7'sd1) ? (s2_abs >> 1) :
      (s2_shift >  7'sd0)  ? (s2_abs << s2_shift[5:0]) :
                             s2_abs;
  wire signed [9:0] s2_exp_pre = {{1{r2_exp_big_s[8]}}, r2_exp_big_s} - s2_shift;

  wire s2_sticky_norm = (s2_shift == -7'sd1) ? s2_abs[0] : 1'b0;

  // 暫存（stage2 → stage3）
  reg        r3_a_is_zero, r3_b_is_zero, r3_a_is_inf, r3_b_is_inf, r3_a_is_nan, r3_b_is_nan;
  reg        r3_sign;
  reg [27:0] r3_norm_pre;
  reg signed [9:0] r3_exp_pre;
  reg        r3_sticky_all;

  always @(posedge clk) begin
    if (rst) begin
      r3_a_is_zero<=0; r3_b_is_zero<=0; r3_a_is_inf<=0; r3_b_is_inf<=0; r3_a_is_nan<=0; r3_b_is_nan<=0;
      r3_sign<=0; r3_norm_pre<=0; r3_exp_pre<=0; r3_sticky_all<=0;
    end else begin
      r3_a_is_zero<= r2_a_is_zero; r3_b_is_zero<= r2_b_is_zero;
      r3_a_is_inf <= r2_a_is_inf ; r3_b_is_inf <= r2_b_is_inf ;
      r3_a_is_nan <= r2_a_is_nan ; r3_b_is_nan <= r2_b_is_nan ;
      r3_sign     <= s2_sign;
      r3_norm_pre <= s2_norm_pre;
      r3_exp_pre  <= s2_exp_pre;
      r3_sticky_all <= r2_sticky_align | s2_sticky_norm;
    end
  end

  // ---------------- stage3 ----------------
  // round → renorm → pack（含 OF/UF/特殊值）
  // ---------------------------------------
  wire lsb_keep = r3_norm_pre[2];
  wire guard    = r3_norm_pre[1];
  wire sticky_r = r3_norm_pre[0] | r3_sticky_all;

  wire round_up = guard & (sticky_r | lsb_keep);
  wire [27:0] mant_round = round_up ? (r3_norm_pre + 28'd4) : r3_norm_pre;

  wire need_renorm = mant_round[26];
  wire [27:0] mant_final = need_renorm ? (mant_round >> 1) : mant_round;
  wire signed [9:0] exp_final_s = need_renorm ? (r3_exp_pre + 10'sd1) : r3_exp_pre;

  wire signed [10:0] exp_bias_s11 = {{1{exp_final_s[9]}}, exp_final_s} + 11'sd127;
  wire exp_overflow  = (exp_bias_s11 >= 11'sd255);
  wire exp_underflow = (exp_bias_s11 <= 11'sd0);

  wire [7:0]  exp_biased = exp_bias_s11[7:0];
  wire [23:0] mant24     = mant_final[25:2];

  wire inf_sign = r3_a_is_inf ? a[31] : b[31];
  wire both_zero = r3_a_is_zero & r3_b_is_zero;

  wire [31:0] res_normal    = { r3_sign, exp_biased, mant24[22:0] };
  wire [31:0] res_zero      = { r3_sign, 8'd0,       23'd0 };
  wire [31:0] res_inf       = { inf_sign,8'hFF,      23'd0 };
  wire [31:0] res_overflow  = { r3_sign, 8'hFF,      23'd0 };
  wire [31:0] res_underflow = { r3_sign, 8'd0,       23'd0 };
  wire [31:0] res_nan       = { 1'b0,    8'hFF,      23'h400000 };

  wire [31:0] res_comb =
      (r3_a_is_nan | r3_b_is_nan | (r3_a_is_inf & r3_b_is_inf & (a[31]^b[31]))) ? res_nan :
      (r3_a_is_inf | r3_b_is_inf) ? res_inf :
      (both_zero | (mant_final==28'd0)) ? res_zero :
      exp_overflow  ? res_overflow :
      exp_underflow ? res_underflow :
                      res_normal;

  always @(posedge clk) begin
    if (rst) d <= 32'h0;
    else     d <= res_comb;
  end
endmodule
