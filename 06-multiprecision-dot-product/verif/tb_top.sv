// =============================================================================
// tb_top.sv - self-checking testbench for project 06 (fused FP32/FP16 DP4)
//
// z = x1*y1 + x2*y2 + x3*y3 + x4*y4, rounded once (RNE).
// precision = 0: binary32 operands;  precision = 1: binary16 operands in
// bits [31:16] (bits [15:0] are don't-care and are driven with garbage), the
// result in z[31:16].
//
// Design contract (from the RTL): subnormal inputs read as zero (DAZ), tiny
// results flush to zero (FTZ), no Inf/NaN support (exponent all-ones is not
// a legal input), so the stimulus stays finite.
//
// One build per DUT (the three files reuse sub-module names):
//   +define+DUT_COMB | DUT_PIPE | DUT_CG, LAT = DUT latency in cycles.
// The precision bit changes randomly every cycle, so the pipelines must
// carry it alongside the data.
// =============================================================================
`timescale 1ns/1ps

module tb_top;
  import fp_dv_pkg::*;

  localparam int HIST = 16;
`ifdef DUT_COMB
  localparam int LAT = 0;  localparam string NAME = "DP4";
`elsif DUT_PIPE
  localparam int LAT = 4;  localparam string NAME = "DP4_pipeline";
`else
  localparam int LAT = 4;  localparam string NAME = "DP4_pipeline_CG";
`endif

  logic clk = 1'b0, rst_n = 1'b0;
  always #5 clk = ~clk;

  logic [31:0] x1, x2, x3, x4, y1, y2, y3, y4, z;
  logic        precision;

`ifdef DUT_COMB
  DP4 dut (.x1, .x2, .x3, .x4, .y1, .y2, .y3, .y4, .precision, .z);
`elsif DUT_PIPE
  DP4_pipeline dut (.clk, .rst_n, .x1, .x2, .x3, .x4, .y1, .y2, .y3, .y4, .precision, .z);
`else
  DP4_pipeline_CG dut (.clk, .rst_n, .x1, .x2, .x3, .x4, .y1, .y2, .y3, .y4, .precision, .z);
`endif

  // ---------------------------------------------------------------- SVA
  logic [7:0] t_valid;
  bit         z_valid, z_fp16;   // set by the scoreboard: what z holds right now
  always_ff @(posedge clk) t_valid <= !rst_n ? 8'd0 : (t_valid == 8'hFF ? t_valid : t_valid + 8'd1);

  a_known: assert property (@(posedge clk) t_valid > LAT + 1 |-> !$isunknown(z))
    else begin $error("[SVA] %s: X on z", NAME); sva_errors++; end
  // result never subnormal, in either format
  a_ftz32: assert property (@(posedge clk) z_valid && !z_fp16 && z[30:23] == 0 |-> z[22:0] == 0)
    else begin $error("[SVA] %s: subnormal FP32 result %h", NAME, z); sva_errors++; end
  a_ftz16: assert property (@(posedge clk) z_valid && z_fp16 && z[30:26] == 0 |-> z[25:16] == 0)
    else begin $error("[SVA] %s: subnormal FP16 result %h", NAME, z[31:16]); sva_errors++; end

  // ---------------------------------------------------------------- coverage
  bit        cv_fp16, cv_prev_fp16, cv_mixed_signs, cv_flushed, cv_ovf, cv_zero_exact;
  int        cv_spread, cv_nzero, cv_cancel;
  round_e    cv_rd;

  covergroup cg_dp4;
    option.per_instance = 1;
    cp_prec: coverpoint cv_fp16 { bins fp32 = {0}; bins fp16 = {1}; }
    cp_switch: coverpoint {cv_prev_fp16, cv_fp16} {
      bins stay32 = {2'b00}; bins to16 = {2'b01}; bins to32 = {2'b10}; bins stay16 = {2'b11};
    }
    cp_round: coverpoint cv_rd;
    // exponent spread between the largest and smallest non-zero product
    cp_spread: coverpoint cv_spread {
      bins tight = {[0:1]}; bins near = {[2:11]}; bins mid = {[12:24]};
      bins wide = {[25:51]}; bins beyond = {[52:$]};
    }
    cp_signs: coverpoint cv_mixed_signs;
    cp_nzero: coverpoint cv_nzero { bins n[] = {[0:4]}; }
    // result exponent below the largest term (cancellation depth)
    cp_cancel: coverpoint cv_cancel iff (cv_mixed_signs && !cv_zero_exact) {
      bins none = {[$:1]}; bins some = {[2:10]}; bins deep = {[11:$]};
    }
    cp_zero: coverpoint cv_zero_exact { bins exact_zero = {1}; }
    cp_flushed: coverpoint cv_flushed { bins flushed = {1}; }
    cp_ovf: coverpoint cv_ovf { bins overflow = {1}; }
    x_prec_round:  cross cp_prec, cp_round;
    x_prec_spread: cross cp_prec, cp_spread;
    x_prec_cancel: cross cp_prec, cp_cancel;
    x_prec_flush:  cross cp_prec, cp_flushed;
    x_prec_ovf:    cross cp_prec, cp_ovf;
  endgroup
  cg_dp4 cov = new();

  // ---------------------------------------------------------------- stimulus
  // a finite operand of the given format, DAZ-aware (subnormals allowed: they
  // must read as zero), placed in the bits the DUT reads
  function automatic logic [31:0] place(int fmt, logic [31:0] v);
    return fmt == FP16 ? {v[15:0], 16'($urandom)} : v;
  endfunction

  function automatic logic [31:0] rand_finite(int fmt);
    logic [31:0] v;
    do v = rand_any(fmt, 0); while (fp_exp(fmt, v) == emax_raw(fmt));
    return v;
  endfunction

  function automatic logic [31:0] with_exp(int fmt, int e);
    if (e < 1) e = 1;
    if (e > emax_raw(fmt) - 1) e = emax_raw(fmt) - 1;
    return fp_pack(fmt, $urandom_range(0, 1), e, rand_mant(fmt));
  endfunction

  // the DUT has no Inf/NaN support: map any all-ones exponent produced by
  // the perturbations below to the largest finite value of the same sign
  function automatic logic [31:0] finite(int fmt, logic [31:0] v);
    if (fp_exp(fmt, v) != emax_raw(fmt)) return v;
    return fp_pack(fmt, fp_sign(fmt, v), emax_raw(fmt) - 1, (1 << mbits(fmt)) - 1);
  endfunction

  task automatic next_vector(int fmt, output logic [31:0] xs[4], output logic [31:0] ys[4]);
    next_vector_raw(fmt, xs, ys);
    foreach (xs[k]) begin xs[k] = finite(fmt, xs[k] & (fmt == FP16 ? 32'hFFFF : 32'hFFFF_FFFF));
                          ys[k] = finite(fmt, ys[k] & (fmt == FP16 ? 32'hFFFF : 32'hFFFF_FFFF)); end
  endtask

  task automatic next_vector_raw(int fmt, output logic [31:0] xs[4], output logic [31:0] ys[4]);
    int s = $urandom_range(0, 99);
    int b = bias(fmt);
    foreach (xs[k]) begin xs[k] = rand_finite(fmt); ys[k] = rand_finite(fmt); end
    if (s < 30) return;                                       // independent
    if (s < 55) begin                                         // pairwise cancellation
      ys[1] = ys[0]; xs[1] = xs[0] ^ (1 << (ebits(fmt) + mbits(fmt)));
      if ($urandom_range(0, 1)) xs[1] = xs[1] + $urandom_range(0, 2);
      if ($urandom_range(0, 1)) begin ys[3] = ys[2]; xs[3] = xs[2] ^ (1 << (ebits(fmt) + mbits(fmt))) ^ $urandom_range(0, 3); end
      return;
    end
    if (s < 75) begin                                         // wide exponent spread
      int e0 = $urandom_range(b - 4, b + 4);
      int sp = $urandom_range(0, 1) ? $urandom_range(0, 30) : $urandom_range(20, (fmt == FP16) ? 28 : 70);
      xs[0] = with_exp(fmt, e0); ys[0] = with_exp(fmt, b);
      for (int k = 1; k < 4; k++) begin
        xs[k] = with_exp(fmt, e0 - $urandom_range(0, sp));
        ys[k] = with_exp(fmt, b - $urandom_range(0, sp));
      end
      return;
    end
    if (s < 87) begin                                         // overflow edge
      foreach (xs[k]) begin
        xs[k] = with_exp(fmt, emax_raw(fmt) - 1 - $urandom_range(0, 2));
        ys[k] = with_exp(fmt, b + $urandom_range(0, 2) - (fmt == FP16 ? 0 : 0));
        if ($urandom_range(0, 1)) begin xs[k][ebits(fmt) + mbits(fmt)] = 1'b0; ys[k][ebits(fmt) + mbits(fmt)] = 1'b0; end
      end
      return;
    end
    foreach (xs[k]) begin                                     // underflow / FTZ edge
      xs[k] = with_exp(fmt, $urandom_range(1, b / 2 + 2));
      ys[k] = with_exp(fmt, b / 2 + $urandom_range(0, 4) - 2);
    end
  endtask

  // ---------------------------------------------------------------- scoreboard
  check_stats st = new(NAME);
  logic [31:0] h_ref[HIST], h_x[HIST][4], h_y[HIST][4];
  logic        h_p[HIST];

  // Same-sign products must be correctly rounded (bit-exact). When products
  // of different signs cancel, a finite alignment window cannot keep the bits
  // of much smaller products; then the result must stay within the window
  // error bound (fpref_dot4_window_ok, WINDOW bits below the largest product).
  localparam int WINDOW = 48;
  check_stats st_win = new({NAME, " (window)"});
  bit h_mixed[HIST];
  longint n_window_limited = 0;

  task automatic check_one(int k, longint src);
    int fmt = h_p[k] ? FP16 : FP32;
    logic [31:0] got = h_p[k] ? {16'h0, z[31:16]} : z;
    logic [31:0] xs[4], ys[4];
    bit exact;
    string msg;
    for (int j = 0; j < 4; j++) begin
      xs[j] = h_p[k] ? {16'h0, h_x[k][j][31:16]} : h_x[k][j];
      ys[j] = h_p[k] ? {16'h0, h_y[k][j][31:16]} : h_y[k][j];
    end
    exact = fp_same(fmt, got, h_ref[k]);
    // documented behaviour: the DP4 returns +0 for every zero result (the
    // sign of an exact/flushed zero is not tracked), so zeros match any zero
    if (((got | h_ref[k]) & (fmt == FP16 ? 32'h7FFF : 32'h7FFF_FFFF)) == 0) exact = 1;
    msg = $sformatf("vec %0d %s: x=%h %h %h %h y=%h %h %h %h -> dut %h ref %h", src, h_p[k] ? "FP16" : "FP32",
                    xs[0], xs[1], xs[2], xs[3], ys[0], ys[1], ys[2], ys[3], got, h_ref[k]);
    if (exact || !h_mixed[k]) begin
      st.check(exact, msg);
    end else begin
      // inexact with cancellation: allowed only within the window bound
      bit ok = fpref_dot4_window_ok(fmt, xs[0], xs[1], xs[2], xs[3], ys[0], ys[1], ys[2], ys[3],
                                    got, MODE_FTZ | MODE_DAZ, WINDOW) != 0;
      st_win.check(ok, {msg, " (outside window bound)"});
      if (ok) n_window_limited++;
    end
  endtask

  int unsigned num = 200000;
  longint t = 0;

  initial begin
    logic [31:0] xs[4], ys[4];
    int fmt, fl, ex, emaxp, eminp;
    int unsigned r;
    longint src;
    int k;
    bit prev16 = 0;

    if ($value$plusargs("NUM=%d", num)) ;
    {x1, x2, x3, x4, y1, y2, y3, y4} = '0; precision = 1'b0;
    repeat (3) @(negedge clk);
    rst_n = 1'b1;

    for (longint i = 0; i < num + 10; i++) begin
      @(negedge clk);
      // check the result that is due now
      src = t - (LAT < 1 ? 1 : LAT);
      z_valid = src >= 0;
      if (src >= 0) begin
        k = int'(src % HIST);
        z_fp16 = h_p[k];
        check_one(k, src);
      end
      // next vector
      fmt = $urandom_range(0, 2) == 0 ? FP16 : FP32;
      next_vector(fmt, xs, ys);
      r = fpref_dot4(fmt, xs[0], xs[1], xs[2], xs[3], ys[0], ys[1], ys[2], ys[3], MODE_FTZ | MODE_DAZ, fl);
      precision = (fmt == FP16);
      // a combinational DUT shows this vector's result before the next edge
      if (LAT == 0) begin z_valid = 1; z_fp16 = (fmt == FP16); end
      x1 = place(fmt, xs[0]); x2 = place(fmt, xs[1]); x3 = place(fmt, xs[2]); x4 = place(fmt, xs[3]);
      y1 = place(fmt, ys[0]); y2 = place(fmt, ys[1]); y3 = place(fmt, ys[2]); y4 = place(fmt, ys[3]);
      k = int'(t % HIST);
      h_ref[k] = r; h_p[k] = precision;
      h_x[k][0] = x1; h_x[k][1] = x2; h_x[k][2] = x3; h_x[k][3] = x4;
      h_y[k][0] = y1; h_y[k][1] = y2; h_y[k][2] = y3; h_y[k][3] = y4;

      // coverage of the applied vector
      cv_fp16 = precision; cv_prev_fp16 = prev16; prev16 = precision;
      cv_rd = round_kind(fl, r);
      cv_flushed = (fl & F_FLUSHED) != 0; cv_ovf = (fl & F_OVERFLOW) != 0;
      cv_zero_exact = (fl & F_EXACT_ZERO) != 0;
      cv_nzero = 0; emaxp = -1000; eminp = 1000; cv_mixed_signs = 0;
      for (int j = 0; j < 4; j++) begin
        if (fp_exp(fmt, xs[j]) == 0 || fp_exp(fmt, ys[j]) == 0) cv_nzero++;
        else begin
          ex = int'(fp_exp(fmt, xs[j])) + int'(fp_exp(fmt, ys[j]));
          if (ex > emaxp) emaxp = ex;
          if (ex < eminp) eminp = ex;
          if (fp_sign(fmt, xs[j]) ^ fp_sign(fmt, ys[j]) ^ fp_sign(fmt, xs[0]) ^ fp_sign(fmt, ys[0])) cv_mixed_signs = 1;
        end
      end
      cv_spread = cv_nzero == 4 ? 0 : emaxp - eminp;
      h_mixed[k] = cv_mixed_signs;
      cv_cancel = (fp_exp(fmt, r) == 0) ? 99 : emaxp - bias(fmt) - int'(fp_exp(fmt, r));
      cov.sample();
      t++;
    end

    $display("\n================ project 06 results (%s) ================", NAME);
    st.report();
    st_win.report();
    $display("  %-18s %0d of %0d results differ from the correctly rounded value (cancellation, inside the window bound)",
             "window-limited", n_window_limited, st.n_checks + st_win.n_checks);
    $display("COVERAGE cg_dp4   %0.2f", cov.get_inst_coverage());
    $display("  %-18s failures=%0d  %s", "SVA", sva_errors, sva_errors == 0 ? "PASS" : "FAIL");
    if (!st.passed() || st_win.n_errors != 0 || sva_errors != 0) $fatal(1, "TEST FAILED");
    $display("TEST PASSED");
    $finish;
  end
endmodule
