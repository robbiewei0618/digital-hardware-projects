// File: FLP_adder.v
// IEEE-754 single-precision adder (single-cycle combinational, registered out)
// Internal datapath uses signed Q3.25 per HW slides.

module FLP_adder (
  input  wire        clk,
  input  wire        rst,          // synchronous, active-high
  input  wire [31:0] a,            // IEEE754 single
  input  wire [31:0] b,            // IEEE754 single
  output reg  [31:0] d             // IEEE754 single
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
                            ? $signed(9'sd1 - $signed({1'b0,BIAS}))
                            : $signed({1'b0,exp_a_raw}) - $signed({1'b0,BIAS});

  wire signed [8:0] exp_b_signed = (exp_b_raw==8'd0) 
                            ? $signed(9'sd1 - $signed({1'b0,BIAS}))
                            : $signed({1'b0,exp_b_raw}) - $signed({1'b0,BIAS});

  // ============================================================
  // Build mantissa in Q3.25 format
  // ============================================================
  wire [27:0] mant_a_unsigned = {2'b00, (exp_a_raw==8'd0)? 1'b0 : 1'b1, frac_a, 2'b00};
  wire [27:0] mant_b_unsigned = {2'b00, (exp_b_raw==8'd0)? 1'b0 : 1'b1, frac_b, 2'b00};

  wire signed [27:0] mant_a_signed = sign_a ? -$signed(mant_a_unsigned) : $signed(mant_a_unsigned);
  wire signed [27:0] mant_b_signed = sign_b ? -$signed(mant_b_unsigned) : $signed(mant_b_unsigned);

  // ============================================================
  // Ensure exp_big >= exp_small by swapping
  // ============================================================
  wire swap_needed = (exp_a_signed < exp_b_signed);

  wire signed [27:0] mant_big   = swap_needed ? mant_b_signed : mant_a_signed;
  wire signed [27:0] mant_small = swap_needed ? mant_a_signed : mant_b_signed;

  wire signed [8:0] exp_big   = swap_needed ? exp_b_signed : exp_a_signed;
  wire signed [8:0] exp_small = swap_needed ? exp_a_signed : exp_b_signed;

  // ============================================================
  // Alignment
  // ============================================================
  wire [8:0] exp_diff = exp_big - exp_small;
  wire exp_diff_too_large = (exp_diff >= 9'd26);

  wire signed [27:0] mant_small_aligned = exp_diff_too_large ? 28'sd0
                                                             : (mant_small >>> exp_diff[4:0]);

  // ============================================================
  // Signed mantissa addition
  // ============================================================
  wire signed [27:0] mant_sum_signed = mant_big + mant_small_aligned;

  // ============================================================
  // Sign-magnitude conversion
  // ============================================================
  wire        result_sign  = mant_sum_signed[27];
  wire [27:0] mant_sum_abs = result_sign ? (~mant_sum_signed + 1) : mant_sum_signed;

  // ============================================================
  // Check if result is truly zero
  // ============================================================
  wire result_is_zero = (mant_sum_abs == 28'd0);

  // ============================================================
  // Normalization
  // ============================================================
  function [5:0] leading_zeros_28;
    input [27:0] x;
    integer i;
    reg found;
    begin
      leading_zeros_28 = 6'd28;
      found = 0;
      for (i=27; i>=0 && !found; i=i-1) begin
        if (x[i]) begin
          leading_zeros_28 = 6'd27 - i;
          found = 1;
        end
      end
    end
  endfunction

  wire [5:0] lzc = leading_zeros_28(mant_sum_abs);
  wire signed [6:0] shift_amount = $signed({1'b0,lzc}) - 7'sd2;

  wire [27:0] mant_norm_pre =
      (shift_amount == -7'sd1) ? (mant_sum_abs >> 1) :
      (shift_amount > 0)       ? (mant_sum_abs << shift_amount[5:0]) :
                                 mant_sum_abs;

  wire signed [9:0] exp_norm_pre = $signed({1'b0,exp_big}) - shift_amount;

  // ============================================================
  // Rounding (round-to-nearest, ties-to-even)
  // ============================================================
  wire lsb_keep = mant_norm_pre[2];
  wire guard    = mant_norm_pre[1];
  wire sticky   = mant_norm_pre[0];

  wire round_up = guard & (sticky | lsb_keep);
  wire [27:0] mant_rounded = round_up ? (mant_norm_pre + 28'd4) : mant_norm_pre;

  // ============================================================
  // Re-normalization (if rounding caused overflow)
  // ============================================================
  wire need_renorm = mant_rounded[26];
  wire [27:0] mant_final = need_renorm ? (mant_rounded >> 1) : mant_rounded;
  wire signed [9:0] exp_final_signed = need_renorm ? (exp_norm_pre + 10'sd1) : exp_norm_pre;

  // ============================================================
  // Pack result (with overflow/underflow guards)
  // ============================================================
  wire signed [9:0] exp_final_biased_s10 = $signed(exp_final_signed) + $signed({2'b00,BIAS});
  wire        exp_overflow  = (exp_final_biased_s10 >= 10'sd255);
  wire        exp_underflow = (exp_final_biased_s10 <= 10'sd0);

  wire [7:0]  exp_final_biased = exp_final_biased_s10[7:0];
  wire [23:0] mantissa_24      = mant_final[25:2];

  // Result values
  wire [31:0] result_normal    = {result_sign, exp_final_biased, mantissa_24[22:0]};
  wire [31:0] result_zero      = {result_sign, 8'd0, 23'd0};
  wire [31:0] result_pos_zero  = 32'h00000000;
  wire [31:0] result_overflow  = {result_sign, 8'hFF, 23'd0};
  wire [31:0] result_underflow = {result_sign, 8'd0, 23'd0};
  wire [31:0] result_nan       = {1'b0, 8'hFF, 23'h400000};
  
  // Infinity signs
  wire inf_sign_a = sign_a;
  wire inf_sign_b = sign_b;
  wire [31:0] result_inf_a = {inf_sign_a, 8'hFF, 23'd0};
  wire [31:0] result_inf_b = {inf_sign_b, 8'hFF, 23'd0};

  // ============================================================
  // Final result selection with proper priority
  // ============================================================
  wire [31:0] result_comb =
        // NaN cases first
        (a_is_nan | b_is_nan) ? result_nan :
        // Inf + (-Inf) = NaN
        (a_is_inf & b_is_inf & (sign_a ^ sign_b)) ? result_nan :
        // If A is Inf, return Inf with A's sign
        (a_is_inf) ? result_inf_a :
        // If B is Inf, return Inf with B's sign
        (b_is_inf) ? result_inf_b :
        // If A is zero, return B
        (a_is_zero & ~b_is_zero) ? b :
        // If B is zero, return A
        (b_is_zero & ~a_is_zero) ? a :
        // If both are zero, return +0 (or handle sign properly)
        (a_is_zero & b_is_zero) ? result_pos_zero :
        // If addition results in exact zero (cancellation)
        result_is_zero ? result_pos_zero :
        // Overflow to infinity
        exp_overflow ? result_overflow :
        // Underflow to zero
        exp_underflow ? result_underflow :
        // Normal result
        result_normal;

  // ============================================================
  // Register output
  // ============================================================
  always @(posedge clk) begin
    if (rst) d <= 32'h00000000;
    else     d <= result_comb;
  end

endmodule