// File: FLP_adder.v
// IEEE-754 single-precision adder (single-cycle combinational, pure combinational output)
// Internal datapath uses signed Q3.25 per HW slides.

module FLP_adder (
  input  wire [31:0] a,            // IEEE754 single
  input  wire [31:0] b,            // IEEE754 single
  output wire [31:0] d             // IEEE754 single
);
  localparam BIAS = 8'd127;

  // ============================================================
  // Unpack input fields
  // ============================================================
  wire        sign_a    = a[31];
  wire        sign_b    = b[31];
  wire [7:0]  exp_a_raw = a[30:23];
  wire [7:0]  exp_b_raw = b[30:23];
  wire [22:0] frac_a    = a[22:0];
  wire [22:0] frac_b    = b[22:0];

  // ============================================================
  // Special value detection
  // ============================================================
  wire a_is_zero = (exp_a_raw == 8'd0) && (frac_a == 23'd0);
  wire b_is_zero = (exp_b_raw == 8'd0) && (frac_b == 23'd0);

  wire a_is_inf  = (exp_a_raw == 8'hFF) && (frac_a == 23'd0);
  wire b_is_inf  = (exp_b_raw == 8'hFF) && (frac_b == 23'd0);

  wire a_is_nan  = (exp_a_raw == 8'hFF) && (frac_a != 23'd0);
  wire b_is_nan  = (exp_b_raw == 8'hFF) && (frac_b != 23'd0);

  // ============================================================
  // Convert exponent to signed (unbiased)
  // Denorm: exponent = 1 - BIAS, hidden bit = 0
  // ============================================================
  wire signed [8:0] exp_a_signed = (exp_a_raw==8'd0)
                                   ? 9'sd1 - $signed({1'b0,BIAS})
                                   : $signed({1'b0,exp_a_raw}) - $signed({1'b0,BIAS});

  wire signed [8:0] exp_b_signed = (exp_b_raw==8'd0)
                                   ? 9'sd1 - $signed({1'b0,BIAS})
                                   : $signed({1'b0,exp_b_raw}) - $signed({1'b0,BIAS});

  // ============================================================
  // Build mantissa in Q3.25 format
  // ============================================================
  wire [27:0] mant_a_unsigned = {2'b00, (exp_a_raw==8'd0)? 1'b0 : 1'b1, frac_a, 2'b00};
  wire [27:0] mant_b_unsigned = {2'b00, (exp_b_raw==8'd0)? 1'b0 : 1'b1, frac_b, 2'b00};

  wire signed [27:0] mant_a_signed = sign_a ? -$signed(mant_a_unsigned) : $signed(mant_a_unsigned);
  wire signed [27:0] mant_b_signed = sign_b ? -$signed(mant_b_unsigned) : $signed(mant_b_unsigned);

  // ============================================================
  // Ensure exp_big >= exp_small by swapping  (全部用「有號」域)
  // ============================================================
  wire swap_needed = (exp_a_signed < exp_b_signed);

  wire signed [8:0]  exp_big_s   = swap_needed ? exp_b_signed : exp_a_signed;
  wire signed [8:0]  exp_small_s = swap_needed ? exp_a_signed : exp_b_signed;

  wire signed [27:0] mant_big    = swap_needed ? mant_b_signed : mant_a_signed;
  wire signed [27:0] mant_small  = swap_needed ? mant_a_signed : mant_b_signed;

  // ============================================================
  // Alignment
  // ============================================================
  // Δexp 取「非負整數」的大小（有號減法，再轉無號）
  wire signed [8:0]  exp_diff_s  = exp_big_s - exp_small_s; // 應該 >= 0
  wire        [8:0]  exp_diff    = $unsigned(exp_diff_s);

  wire exp_diff_too_large = (exp_diff >= 9'd26);

  wire signed [27:0] mant_small_aligned =
      exp_diff_too_large ? 28'sd0 : (mant_small >>> exp_diff[4:0]);

  // ============================================================
  // Signed mantissa addition
  // ============================================================
  wire signed [27:0] mant_sum_signed = mant_big + mant_small_aligned;

  // ============================================================
  // Sign-magnitude conversion
  // ============================================================
  wire        result_sign  = mant_sum_signed[27];
  wire [27:0] mant_sum_abs = result_sign ? (~mant_sum_signed + 28'd1) : mant_sum_signed;

  // ============================================================
  // Normalization
  // ============================================================
  function [5:0] leading_zeros_28;
    input [27:0] x;
    integer i;
    reg found;
    begin
      leading_zeros_28 = 6'd28;
      found = 1'b0;
      for (i=27; i>=0 && !found; i=i-1) begin
        if (x[i]) begin
          leading_zeros_28 = 6'd27 - i;
          found = 1'b1; // break
        end
      end
    end
  endfunction

  wire [5:0] lzc = leading_zeros_28(mant_sum_abs);
  // shift_amount = lzc - 2：希望 MSB 對齊到 bit[25] (Q3.25 的 1.xxx)
  wire signed [6:0] shift_amount = $signed({1'b0,lzc}) - 7'sd2;

  wire [27:0] mant_norm_pre =
      (shift_amount == -7'sd1) ? (mant_sum_abs >> 1) :
      (shift_amount >  7'sd0)  ? (mant_sum_abs << shift_amount[5:0]) :
                                 mant_sum_abs;

  // !! 這裡要做「符號延伸」的有號加減，不能 {1'b0,exp_big_s}
  wire signed [9:0] exp_norm_pre = {{1{exp_big_s[8]}}, exp_big_s} - shift_amount;

  // ============================================================
  // Rounding (round-to-nearest, ties-to-even using guard/sticky/lsb_keep)
  // ============================================================
  // 保留 [25:2] → 兩個丟棄位是 [1:0]
  wire lsb_keep = mant_norm_pre[2];  // 保留區最低位
  wire guard    = mant_norm_pre[1];  // 第一個丟棄位
  wire sticky   = mant_norm_pre[0];  // 其它丟棄位 OR（此設計只丟兩位 → sticky=bit0）

  wire round_up = guard & (sticky | lsb_keep);          // ties-to-even
  wire [27:0] mant_rounded = round_up ? (mant_norm_pre + 28'd4) : mant_norm_pre;

  // ============================================================
  // Re-normalization (if rounding caused exactly 2.0)
  // ============================================================
  wire need_renorm = mant_rounded[26];                  // ≥ 2.0 in Q3.25
  wire [27:0] mant_final = need_renorm ? (mant_rounded >> 1) : mant_rounded;
  wire signed [9:0] exp_final_signed = need_renorm ? (exp_norm_pre + 10'sd1) : exp_norm_pre;

  // ============================================================
  // Pack result (with overflow/underflow guards)
  // ============================================================
  // 在「有號」域做偏移，再用 11-bit 保證不溢位後比較上下限
  wire signed [10:0] exp_final_biased_s11 = {{1{exp_final_signed[9]}}, exp_final_signed} + 11'sd127;
  wire        exp_overflow  = (exp_final_biased_s11 >= 11'sd255); // → Inf
  wire        exp_underflow = (exp_final_biased_s11 <= 11'sd0);   // → Zero (簡化：不產生 denorm)

  wire [7:0]  exp_final_biased = exp_final_biased_s11[7:0];
  wire [23:0] mantissa_24      = mant_final[25:2];

  // Infinity sign must come from the operand that is Inf (not XOR)
  wire        inf_sign = a_is_inf ? sign_a : sign_b;

  wire [31:0] result_normal    = { result_sign, exp_final_biased, mantissa_24[22:0] };
  wire [31:0] result_zero      = { result_sign, 8'd0,            23'd0 };
  wire [31:0] result_inf       = { inf_sign,    8'hFF,           23'd0 };
  wire [31:0] result_overflow  = { result_sign, 8'hFF,           23'd0 }; // overflow -> +/-Inf
  wire [31:0] result_underflow = { result_sign, 8'd0,            23'd0 }; // underflow -> +/-0
  wire [31:0] result_nan       = { 1'b0,        8'hFF,           23'h400000 }; // quiet NaN

  wire both_inputs_zero = a_is_zero & b_is_zero;

  wire [31:0] result_comb =
        // NaN first (including +Inf + -Inf)
        (a_is_nan | b_is_nan | (a_is_inf & b_is_inf & (sign_a ^ sign_b))) ? result_nan :
        // If either operand is Inf (single-sided), return that Inf with its sign
        (a_is_inf | b_is_inf)        ? result_inf :
        // Exact zero (both zero or cancellation)
        (both_inputs_zero | (mant_sum_abs==28'd0)) ? result_zero :
        // Exponent guards
        exp_overflow                 ? result_overflow :
        exp_underflow                ? result_underflow :
        // Normal case
        result_normal;

  // 純組合輸出（非 pipeline 版）
  assign d = result_comb;

endmodule
