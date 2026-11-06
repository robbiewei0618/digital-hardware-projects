// =============================================================================
// tb_top.sv - project 04: unsigned N x N multipliers returning the upper N bits
//
//   exact   : mul_operator, mul_row, mul_array       p == floor(a*b / 2^N)
//   approx. : mul_trunc_const_row (K=3|4),  mul_trunc_var_array (K=2|3)
//
// For the truncated designs the error e = p*2^N - a*b is measured in output
// ULPs (1 ULP = 2^N in product units). Contract checked: |e| < 1 ULP.
// Reported: min / max / mean error (the mean is the bias the constant or
// variable correction is meant to cancel).
// +define+N_W=8: exhaustive (65 536 pairs);  N_W=16: corners + NUM random.
// =============================================================================
`timescale 1ns/1ps
`ifndef N_W
  `define N_W 8
`endif

module tb_top;
  localparam int N = `N_W;
  localparam int KC = (N == 8) ? 3 : 4;
  localparam int KV = (N == 8) ? 2 : 3;
  logic clk = 0;
  always #5 clk = ~clk;

  logic [N-1:0] a, b;
  logic [N-1:0] p_op, p_row, p_arr, p_tc, p_tv;
  mul_operator        #(.N(N))         u_op  (.a, .b, .p_msb(p_op));
  mul_row             #(.N(N))         u_row (.a, .b, .p_msb(p_row));
  mul_array           #(.N(N))         u_arr (.a, .b, .p_msb(p_arr));
  mul_trunc_const_row #(.N(N), .K(KC)) u_tc  (.a, .b, .p_msb(p_tc));
  mul_trunc_var_array #(.N(N), .K(KV)) u_tv  (.a, .b, .p_msb(p_tv));

  int unsigned sva_errors = 0;
  a_exact_equiv: assert property (@(posedge clk) p_row == p_op && p_arr == p_op)
    else begin $error("[SVA] exact multipliers disagree for %h * %h", a, b); sva_errors++; end
  a_known: assert property (@(posedge clk) !$isunknown({p_op, p_row, p_arr, p_tc, p_tv}))
    else begin $error("[SVA] X on an output"); sva_errors++; end

  // ---------------------------------------------------------------- stats
  class err_stats;
    string name;
    longint n, n_viol, sum, emin, emax;     // errors in product units
    function new(string s); name = s; emin = '1 >>> 1; emax = -emin; endfunction
    function void add(longint e);
      n++; sum += e;
      if (e < emin) emin = e;
      if (e > emax) emax = e;
      if (e >= (longint'(1) << N) || e <= -(longint'(1) << N)) begin
        n_viol++;
        if (n_viol <= 5) $display("[MISMATCH] %s: %h * %h -> %h (error %0.3f ULP)", name, a, b,
                                  name == "trunc_const_row" ? p_tc : p_tv, real'(e) / real'(longint'(1) << N));
      end
    endfunction
    function void report();
      real ulp = real'(longint'(1) << N);
      $display("  %-18s checks=%0d  errors=%0d  %s   error/ULP: min %0.4f  max %0.4f  mean %0.4f", name, n, n_viol,
               n_viol == 0 ? "PASS" : "FAIL", real'(emin) / ulp, real'(emax) / ulp, real'(sum) / real'(n) / ulp);
    endfunction
  endclass
  err_stats s_tc = new("trunc_const_row"), s_tv = new("trunc_var_array");

  // coverage: error of the truncated designs in quarter-ULP bins, operand corners
  int cv_etc, cv_etv;     // floor(4*e/ULP)
  bit [1:0] cv_amax, cv_bmax;
  covergroup cg_trunc;
    option.per_instance = 1;
    // error in quarter ULPs: under-estimate, over by < 1/2 ULP, over by >= 1/2 ULP
    // (|e| >= 1 ULP is a contract violation, counted by err_stats)
    cp_err_const: coverpoint cv_etc { bins under = {[-4:-1]}; bins over_lo = {[0:1]}; bins over_hi = {[2:3]}; }
    cp_err_var:   coverpoint cv_etv { bins under = {[-4:-1]}; bins over_lo = {[0:1]}; bins over_hi = {[2:3]}; }
    cp_a: coverpoint cv_amax { bins zero = {0}; bins mid = {1}; bins max = {2}; }
    cp_b: coverpoint cv_bmax { bins zero = {0}; bins mid = {1}; bins max = {2}; }
    x_ab: cross cp_a, cp_b;
  endgroup
  cg_trunc cov = new();

  longint unsigned n_exact = 0, n_exact_err = 0;

  function automatic int qbin(longint e);
    longint q = (4 * e) >>> N;              // floor(4e / 2^N)
    return int'(q);
  endfunction

  task automatic apply(logic [N-1:0] x, logic [N-1:0] y);
    longint prod, e;
    logic [N-1:0] exact;
    a = x; b = y;
    @(negedge clk);
    prod = longint'(x) * longint'(y);
    exact = prod >> N;
    n_exact++;
    if (p_op != exact) begin n_exact_err++; if (n_exact_err <= 5) $display("[MISMATCH] exact: %h * %h -> %h, expected %h", x, y, p_op, exact); end
    e = (longint'(p_tc) << N) - prod; s_tc.add(e); cv_etc = qbin(e);
    e = (longint'(p_tv) << N) - prod; s_tv.add(e); cv_etv = qbin(e);
    cv_amax = (x == 0) ? 0 : (&x) ? 2 : 1;
    cv_bmax = (y == 0) ? 0 : (&y) ? 2 : 1;
    cov.sample();
  endtask

  initial begin
    longint unsigned num = 2000000;
    logic [N-1:0] c[$];
    void'($value$plusargs("NUM=%d", num));
    if (N <= 8) begin
      for (longint i = 0; i < (longint'(1) << (2 * N)); i++) apply(i[N-1:0], i[2*N-1:N]);
    end else begin
      c = '{'0, 1, '1, {1'b1, {(N-1){1'b0}}}, {(N/2){2'b10}}, {(N/2){2'b01}}, '1 - 1};
      foreach (c[i]) foreach (c[j]) apply(c[i], c[j]);
      // dense random plus operands with many ones (largest truncation error)
      for (longint i = 0; i < num; i++)
        apply(i[0] ? N'($urandom) : N'($urandom | $urandom), i[1] ? N'($urandom) : N'($urandom | $urandom));
    end
    $display("\n================ project 04 results (%0dx%0d) ================", N, N);
    $display("  %-18s checks=%0d  errors=%0d  %s", "exact (op/row/arr)", n_exact, n_exact_err, n_exact_err == 0 ? "PASS" : "FAIL");
    s_tc.report();
    s_tv.report();
    $display("COVERAGE cg_trunc %0.2f", cov.get_inst_coverage());
    $display("  %-18s failures=%0d  %s", "SVA", sva_errors, sva_errors == 0 ? "PASS" : "FAIL");
    if (n_exact_err || s_tc.n_viol || s_tv.n_viol || sva_errors) $fatal(1, "TEST FAILED");
    $display("TEST PASSED");
    $finish;
  end
endmodule
