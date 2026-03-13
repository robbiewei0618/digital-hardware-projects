// ============================================================
// File   : FLP_mul.v
// Desc   : IEEE-754 單精度浮點乘法 (無 clk/rst；純組合邏輯)
// 特色：
//   - NaN / Inf / Zero / 次正規數(denorm) 處理
//   - 去 bias 後用有號整數做指數加減
//   - 24x24 → 48 位尾數乘法
//   - 一般化 normalize（含次正規） + ties-to-even 捨入
//   - 輸出不產生次正規（UF 直接輸出 0），OF 輸出 Inf
// 與作業 TB 介面相容：FLP_mul(.a,.b,.d)
// ============================================================

module FLP_mul (
  input  wire [31:0] a,   // 32b 單精度
  input  wire [31:0] b,   // 32b 單精度
  output wire [31:0] d    // 32b 單精度
);
  localparam BIAS = 8'd127;

  // ---------------- Unpack ----------------
  wire        sign_a    = a[31];
  wire        sign_b    = b[31];
  wire [7:0]  exp_a_raw = a[30:23];
  wire [7:0]  exp_b_raw = b[30:23];
  wire [22:0] frac_a    = a[22:0];
  wire [22:0] frac_b    = b[22:0];

  // 特殊值偵測
  wire a_is_zero = (exp_a_raw==8'd0) && (frac_a==23'd0);
  wire b_is_zero = (exp_b_raw==8'd0) && (frac_b==23'd0);
  wire a_is_inf  = (exp_a_raw==8'hFF) && (frac_a==23'd0);
  wire b_is_inf  = (exp_b_raw==8'hFF) && (frac_b==23'd0);
  wire a_is_nan  = (exp_a_raw==8'hFF) && (frac_a!=23'd0);
  wire b_is_nan  = (exp_b_raw==8'hFF) && (frac_b!=23'd0);

  // 次正規數的 hidden bit = 0；正規數 hidden bit = 1
  wire [23:0] mant_a_u = (exp_a_raw==8'd0) ? {1'b0, frac_a} : {1'b1, frac_a};
  wire [23:0] mant_b_u = (exp_b_raw==8'd0) ? {1'b0, frac_b} : {1'b1, frac_b};

  // 指數去 bias（次正規視為 1-BIAS），用有號表示
  wire signed [9:0] exp_a_s = (exp_a_raw==8'd0)
                              ? (10'sd1 - 10'sd127)
                              : ($signed({1'b0,exp_a_raw}) - $signed({1'b0,BIAS}));
  wire signed [9:0] exp_b_s = (exp_b_raw==8'd0)
                              ? (10'sd1 - 10'sd127)
                              : ($signed({1'b0,exp_b_raw}) - $signed({1'b0,BIAS}));

  // 結果號誌 = XOR
  wire sign_res = sign_a ^ sign_b;

  // ---------------- 尾數乘法（24x24 → 48） ----------------
  wire [47:0] prod = mant_a_u * mant_b_u;

  // 若乘積為 0（包含任一為 0，或 denorm×denorm 但數值小到乘積為 0）
  wire prod_is_zero = (prod == 48'd0);

  // ---------------- 一般化 normalize ----------------
  // 目標：把 MSB 對齊到 bit[46]（即 1.xxxxxx 格式）
  // 先找 48-bit 的 leading one 位置
  function [5:0] lzc48;  // 回傳「前導零個數」
    input [47:0] x;
    integer i; reg found;
    begin
      lzc48 = 6'd48; found = 1'b0;
      for (i=47; i>=0 && !found; i=i-1)
        if (x[i]) begin lzc48 = 6'd47 - i; found = 1'b1; end
    end
  endfunction

  wire [5:0] lzc = lzc48(prod);      // 0..48
  wire       any_one = (lzc != 6'd48);
  // MSB index = 47 - lzc；希望對齊到 46 → 需要左移或右移
  wire signed [6:0] msb_idx     = $signed(7'd47) - $signed({1'b0,lzc});
  wire signed [6:0] shift_to_46 = 7'sd46 - msb_idx;
  // shift_to_46 > 0 → 左移；= -1 → 右移 1（對應乘積落在 [2,4)）
  wire [47:0] mant_norm_pre =
      (!any_one)              ? 48'd0 :
      (shift_to_46 == -7'sd1) ? (prod >> 1) :
      (shift_to_46 >  7'sd0)  ? (prod << shift_to_46[5:0]) :
                                prod;

  // 指數補償：右移1 → +1；左移L → -L
  wire signed [10:0] exp_sum = exp_a_s + exp_b_s
                             + ((shift_to_46 == -7'sd1) ? 11'sd1 : 11'sd0)
                             - ((shift_to_46 > 7'sd0)  ? {{5{1'b0}}, shift_to_46[5:0]} : 11'sd0);

  // ---------------- 捨入：ties-to-even ----------------
  // 取要保留的 24 位（含隱藏位）：mant_norm_pre[46:23]
  wire [23:0] keep24   = mant_norm_pre[46:23];   // 將成為 {1.hidden, frac[22:0]}
  wire        lsb_keep = keep24[0];              // 24 位中的 LSB（用於偶數捨入）
  wire        guard    = mant_norm_pre[22];      // 第一個丟棄位
  wire        sticky_r = |mant_norm_pre[21:0];   // 其餘被丟位 OR 成 sticky
  wire        round_up = guard & (sticky_r | lsb_keep);

  // 先在 24 位空間捨入（避免多做進位帶來的位寬問題）
  wire [24:0] keep24_plus1 = {1'b0, keep24} + 25'd1;
  wire [23:0] mant_round24 = round_up ? keep24_plus1[23:0] : keep24;

  // 捨入後可能溢位（例如 1.111... + round → 10.000...）
  wire        mant_ovf = round_up & keep24_plus1[24];
  wire [23:0] mant_final24 = mant_ovf ? keep24_plus1[24:1] : mant_round24; // 右移 1
  wire signed [10:0] exp_final_s = mant_ovf ? (exp_sum + 11'sd1) : exp_sum;

  // ---------------- Pack（含 OF/UF 防呆） ----------------
  // 把 exponent 加回 bias，用 12b 有號避免比較時溢位
  wire signed [11:0] exp_bias_s = {{1{exp_final_s[10]}}, exp_final_s} + 12'sd127;
  wire exp_overflow  = (exp_bias_s >= 12'sd255);
  wire exp_underflow = (exp_bias_s <= 12'sd0);

  wire [7:0]  exp_biased = exp_bias_s[7:0];
  wire [22:0] frac_out   = mant_final24[22:0];       // 去掉隱藏位

  // 特殊值彙整
  wire nan_case =
      a_is_nan | b_is_nan |
      ((a_is_inf | b_is_inf) & (a_is_zero | b_is_zero)); // Inf*0 → NaN
  wire inf_case = (a_is_inf | b_is_inf);
  wire zero_case= (a_is_zero | b_is_zero) | prod_is_zero;

  wire [31:0] res_normal    = { sign_res, exp_biased, frac_out };
  wire [31:0] res_zero      = { sign_res, 8'd0,       23'd0 };
  wire [31:0] res_inf       = { sign_res, 8'hFF,      23'd0 };
  wire [31:0] res_overflow  = { sign_res, 8'hFF,      23'd0 };
  wire [31:0] res_underflow = { sign_res, 8'd0,       23'd0 }; // 本題簡化：不輸出 denorm
  wire [31:0] res_nan       = { 1'b0,     8'hFF,      23'h400000 }; // qNaN

  wire [31:0] res_comb =
      nan_case        ? res_nan       :
      inf_case        ? res_inf       :
      zero_case       ? res_zero      :
      exp_overflow    ? res_overflow  :
      exp_underflow   ? res_underflow :
                        res_normal;

  assign d = res_comb;
endmodule

// ------------------------------------------------------------
// 可選別名：若你在其他地方想用 FLP_Multiplier 這個名字，
// 這個小 wrapper 可以保持相同介面與行為。
// ------------------------------------------------------------
module FLP_Multiplier (
  input  wire [31:0] a,
  input  wire [31:0] b,
  output wire [31:0] d
);
  FLP_mul u_mul(.a(a), .b(b), .d(d));
endmodule
