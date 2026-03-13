// ============================================================
// File: FLP_adder.v
// 單精度 IEEE-754 加法器（單循環，輸出純組合；clk/rst 只為介面相容而保留）
// 內部尾數用 Q3.25（28bit）：[27:25]整數位、[24:0]小數位
// 特色：有號 exponent / 交換對齊 / 全域 sticky（含對齊、normalize右移）
//       round-to-nearest, ties-to-even / OF→Inf, UF→0 / Inf 取自該運算元的符號
// ============================================================
module FLP_adder (
  input  wire        clk,          // 非 pipeline 版不使用
  input  wire        rst,          // 非 pipeline 版不使用
  input  wire [31:0] a,            // 32b 單精度浮點
  input  wire [31:0] b,            // 32b 單精度浮點
  output wire [31:0] d             // 32b 單精度浮點
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
  wire a_is_zero = (exp_a_raw == 8'd0) && (frac_a == 23'd0);
  wire b_is_zero = (exp_b_raw == 8'd0) && (frac_b == 23'd0);
  wire a_is_inf  = (exp_a_raw == 8'hFF) && (frac_a == 23'd0);
  wire b_is_inf  = (exp_b_raw == 8'hFF) && (frac_b == 23'd0);
  wire a_is_nan  = (exp_a_raw == 8'hFF) && (frac_a != 23'd0);
  wire b_is_nan  = (exp_b_raw == 8'hFF) && (frac_b != 23'd0);

  // -------- exponent 去 bias（次正規數視為 1 - BIAS），用「有號」表示 --------
  wire signed [8:0] exp_a_s = (exp_a_raw==8'd0)
                              ? 9'sd1 - $signed({1'b0,BIAS})
                              : $signed({1'b0,exp_a_raw}) - $signed({1'b0,BIAS});
  wire signed [8:0] exp_b_s = (exp_b_raw==8'd0)
                              ? 9'sd1 - $signed({1'b0,BIAS})
                              : $signed({1'b0,exp_b_raw}) - $signed({1'b0,BIAS});

  // -------- 建立 Q3.25 mantissa：{00, hidden(正規=1/次正規=0), frac, 00} --------
  wire [27:0] mant_a_u = {2'b00, (exp_a_raw==8'd0)? 1'b0 : 1'b1, frac_a, 2'b00};
  wire [27:0] mant_b_u = {2'b00, (exp_b_raw==8'd0)? 1'b0 : 1'b1, frac_b, 2'b00};
  // 加上輸入號誌轉成「有號數」
  wire signed [27:0] mant_a_s = sign_a ? -$signed(mant_a_u) : $signed(mant_a_u);
  wire signed [27:0] mant_b_s = sign_b ? -$signed(mant_b_u) : $signed(mant_b_u);

  // ---------------- 交換：確保 exp_big ≥ exp_small ----------------
  wire swap = (exp_a_s < exp_b_s);
  wire signed [8:0]  exp_big_s   = swap ? exp_b_s : exp_a_s;
  wire signed [8:0]  exp_small_s = swap ? exp_a_s : exp_b_s;
  wire signed [27:0] mant_big    = swap ? mant_b_s : mant_a_s;
  wire signed [27:0] mant_small  = swap ? mant_a_s : mant_b_s;

  // ---------------- 對齊（小數右移；含 sticky from alignment） ----------------
  wire signed [8:0]  de_s   = exp_big_s - exp_small_s;   // ≥0
  wire        [8:0]  de     = $unsigned(de_s);
  wire               de_ge_26 = (de >= 9'd26);

  // 以 magnitude 評估對齊丟掉的位元，以納入 sticky
  wire [27:0] mant_small_mag = mant_small[27] ? (~mant_small + 28'd1) : mant_small;

  // 動態低位遮罩：取出將被丟掉的低 de[4:0] 位
  function [27:0] low_mask28;
    input [4:0] n; integer k;
    begin
      low_mask28 = 28'd0;
      for (k=0; k<28; k=k+1)
        if (k < n) low_mask28[k] = 1'b1;
    end
  endfunction

  // 右移對齊（注意：不能對負數做算術右移，會把符號位往下帶）
  wire [27:0] mant_small_mag_shift = de_ge_26 ? 28'd0 : (mant_small_mag >> de[4:0]);
  wire signed [27:0] mant_small_aligned =
      mant_small[27] ? -$signed(mant_small_mag_shift) : $signed(mant_small_mag_shift);

  // 對齊帶來的 sticky：Δexp 很大→整段被丟；一般→低位被丟
  wire sticky_from_align =
      de_ge_26                 ? (|mant_small_mag) :
      (de[4:0]==5'd0)          ? 1'b0 :
      |(mant_small_mag & low_mask28(de[4:0]));

  // ---------------- 有號尾數相加 → 轉正負號/絕對值 ----------------
  wire signed [27:0] mant_sum_s  = mant_big + mant_small_aligned;
  wire               sign_res    = mant_sum_s[27];
  wire [27:0]        mant_sum_abs= sign_res ? (~mant_sum_s + 28'd1) : mant_sum_s;

  // ---------------- Leading Zero Count（做 normalize 用） ----------------
  function [5:0] lzc28;
    input [27:0] x;
    integer i; reg found;
    begin
      lzc28 = 6'd28; found = 1'b0;
      for (i=27; i>=0 && !found; i=i-1)
        if (x[i]) begin lzc28 = 6'd27 - i; found = 1'b1; end
    end
  endfunction

  // 期望 MSB 對齊到 bit[25] → shift_amount = lzc - 2
  wire [5:0]           lzc = lzc28(mant_sum_abs);
  wire signed [6:0] shift = $signed({1'b0,lzc}) - 7'sd2;

  // normalize：-1 → 右移 1（sum≥2.0）；>0 → 左移；=0 → 不動
  wire [27:0] mant_norm_pre =
      (shift == -7'sd1) ? (mant_sum_abs >> 1) :
      (shift >  7'sd0)  ? (mant_sum_abs << shift[5:0]) :
                          mant_sum_abs;

  // exponent 補償（做有號加減；先把 9b 符號延伸到 10b）
  wire signed [9:0] exp_norm_pre = {{1{exp_big_s[8]}}, exp_big_s} - shift;

  // normalize 若為「右移 1」，丟掉的原始 LSB 也要併入 sticky（避免差 1 ULP）
  wire sticky_from_norm = (shift == -7'sd1) ? mant_sum_abs[0] : 1'b0;

  // ---------------- Round-to-nearest ties-to-even ----------------
  // 最終只保留 [25:2] 共 24bit（含隱藏位）；丟掉 [1:0] 是 G/S
  wire lsb_keep = mant_norm_pre[2];                          // 保留區最低位
  wire guard    = mant_norm_pre[1];                          // 第一個丟棄位
  wire sticky_r = mant_norm_pre[0] | sticky_from_align | sticky_from_norm; // 全域 sticky

  wire round_up = guard & (sticky_r | lsb_keep);             // ties-to-even 規則
  wire [27:0] mant_rounded = round_up ? (mant_norm_pre + 28'd4) : mant_norm_pre;

  // 捨入後可能剛好到 2.0 → 需再右移 1 & exponent +1
  wire need_renorm = mant_rounded[26];                       // Q3.25 的 2.0 指標位
  wire [27:0] mant_final = need_renorm ? (mant_rounded >> 1) : mant_rounded;
  wire signed [9:0] exp_final_s = need_renorm ? (exp_norm_pre + 10'sd1) : exp_norm_pre;

  // ---------------- Pack（含 OF/UF 防呆） ----------------
  // 先把 exponent 加回 bias，用 11b 有號避免比較時溢位
  wire signed [10:0] exp_bias_s11 = {{1{exp_final_s[9]}}, exp_final_s} + 11'sd127;
  wire exp_overflow  = (exp_bias_s11 >= 11'sd255);           // ≥255 → Inf
  wire exp_underflow = (exp_bias_s11 <= 11'sd0);             // ≤0   → 0（簡化：不產生 denorm）

  wire [7:0]  exp_biased = exp_bias_s11[7:0];
  wire [23:0] mant24     = mant_final[25:2];

  // 單邊為 Inf → 取該運算元的符號（不是 XOR）
  wire inf_sign = a_is_inf ? sign_a : sign_b;

  wire [31:0] res_normal    = { sign_res, exp_biased, mant24[22:0] };
  wire [31:0] res_zero      = { sign_res, 8'd0,       23'd0 };
  wire [31:0] res_inf       = { inf_sign, 8'hFF,      23'd0 };
  wire [31:0] res_overflow  = { sign_res, 8'hFF,      23'd0 };
  wire [31:0] res_underflow = { sign_res, 8'd0,       23'd0 };
  wire [31:0] res_nan       = { 1'b0,     8'hFF,      23'h400000 }; // qNaN

  wire both_zero = a_is_zero & b_is_zero;

  wire [31:0] res_comb =
      (a_is_nan | b_is_nan | (a_is_inf & b_is_inf & (sign_a ^ sign_b))) ? res_nan :
      (a_is_inf | b_is_inf)        ? res_inf :
      (both_zero | (mant_sum_abs==28'd0)) ? res_zero :
      exp_overflow                 ? res_overflow :
      exp_underflow                ? res_underflow :
                                     res_normal;

  // 非 pipeline 版：輸出為純組合
  assign d = res_comb;

endmodule
