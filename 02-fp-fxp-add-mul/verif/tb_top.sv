// =============================================================================
// tb_top.sv - self-checking testbench for project 02 (FP/FXP add & multiply)
//
// All seven DUTs see the same operand stream every cycle:
//   FXP_adder, FXP_mul                     (combinational, integer/Q15.16)
//   FLP_adder, FLP_adder_4, FLP_adder_7    (latency 0 / 3 / 7)
//   FLP_Multiplier, FLP_Multiplier_4       (latency 0 / 2)
//
// Reference: common/fpref (exact, RNE, flush-to-zero after rounding).
// Scoreboard: per-DUT latency-aligned compare, bit-exact (any NaN == any NaN;
// the canonical-NaN rule is an SVA in fp_out_sva).
// Plusargs: +NUM=<n> random vectors (default 200000), +verilator+seed+<s>
// =============================================================================
`timescale 1ns/1ps

module tb_top;
  import fp_dv_pkg::*;

  localparam int HIST = 16;

  logic clk = 1'b0, rst = 1'b1;
  always #5 clk = ~clk;

  // ------------------------------------------------------------------ DUTs
  logic [31:0] a, b, fx_a, fx_b;
  logic [31:0] d_fxadd, d_fxmul, d_add0, d_add4, d_add7, d_mul0, d_mul4, d_add0_sw, d_mul0_sw;

  FXP_adder        u_fxadd (.a(fx_a), .b(fx_b), .d(d_fxadd));
  FXP_mul          u_fxmul (.a(fx_a), .b(fx_b), .d(d_fxmul));
  FLP_adder        u_add0  (.clk(clk), .rst(rst), .a(a), .b(b), .d(d_add0));
  FLP_adder_4      u_add4  (.clk(clk), .rst(rst), .a(a), .b(b), .d(d_add4));
  FLP_adder_7      u_add7  (.clk(clk), .rst(rst), .a(a), .b(b), .d(d_add7));
  FLP_Multiplier   u_mul0  (.a(a), .b(b), .d(d_mul0));
  FLP_Multiplier_4 u_mul4  (.clk(clk), .rst(rst), .a(a), .b(b), .d(d_mul4));

  // metamorphic check: a second copy with swapped operands must agree
  FLP_adder        u_add0_sw (.clk(clk), .rst(rst), .a(b), .b(a), .d(d_add0_sw));
  FLP_Multiplier   u_mul0_sw (.a(b), .b(a), .d(d_mul0_sw));

  // ---------------------------------------------------- output contract SVA
  logic [7:0] t_valid;          // cycles since reset release (saturating)
  always_ff @(posedge clk) t_valid <= rst ? 8'd0 : (t_valid == 8'hFF ? t_valid : t_valid + 8'd1);

  fp_out_sva #(.NAME("FLP_adder"))        sva_add0 (.clk, .en(t_valid > 1), .d(d_add0));
  fp_out_sva #(.NAME("FLP_adder_4"))      sva_add4 (.clk, .en(t_valid > 4), .d(d_add4));
  fp_out_sva #(.NAME("FLP_adder_7"))      sva_add7 (.clk, .en(t_valid > 8), .d(d_add7));
  fp_out_sva #(.NAME("FLP_Multiplier"))   sva_mul0 (.clk, .en(t_valid > 1), .d(d_mul0));
  fp_out_sva #(.NAME("FLP_Multiplier_4")) sva_mul4 (.clk, .en(t_valid > 3), .d(d_mul4));

  a_add_commutes: assert property (@(posedge clk) t_valid > 1 |-> d_add0 == d_add0_sw)
    else begin $error("[SVA] FLP_adder not commutative: %h + %h", a, b); sva_errors++; end
  a_mul_commutes: assert property (@(posedge clk) t_valid > 1 |-> d_mul0 == d_mul0_sw)
    else begin $error("[SVA] FLP_Multiplier not commutative: %h * %h", a, b); sva_errors++; end

  // ------------------------------------------------------ reference models
  function automatic logic [31:0] fxp_mul_ref(logic [31:0] x, logic [31:0] y, output bit sat, output bit tie);
    longint p, keep, r;
    bit guard, sticky;
    p = longint'($signed(x)) * longint'($signed(y));
    keep = p >>> 16;
    guard = p[15];
    sticky = |p[14:0];
    tie = guard && !sticky;
    r = keep + longint'(guard && (sticky || keep[0]));
    sat = 1'b0;
    if (r > 64'sh7FFF_FFFF)       begin r = 64'sh7FFF_FFFF; sat = 1'b1; end
    else if (r < -64'sh8000_0000) begin r = -64'sh8000_0000; sat = 1'b1; end
    return r[31:0];
  endfunction

  // ----------------------------------------------------------- coverage
  fp_class_e cv_ca, cv_cb, cv_cr;
  round_e    cv_rd;
  int        cv_ediff, cv_esum;
  bit        cv_effsub, cv_flushed, cv_ovf, cv_zero_exact, cv_finite;
  bit        cv_sat, cv_tie, cv_fx_neg;

  covergroup cg_fadd;
    option.per_instance = 1;
    cp_a:   coverpoint cv_ca;
    cp_b:   coverpoint cv_cb;
    x_ab:   cross cp_a, cp_b;
    cp_res: coverpoint cv_cr;
    cp_round: coverpoint cv_rd iff (cv_finite);
    cp_ediff: coverpoint cv_ediff iff (cv_finite) {
      bins d0 = {0}; bins d1 = {1}; bins d2_23 = {[2:23]}; bins d24_26 = {[24:26]}; bins far = {[27:$]};
    }
    cp_effsub: coverpoint cv_effsub iff (cv_finite);
    x_effsub_round: cross cp_effsub, cp_round;
    x_effsub_ediff: cross cp_effsub, cp_ediff;
    cp_cancel:  coverpoint cv_zero_exact iff (cv_finite) { bins exact_zero = {1}; }
    cp_flushed: coverpoint cv_flushed { bins flushed = {1}; }
    cp_ovf:     coverpoint cv_ovf     { bins overflow = {1}; }
  endgroup

  covergroup cg_fmul;
    option.per_instance = 1;
    cp_a:   coverpoint cv_ca;
    cp_b:   coverpoint cv_cb;
    x_ab:   cross cp_a, cp_b;
    cp_res: coverpoint cv_cr;
    cp_round: coverpoint cv_rd iff (cv_finite);
    // biased exponent of the exact product (before normalisation)
    cp_esum: coverpoint cv_esum iff (cv_finite) {
      bins deep_uf  = {[$:-24]};
      bins ftz_edge = {[-23:0]};
      bins low      = {[1:10]};
      bins mid      = {[11:243]};
      bins high     = {[244:254]};
      bins ovf      = {[255:$]};
    }
    cp_flushed: coverpoint cv_flushed { bins flushed = {1}; }
    cp_ovf:     coverpoint cv_ovf     { bins overflow = {1}; }
    x_esum_round: cross cp_esum, cp_round;
  endgroup

  covergroup cg_fxmul;
    option.per_instance = 1;
    cp_sat:  coverpoint cv_sat  { bins no_sat = {0}; bins sat = {1}; }
    cp_tie:  coverpoint cv_tie  { bins tie = {1}; }
    cp_sign: coverpoint cv_fx_neg;
    x_sat_sign: cross cp_sat, cp_sign;
  endgroup

  cg_fadd  cov_add   = new();
  cg_fmul  cov_mul   = new();
  cg_fxmul cov_fxmul = new();

  function automatic int exp_unb(int unsigned x);   // exponent, subnormal -> 1
    int e = int'(fp_exp(FP32, x));
    return e == 0 ? 1 : e;
  endfunction

  // ---------------------------------------------------------- scoreboard
  check_stats st_fxadd = new("FXP_adder");
  check_stats st_fxmul = new("FXP_mul");
  check_stats st_add0  = new("FLP_adder");
  check_stats st_add4  = new("FLP_adder_4");
  check_stats st_add7  = new("FLP_adder_7");
  check_stats st_mul0  = new("FLP_Multiplier");
  check_stats st_mul4  = new("FLP_Multiplier_4");

  logic [31:0] h_a[HIST], h_b[HIST], h_add[HIST], h_mul[HIST];

  // DUT output at negedge t corresponds to the input applied at negedge
  // t - max(latency, 1)
  task automatic check_pipe(check_stats st, int lat, longint t, logic [31:0] dut, logic [31:0] hist_ref[HIST], string op);
    longint src = t - (lat < 1 ? 1 : lat);
    int k;
    if (src < 0) return;
    k = int'(src % HIST);
    st.check(fp_same(FP32, dut, hist_ref[k]),
             $sformatf("vec %0d: %h %s %h -> dut %h ref %h", src, h_a[k], op, h_b[k], dut, hist_ref[k]));
  endtask

  // ---------------------------------------------------------- stimulus
  int unsigned directed[$];
  initial begin
    // signed zeros, subnormal/normal limits, +-1, max finite, inf, qNaN, sNaN
    int unsigned base[] = '{32'h0000_0000, 32'h0000_0001, 32'h007F_FFFF, 32'h0080_0000,
                            32'h3F80_0000, 32'h3F80_0001, 32'h7F7F_FFFF, 32'h7F80_0000,
                            32'h7FC0_0000, 32'h7F80_0001, 32'h3400_0000};
    foreach (base[i]) begin directed.push_back(base[i]); directed.push_back(base[i] | 32'h8000_0000); end
  end

  // one operand pair according to a scenario mix
  task automatic next_operands(output logic [31:0] x, output logic [31:0] y);
    int s = $urandom_range(0, 99);
    if (s < 40) begin x = rand_any(FP32); y = rand_any(FP32); end
    else if (s < 70) begin x = rand_any(FP32); y = rand_partner(FP32, x); end
    else if (s < 85) begin
      // multiply: steer the exponent sum to the underflow / overflow edges
      int ea = $urandom_range(1, 254), eb;
      eb = ($urandom_range(0, 1) ? 127 - ea + $urandom_range(0, 30) - 15
                                 : 127 + 254 - ea + $urandom_range(0, 6) - 3);
      if (eb < 0) eb = 0;
      if (eb > 254) eb = 254;
      x = fp_pack(FP32, $urandom_range(0, 1), ea, rand_mant(FP32));
      y = fp_pack(FP32, $urandom_range(0, 1), eb, rand_mant(FP32));
    end else begin
      // multiply: exact rounding ties, 1.5 * (1 + odd*2^-23) * 2^k
      int k = $urandom_range(0, 60) - 30;
      x = fp_pack(FP32, $urandom_range(0, 1), 127 + k, 23'h40_0000);
      y = fp_pack(FP32, $urandom_range(0, 1), 127 - k / 2, ($urandom & 23'h7F_FFFE) | 23'h1);
    end
  endtask

  task automatic next_fxp(output logic [31:0] x, output logic [31:0] y);
    case ($urandom_range(0, 7))
      0: begin x = $urandom; y = $urandom; end
      1: begin x = $urandom & 32'h0003_FFFF; y = $urandom & 32'h0003_FFFF; end   // small values
      2: begin x = 32'h7FFF_FFFF - $urandom_range(0, 3); y = $urandom_range(0, 1) ? 32'h0001_0000 : 32'h0002_0000; end
      3: begin x = 32'h8000_0000 + $urandom_range(0, 3); y = $urandom_range(0, 1) ? 32'hFFFF_0000 : 32'h0001_8000; end
      4: begin x = {$urandom} | 32'h0000_8000; y = 32'h0000_8000; end               // * 0.5 -> exact ties
      5: begin x = $urandom; y = {16'h0, $urandom_range(0, 1) ? 16'h8000 : 16'h0000} | (32'h0001_0000 << $urandom_range(0, 14)); end
      6: begin x = -$urandom_range(1, 1 << 20); y = $urandom_range(1, 1 << 20); end
      default: begin x = 32'(-$signed($urandom)); y = 32'(-$signed($urandom)); end
    endcase
  endtask

  int unsigned num = 200000;
  longint t = 0;

  initial begin
    int f_add, f_mul;
    int unsigned r_add, r_mul;
    logic [31:0] x, y, fx, fy, fx_ref;
    bit sat, tie;
    longint n_total;
    bit fail;

    if ($value$plusargs("NUM=%d", num)) ;
    a = '0; b = '0; fx_a = '0; fx_b = '0;
    repeat (3) @(negedge clk);
    rst = 1'b0;

    n_total = directed.size() * directed.size() + num;
    for (longint i = 0; i < n_total + 10; i++) begin
      @(negedge clk);
      // 1) check everything that is due at this edge
      st_fxadd.check(d_fxadd == fx_a + fx_b, $sformatf("%h + %h -> %h", fx_a, fx_b, d_fxadd));
      fx_ref = fxp_mul_ref(fx_a, fx_b, sat, tie);
      st_fxmul.check(d_fxmul == fx_ref, $sformatf("%h * %h -> dut %h ref %h", fx_a, fx_b, d_fxmul, fx_ref));
      cv_sat = sat; cv_tie = tie; cv_fx_neg = fx_ref[31]; cov_fxmul.sample();
      if (i > 0) begin
        check_pipe(st_add0, 0, t, d_add0, h_add, "+");
        check_pipe(st_add4, 3, t, d_add4, h_add, "+");
        check_pipe(st_add7, 7, t, d_add7, h_add, "+");
        check_pipe(st_mul0, 0, t, d_mul0, h_mul, "*");
        check_pipe(st_mul4, 2, t, d_mul4, h_mul, "*");
      end

      // 2) drive the next vector
      if (i < directed.size() * directed.size()) begin
        x = directed[i / directed.size()];
        y = directed[i % directed.size()];
      end else next_operands(x, y);
      next_fxp(fx, fy);
      a = x; b = y; fx_a = fx; fx_b = fy;

      r_add = fpref_add(FP32, x, y, MODE_FTZ, f_add);
      r_mul = fpref_mul(FP32, x, y, MODE_FTZ, f_mul);
      h_a[t % HIST] = x; h_b[t % HIST] = y;
      h_add[t % HIST] = r_add; h_mul[t % HIST] = r_mul;

      // 3) functional coverage of what was just applied
      cv_ca = fp_class(FP32, x); cv_cb = fp_class(FP32, y);
      cv_finite = (cv_ca inside {CL_SUB, CL_NORM}) && (cv_cb inside {CL_SUB, CL_NORM});
      cv_cr = fp_class(FP32, r_add); cv_rd = round_kind(f_add, r_add);
      cv_ediff = exp_unb(x) > exp_unb(y) ? exp_unb(x) - exp_unb(y) : exp_unb(y) - exp_unb(x);
      cv_effsub = x[31] ^ y[31];
      cv_flushed = (f_add & F_FLUSHED) != 0; cv_ovf = (f_add & F_OVERFLOW) != 0;
      cv_zero_exact = (f_add & F_EXACT_ZERO) != 0;
      cov_add.sample();
      cv_cr = fp_class(FP32, r_mul); cv_rd = round_kind(f_mul, r_mul);
      cv_esum = exp_unb(x) + exp_unb(y) - 127;
      cv_flushed = (f_mul & F_FLUSHED) != 0; cv_ovf = (f_mul & F_OVERFLOW) != 0;
      cov_mul.sample();
      t++;
    end

    $display("\n================ project 02 results ================");
    st_fxadd.report(); st_fxmul.report();
    st_add0.report(); st_add4.report(); st_add7.report();
    st_mul0.report(); st_mul4.report();
    $display("COVERAGE cg_fadd  %0.2f", cov_add.get_inst_coverage());
    $display("COVERAGE cg_fmul  %0.2f", cov_mul.get_inst_coverage());
    $display("COVERAGE cg_fxmul %0.2f", cov_fxmul.get_inst_coverage());
    $display("  %-18s failures=%0d  %s", "SVA", sva_errors, sva_errors == 0 ? "PASS" : "FAIL");
    fail = !(st_fxadd.passed() && st_fxmul.passed() && st_add0.passed() && st_add4.passed() &&
             st_add7.passed() && st_mul0.passed() && st_mul4.passed()) || sva_errors != 0;
    if (fail) $fatal(1, "TEST FAILED");
    $display("TEST PASSED");
    $finish;
  end
endmodule
