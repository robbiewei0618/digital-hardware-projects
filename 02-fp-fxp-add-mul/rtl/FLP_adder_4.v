// ============================================================
// File: FLP_adder_4.v
// 4 級 pipeline（依 TA TB 定義延遲 = PIPE-2 = 2 cycle）
// stage_r1: Unpack/去bias/建Q3.25 → 交換/對齊(+alignment sticky)
// stage_r2: 加法→絕對值→normalize(+norm右移sticky)→round(tte)→renorm→pack(+OF/UF/特殊值)
// ============================================================
module FLP_adder_4 (
  input  wire        clk,
  input  wire        rst,
  input  wire [31:0] a,
  input  wire [31:0] b,
  output reg  [31:0] d
);
  localparam BIAS = 8'd127;

  // ============== Stage 0: 輸入暫存（新增！）==============
  reg [31:0] r0_a, r0_b;
  always @(posedge clk) begin
    if (rst) begin
      r0_a <= 32'h0;
      r0_b <= 32'h0;
    end else begin
      r0_a <= a;
      r0_b <= b;
    end
  end

  // ============== Stage 1: Unpack + Align ==============
  // 使用 r0_a, r0_b 而不是 a, b
  wire sign_a = r0_a[31];
  wire sign_b = r0_b[31];
  wire [7:0] exp_a_raw = r0_a[30:23];
  wire [7:0] exp_b_raw = r0_b[30:23];
  wire [22:0] frac_a = r0_a[22:0];
  wire [22:0] frac_b = r0_b[22:0];

  wire a_is_zero = (exp_a_raw==8'd0) && (frac_a==23'd0);
  wire b_is_zero = (exp_b_raw==8'd0) && (frac_b==23'd0);
  wire a_is_inf  = (exp_a_raw==8'hFF) && (frac_a==23'd0);
  wire b_is_inf  = (exp_b_raw==8'hFF) && (frac_b==23'd0);
  wire a_is_nan  = (exp_a_raw==8'hFF) && (frac_a!=23'd0);
  wire b_is_nan  = (exp_b_raw==8'hFF) && (frac_b!=23'd0);

  wire signed [8:0] exp_a_s = (exp_a_raw==8'd0) ? 9'sd1 - $signed({1'b0,BIAS})
                                                : $signed({1'b0,exp_a_raw}) - $signed({1'b0,BIAS});
  wire signed [8:0] exp_b_s = (exp_b_raw==8'd0) ? 9'sd1 - $signed({1'b0,BIAS})
                                                : $signed({1'b0,exp_b_raw}) - $signed({1'b0,BIAS});

  // {00, hidden, frac, G, R, S}: three extra bits so that an effective
  // subtraction followed by a 1-bit left shift still rounds correctly
  wire [28:0] mant_a_u = {2'b00, (exp_a_raw==8'd0)?1'b0:1'b1, frac_a, 3'b000};
  wire [28:0] mant_b_u = {2'b00, (exp_b_raw==8'd0)?1'b0:1'b1, frac_b, 3'b000};
  wire signed [28:0] mant_a_s = sign_a ? -$signed(mant_a_u) : $signed(mant_a_u);
  wire signed [28:0] mant_b_s = sign_b ? -$signed(mant_b_u) : $signed(mant_b_u);

  // ----------------- 組合：交換，確保 exp_big >= exp_small -----------------
  wire swap = (exp_a_s < exp_b_s);
  wire signed [8:0]  exp_big_s   = swap ? exp_b_s : exp_a_s;
  wire signed [8:0]  exp_small_s = swap ? exp_a_s : exp_b_s;
  wire signed [28:0] mant_big_s  = swap ? mant_b_s : mant_a_s;
  wire signed [28:0] mant_sml_s  = swap ? mant_a_s : mant_b_s;

  // 工具：低 n 位遮罩（抓對齊被丟掉的位元以產生 sticky）
  function [28:0] low_mask29;
    input [4:0] n; integer k;
    begin
      low_mask29 = 29'd0;
      for (k=0;k<29;k=k+1) if (k<n) low_mask29[k]=1'b1;
    end
  endfunction

  // ----------------- 組合：對齊（含 alignment sticky） -----------------
  wire signed [8:0] de_s = exp_big_s - exp_small_s;  // >=0
  wire        [8:0] de   = $unsigned(de_s);
  wire de_ge_32 = (de >= 9'd32);

  wire [28:0] mant_sml_mag = mant_sml_s[28] ? (~mant_sml_s + 29'd1) : mant_sml_s;
  wire sticky_align = de_ge_32               ? (|mant_sml_mag) :
                      (de[4:0]==5'd0)        ? 1'b0 :
                      |(mant_sml_mag & low_mask29(de[4:0]));
  // shifted-out bits are jammed into the LSB *before* the add/subtract
  wire [28:0] mant_sml_mag_shift = (de_ge_32 ? 29'd0 : (mant_sml_mag >> de[4:0]))
                                 | {28'd0, sticky_align};
  wire signed [28:0] mant_sml_al  = mant_sml_s[28] ? -$signed(mant_sml_mag_shift)
                                                   :  $signed(mant_sml_mag_shift);

  // ----------------- r1 暫存（第一拍） -----------------
  reg        r1_a_zero, r1_b_zero, r1_a_inf, r1_b_inf, r1_a_nan, r1_b_nan;
  reg        r1_sign_a, r1_sign_b;   // input signs travel with the Inf/NaN flags
  reg signed [8:0]  r1_exp_big_s;
  reg signed [28:0] r1_mant_big_s, r1_mant_sml_al;
  always @(posedge clk) begin
    if (rst) begin
      r1_a_zero<=0; r1_b_zero<=0; r1_a_inf<=0; r1_b_inf<=0; r1_a_nan<=0; r1_b_nan<=0;
      r1_sign_a<=0; r1_sign_b<=0;
      r1_exp_big_s<=0; r1_mant_big_s<=0; r1_mant_sml_al<=0;
    end else begin
      r1_a_zero<=a_is_zero; r1_b_zero<=b_is_zero; r1_a_inf<=a_is_inf; r1_b_inf<=b_is_inf; r1_a_nan<=a_is_nan; r1_b_nan<=b_is_nan;
      r1_sign_a<=sign_a; r1_sign_b<=sign_b;
      r1_exp_big_s<=exp_big_s; r1_mant_big_s<=mant_big_s; r1_mant_sml_al<=mant_sml_al;
    end
  end

  // ----------------- 組合：第二拍完整收尾並打到 d -----------------
  // 相加 → 絕對值
  wire signed [28:0] s2_sum_s = r1_mant_big_s + r1_mant_sml_al;
  wire               s2_sign  = s2_sum_s[28];
  wire [28:0]        s2_abs   = s2_sign ? (~s2_sum_s + 29'd1) : s2_sum_s;

  // LZC
  function [5:0] lzc29;
    input [28:0] x; integer i; reg found;
    begin
      lzc29=6'd29; found=1'b0;
      for (i=28;i>=0 && !found;i=i-1) if (x[i]) begin lzc29=6'd28-i; found=1'b1; end
    end
  endfunction

  wire [5:0]        lzc   = lzc29(s2_abs);
  wire signed [6:0] shift = $signed({1'b0,lzc}) - 7'sd2;

  // normalize（-1→右移1；>0→左移；0→不動）
  wire [28:0] mant_norm_pre =
      (shift == -7'sd1) ? (s2_abs >> 1) :
      (shift >  7'sd0)  ? (s2_abs << shift[5:0]) :
                          s2_abs;

  wire signed [9:0] exp_norm_pre = $signed({r1_exp_big_s[8], r1_exp_big_s}) - shift;  // both operands signed

  // normalize 右移造成的 sticky
  wire sticky_norm = (shift == -7'sd1) ? s2_abs[0] : 1'b0;

  // Round-to-nearest ties-to-even
  wire lsb_keep = mant_norm_pre[3];
  wire guard    = mant_norm_pre[2];
  wire sticky_r = (|mant_norm_pre[1:0]) | sticky_norm;   // alignment sticky is jammed in bit 0

  wire round_up = guard & (sticky_r | lsb_keep);
  wire [28:0] mant_round = round_up ? (mant_norm_pre + 29'd8) : mant_norm_pre;

  // 可能 2.0 → 再右移 1；指數 +1
  wire need_renorm = mant_round[27];
  wire [28:0] mant_final = need_renorm ? (mant_round >> 1) : mant_round;
  wire signed [9:0] exp_final_s = need_renorm ? (exp_norm_pre + 10'sd1) : exp_norm_pre;

  // Pack（含 OF/UF、防呆及特殊值）
  wire signed [10:0] exp_bias_s11 = {{1{exp_final_s[9]}}, exp_final_s} + 11'sd127;
  wire exp_overflow  = (exp_bias_s11 >= 11'sd255);
  wire exp_underflow = (exp_bias_s11 <= 11'sd0);

  wire [7:0]  exp_biased = exp_bias_s11[7:0];
  wire [23:0] mant24     = mant_final[26:3];

  wire inf_sign = r1_a_inf ? r1_sign_a : r1_sign_b;
  wire both_zero = r1_a_zero & r1_b_zero;

  wire [31:0] res_normal    = { s2_sign, exp_biased, mant24[22:0] };
  wire [31:0] res_zero      = { s2_sign, 8'd0, 23'd0 };
  wire [31:0] res_inf       = { inf_sign, 8'hFF, 23'd0 };
  wire [31:0] res_overflow  = { s2_sign, 8'hFF, 23'd0 };
  wire [31:0] res_underflow = { s2_sign, 8'd0, 23'd0 };
  wire [31:0] res_nan       = { 1'b0, 8'hFF, 23'h400000 };

  wire [31:0] res_comb =
      (r1_a_nan | r1_b_nan | (r1_a_inf & r1_b_inf & (r1_sign_a ^ r1_sign_b))) ? res_nan :
      (r1_a_inf | r1_b_inf)  ? res_inf :
      (both_zero | (s2_abs==29'd0)) ? res_zero :
      exp_overflow  ? res_overflow :
      exp_underflow ? res_underflow :
                      res_normal;

  // 第二拍寄存到輸出（延遲=2）
  always @(posedge clk) begin
    if (rst) d <= 32'h0;
    else     d <= res_comb;
  end
endmodule
