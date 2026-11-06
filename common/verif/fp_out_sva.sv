// =============================================================================
// fp_out_sva.sv - output contract of the floating-point units in this repo
//
// Instantiated (or bound) once per DUT output. `en` must be low until the
// pipeline holds valid data. All designs here share one contract:
//   * the result is never X/Z
//   * no subnormal results: tiny results are flushed to a signed zero (FTZ)
//   * every NaN result is the canonical quiet NaN 0 | all-ones | 10...0
// =============================================================================
module fp_out_sva #(
  parameter int EB = 8,
  parameter int MB = 23,
  parameter string NAME = "dut"
) (
  input logic             clk,
  input logic             en,
  input logic [EB+MB:0]   d
);
  localparam logic [EB+MB:0] QNAN = {1'b0, {EB{1'b1}}, 1'b1, {(MB-1){1'b0}}};

  wire is_nan = (&d[EB+MB-1:MB]) && (d[MB-1:0] != '0);

  a_known: assert property (@(posedge clk) en |-> !$isunknown(d))
    else begin $error("[SVA] %s: X/Z on result", NAME); fp_dv_pkg::sva_errors++; end

  a_ftz: assert property (@(posedge clk) en && d[EB+MB-1:MB] == '0 |-> d[MB-1:0] == '0)
    else begin $error("[SVA] %s: subnormal result %h (FTZ contract)", NAME, d); fp_dv_pkg::sva_errors++; end

  a_qnan: assert property (@(posedge clk) en && is_nan |-> d == QNAN)
    else begin $error("[SVA] %s: non-canonical NaN %h", NAME, d); fp_dv_pkg::sva_errors++; end

  // the checks above must actually be exercised
  c_nan:  cover property (@(posedge clk) en && is_nan);
  c_zero: cover property (@(posedge clk) en && d[EB+MB-1:0] == '0);
  c_inf:  cover property (@(posedge clk) en && (&d[EB+MB-1:MB]) && d[MB-1:0] == '0);
endmodule
