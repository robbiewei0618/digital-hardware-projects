// ============================================================
// 檔案：FLP_Multiplier_4.v
// IEEE-754 單精度浮點乘法器 - 4 級流水線版本
// 延遲：PIPE-2 = 2 個時脈週期
// 
// Pipeline 架構：
// Stage 1 (組合): Unpack + 尾數乘法 + 正規化 → r1 暫存
// Stage 2 (組合): 四捨五入 + 再正規化 + Pack → d 輸出
// ============================================================

module FLP_Multiplier_4 (
  input  wire        clk,
  input  wire        rst,       // 同步高電位 reset
  input  wire [31:0] a,         // IEEE-754 單精度輸入 A
  input  wire [31:0] b,         // IEEE-754 單精度輸入 B
  output reg  [31:0] d          // IEEE-754 單精度輸出
);
  localparam BIAS = 8'd127;     // 指數偏移量

  // ============================================================
  // Stage 1 組合邏輯：解包（Unpack）
  // ============================================================
  
  // 提取輸入的符號位、指數、尾數
  wire        sign_a    = a[31];
  wire        sign_b    = b[31];
  wire [7:0]  exp_a_raw = a[30:23];  // 8-bit 有偏移指數
  wire [7:0]  exp_b_raw = b[30:23];
  wire [22:0] frac_a    = a[22:0];   // 23-bit 小數部分
  wire [22:0] frac_b    = b[22:0];

  // ============================================================
  // 特殊值檢測
  // ============================================================
  wire a_is_zero = (exp_a_raw == 8'd0) && (frac_a == 23'd0);     // 零
  wire b_is_zero = (exp_b_raw == 8'd0) && (frac_b == 23'd0);
  wire a_is_inf  = (exp_a_raw == 8'hFF) && (frac_a == 23'd0);    // 無窮大
  wire b_is_inf  = (exp_b_raw == 8'hFF) && (frac_b == 23'd0);
  wire a_is_nan  = (exp_a_raw == 8'hFF) && (frac_a != 23'd0);    // NaN
  wire b_is_nan  = (exp_b_raw == 8'hFF) && (frac_b != 23'd0);

  // ============================================================
  // 建立 24-bit 尾數（含隱藏位）
  // Normal: hidden bit = 1
  // Denormal: hidden bit = 0
  // ============================================================
  wire [23:0] mant_a_u = (exp_a_raw == 8'd0) ? {1'b0, frac_a} : {1'b1, frac_a};
  wire [23:0] mant_b_u = (exp_b_raw == 8'd0) ? {1'b0, frac_b} : {1'b1, frac_b};

  // ============================================================
  // 指數轉換為有號數（去偏移）
  // Normal: exp_signed = exp_raw - 127
  // Denormal: exp_signed = 1 - 127 = -126
  // ============================================================
  wire signed [9:0] exp_a_signed = (exp_a_raw == 8'd0)
                                   ? (10'sd1 - 10'sd127)
                                   : ($signed({1'b0, exp_a_raw}) - $signed(10'd127));

  wire signed [9:0] exp_b_signed = (exp_b_raw == 8'd0)
                                   ? (10'sd1 - 10'sd127)
                                   : ($signed({1'b0, exp_b_raw}) - $signed(10'd127));

  // 結果符號 = 兩操作數符號的 XOR
  wire sign_result = sign_a ^ sign_b;

  // ============================================================
  // 無號尾數乘法：24 × 24 = 48 bits
  // 乘積範圍：[0, 4)（因為 [0,2) × [0,2) = [0,4)）
  // ============================================================
  wire [47:0] product = mant_a_u * mant_b_u;

  // 檢測乘積是否為零
  wire product_is_zero = (product == 48'd0);

  // ============================================================
  // 正規化（Normalization）
  // 目標：將 MSB（最高有效位）對齊到 bit[46]，形成 1.xxxxx 格式
  // ============================================================
  
  // 計算前導零數量（Leading Zero Count）
  function [5:0] lzc48;
    input [47:0] x;
    integer i;
    reg found;
    begin
      lzc48 = 6'd48;
      found = 1'b0;
      for (i = 47; i >= 0 && !found; i = i - 1) begin
        if (x[i]) begin
          lzc48 = 6'd47 - i;
          found = 1'b1;
        end
      end
    end
  endfunction

  wire [5:0] lzc = lzc48(product);
  wire has_one = (lzc != 6'd48);  // 乘積中是否有 1

  // 計算 MSB 位置和需要的移位量
  // MSB index = 47 - lzc
  // 要對齊到 bit[46]，需要移位 = 46 - MSB_index
  wire signed [6:0] msb_index = $signed(7'd47) - $signed({1'b0, lzc});
  wire signed [6:0] shift_amount = 7'sd46 - msb_index;

  // 執行正規化移位
  // shift_amount > 0：左移（乘積 < 2）
  // shift_amount = -1：右移 1（乘積 >= 2）
  // shift_amount = 0：不移（乘積恰好在 [1,2)）
  wire [47:0] mant_norm_pre =
      (!has_one)                  ? 48'd0 :
      (shift_amount == -7'sd1)    ? (product >> 1) :
      (shift_amount >  7'sd0)     ? (product << shift_amount[5:0]) :
                                    product;

  // ============================================================
  // 指數計算
  // exp_result = exp_a + exp_b - shift_adjust
  // ============================================================
  
  // 1. 基礎指數和（兩個有號數相加）
  wire signed [10:0] exp_base = $signed({exp_a_signed[9], exp_a_signed}) 
                               + $signed({exp_b_signed[9], exp_b_signed});
  
  // 2. 正規化調整量
  // 右移 1 → 指數 +1（乘積溢出到 [2,4)）
  // 左移 N → 指數 -N（乘積太小，需要左移對齊）
  wire signed [10:0] exp_adjust = 
      (shift_amount == -7'sd1) ? 11'sd1 :
      (shift_amount >  7'sd0)  ? -$signed({5'b0, shift_amount[5:0]}) :
                                 11'sd0;
  
  // 3. 最終指數（未加偏移）
  wire signed [10:0] exp_sum = exp_base + exp_adjust;

  // ============================================================
  // Stage 1 暫存器：暫存第一級結果
  // ============================================================
  reg        r1_a_zero, r1_b_zero, r1_a_inf, r1_b_inf, r1_a_nan, r1_b_nan;
  reg        r1_sign_result;
  reg signed [10:0] r1_exp_sum;
  reg [47:0] r1_mant_norm_pre;
  reg        r1_product_is_zero;

  always @(posedge clk) begin
    if (rst) begin
      r1_a_zero <= 0;
      r1_b_zero <= 0;
      r1_a_inf  <= 0;
      r1_b_inf  <= 0;
      r1_a_nan  <= 0;
      r1_b_nan  <= 0;
      r1_sign_result <= 0;
      r1_exp_sum <= 0;
      r1_mant_norm_pre <= 0;
      r1_product_is_zero <= 0;
    end else begin
      r1_a_zero <= a_is_zero;
      r1_b_zero <= b_is_zero;
      r1_a_inf  <= a_is_inf;
      r1_b_inf  <= b_is_inf;
      r1_a_nan  <= a_is_nan;
      r1_b_nan  <= b_is_nan;
      r1_sign_result <= sign_result;
      r1_exp_sum <= exp_sum;
      r1_mant_norm_pre <= mant_norm_pre;
      r1_product_is_zero <= product_is_zero;
    end
  end

  // ============================================================
  // Stage 2 組合邏輯：四捨五入 → 再正規化 → 封裝
  // ============================================================

  // ---------- 四捨五入（Round to Nearest, Ties to Even）----------
  // 保留 bits[46:23] 共 24 bits（含隱藏位）
  // 捨棄 bits[22:0] 共 23 bits
  wire [23:0] keep24   = r1_mant_norm_pre[46:23];
  wire        lsb_keep = keep24[0];                      // 保留部分的 LSB
  wire        guard    = r1_mant_norm_pre[22];           // 保護位
  wire        sticky   = |r1_mant_norm_pre[21:0];        // 黏滯位（所有更低位的 OR）

  // Ties-to-even 規則：當 guard=1 且（sticky=1 或 LSB=1）時進位
  wire round_up = guard & (sticky | lsb_keep);

  // 執行四捨五入
  wire [24:0] keep24_plus1 = {1'b0, keep24} + 25'd1;
  wire [23:0] mant_rounded = round_up ? keep24_plus1[23:0] : keep24;

  // ---------- 再正規化（Re-normalization）----------
  // 四捨五入可能造成溢出（例如 1.111...111 + 1 = 10.000...000）
  wire mant_overflow = round_up & keep24_plus1[24];
  wire [23:0] mant_final = mant_overflow ? keep24_plus1[24:1] : mant_rounded;
  wire signed [10:0] exp_final_signed = mant_overflow ? (r1_exp_sum + 11'sd1) : r1_exp_sum;

  // ---------- 封裝（Pack）結果 ----------
  // 將指數加回偏移量（127）
  wire signed [11:0] exp_final_biased_s12 = $signed({exp_final_signed[10], exp_final_signed}) + 12'sd127;
  
  // 檢查溢出/下溢
  wire exp_overflow  = (exp_final_biased_s12 >= 12'sd255);  // → 無窮大
  wire exp_underflow = (exp_final_biased_s12 <= 12'sd0);    // → 零

  wire [7:0]  exp_final_biased = exp_final_biased_s12[7:0];
  wire [22:0] frac_final       = mant_final[22:0];  // 去除隱藏位

  // ---------- 特殊值處理 ----------
  // NaN 情況：輸入為 NaN，或 Inf × 0
  wire nan_case = r1_a_nan | r1_b_nan | 
                  ((r1_a_inf | r1_b_inf) & (r1_a_zero | r1_b_zero));
  
  // Inf 情況：任一輸入為 Inf（且不是 Inf × 0）
  wire inf_case = (r1_a_inf | r1_b_inf) & !nan_case;
  
  // 零情況：任一輸入為零，或乘積為零
  wire zero_case = (r1_a_zero | r1_b_zero) | r1_product_is_zero;

  // 各種可能的結果
  wire [31:0] result_normal    = {r1_sign_result, exp_final_biased, frac_final};
  wire [31:0] result_zero      = {r1_sign_result, 8'd0, 23'd0};
  wire [31:0] result_inf       = {r1_sign_result, 8'hFF, 23'd0};
  wire [31:0] result_overflow  = {r1_sign_result, 8'hFF, 23'd0};     // 溢出 → 無窮大
  wire [31:0] result_underflow = {r1_sign_result, 8'd0, 23'd0};      // 下溢 → 零
  wire [31:0] result_nan       = {1'b0, 8'hFF, 23'h400000};          // Quiet NaN

  // 最終結果選擇（優先級由高到低）
  wire [31:0] result_comb =
        nan_case      ? result_nan       :  // NaN 最優先
        inf_case      ? result_inf       :  // 無窮大
        zero_case     ? result_zero      :  // 零
        exp_overflow  ? result_overflow  :  // 指數溢出
        exp_underflow ? result_underflow :  // 指數下溢
                        result_normal;      // 正常結果

  // ============================================================
  // Stage 2 暫存器：輸出
  // ============================================================
  always @(posedge clk) begin
    if (rst)
      d <= 32'h00000000;
    else
      d <= result_comb;
  end

endmodule

// ============================================================
// 別名模組：相容性封裝
// ============================================================
module FLP_mul_4 (
  input  wire        clk,
  input  wire        rst,
  input  wire [31:0] a,
  input  wire [31:0] b,
  output wire [31:0] d
);
  FLP_Multiplier_4 u_mul4(
    .clk(clk),
    .rst(rst),
    .a(a),
    .b(b),
    .d(d)
  );
endmodule