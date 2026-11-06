// =============================================================================
// sva_bind.sv - white-box assertions bound into the project 02 RTL
// =============================================================================

// FLP_mul (inside FLP_Multiplier): exponent datapath and normalisation.
module flp_mul_internal_sva (
  input logic              clk,
  input logic signed [9:0] exp_a_s, exp_b_s,
  input logic signed [6:0] shift_to_46,
  input logic signed [10:0] exp_sum,
  input logic              any_one,
  input logic [47:0]       mant_norm_pre
);
  // exponent of the normalised product, recomputed independently in 32 bits
  int unsigned dummy;
  wire signed [31:0] exp_model = 32'(exp_a_s) + 32'(exp_b_s)
                               + (shift_to_46 == -7'sd1 ? 1 : 0)
                               - (shift_to_46 > 0 ? 32'(shift_to_46) : 0);

  a_exp_sum: assert property (@(posedge clk) any_one |-> 32'(exp_sum) == exp_model)
    else begin $error("[SVA] FLP_mul exp_sum=%0d, expected %0d (ea=%0d eb=%0d shift=%0d)",
                exp_sum, exp_model, exp_a_s, exp_b_s, shift_to_46); fp_dv_pkg::sva_errors++; end

  // after normalisation the leading one sits at bit 46
  a_norm: assert property (@(posedge clk) any_one |-> mant_norm_pre[47:46] == 2'b01)
    else begin $error("[SVA] FLP_mul not normalised: %h", mant_norm_pre); fp_dv_pkg::sva_errors++; end
endmodule

bind FLP_mul flp_mul_internal_sva u_int_sva (
  .clk(tb_top.clk), .exp_a_s, .exp_b_s, .shift_to_46, .exp_sum, .any_one, .mant_norm_pre);

// FLP_adder: the normalised sum has its leading one at bit 25 (Q3.25)
module flp_add_internal_sva (
  input logic        clk,
  input logic [28:0] mant_sum_abs,
  input logic [28:0] mant_norm_pre
);
  a_norm: assert property (@(posedge clk) mant_sum_abs != 0 |-> mant_norm_pre[28:26] == 3'b001)
    else begin $error("[SVA] FLP_adder not normalised: sum %h -> %h", mant_sum_abs, mant_norm_pre); fp_dv_pkg::sva_errors++; end
endmodule

bind FLP_adder flp_add_internal_sva u_int_sva (.clk(tb_top.clk), .mant_sum_abs, .mant_norm_pre);
