// =============================================================================
// tb_top.sv - project 03: six signed M x N multipliers against $signed(a)*$signed(b)
//
//   multiply_op (reference "*"), multiply_row, multiply_row_opt (sign-
//   extension reduction), multiply_mbw (modified Baugh-Wooley),
//   multiply_booth, multiply_booth_opt (radix-4 Booth)
//
// Build per size: +define+M_W=<M> +define+N_W=<N>.
//   M+N <= 24: exhaustive (all 2^(M+N) operand pairs)
//   otherwise: corner matrix + NUM random pairs (+NUM=, default 2 000 000)
// SVA: all six products equal on every sample (equivalence), no X.
// Coverage: operand corners (min, -1, 0, 1, max) for a x b, and the radix-4
// Booth digit (-2..+2) seen in each of the first four multiplier groups.
// =============================================================================
`timescale 1ns/1ps
`ifndef M_W
  `define M_W 8
`endif
`ifndef N_W
  `define N_W 8
`endif

module tb_top;
  localparam int M = `M_W, N = `N_W;
  logic clk = 0;
  always #5 clk = ~clk;

  logic [M-1:0] a;
  logic [N-1:0] b;
  logic [M+N-1:0] p_op, p_row, p_row_opt, p_mbw, p_booth, p_booth_opt;

  multiply_op        #(.M(M), .N(N)) u_op        (.a, .b, .p(p_op));
  multiply_row       #(.M(M), .N(N)) u_row       (.a, .b, .p(p_row));
  multiply_row_opt   #(.M(M), .N(N)) u_row_opt   (.a, .b, .p(p_row_opt));
  multiply_mbw       #(.M(M), .N(N)) u_mbw       (.a, .b, .p(p_mbw));
  multiply_booth     #(.M(M), .N(N)) u_booth     (.a, .b, .p(p_booth));
  multiply_booth_opt #(.M(M), .N(N)) u_booth_opt (.a, .b, .p(p_booth_opt));

  int unsigned sva_errors = 0;
  a_equiv: assert property (@(posedge clk)
      p_row == p_op && p_row_opt == p_op && p_mbw == p_op && p_booth == p_op && p_booth_opt == p_op)
    else begin $error("[SVA] implementations disagree for %h * %h", a, b); sva_errors++; end
  a_known: assert property (@(posedge clk) !$isunknown({p_op, p_row, p_row_opt, p_mbw, p_booth, p_booth_opt}))
    else begin $error("[SVA] X in a product"); sva_errors++; end

  // ---------------------------------------------------------------- coverage
  typedef enum int { V_MIN, V_M1, V_ZERO, V_P1, V_MAX, V_OTHER } val_e;
  function automatic val_e classify(longint v, int w);
    if (v == -(longint'(1) << (w - 1))) return V_MIN;
    if (v == -1) return V_M1;
    if (v == 0)  return V_ZERO;
    if (v == 1)  return V_P1;
    if (v == (longint'(1) << (w - 1)) - 1) return V_MAX;
    return V_OTHER;
  endfunction
  function automatic int booth_digit(logic [N-1:0] x, int g);   // group g: {x[2g+1], x[2g], x[2g-1]}
    logic [2:0] t = {x[2*g+1], x[2*g], (g == 0) ? 1'b0 : x[2*g-1]};
    case (t)
      3'b000, 3'b111: return 0;
      3'b001, 3'b010: return 1;
      3'b011:         return 2;
      3'b100:         return -2;
      default:        return -1;
    endcase
  endfunction

  val_e cv_a, cv_b;
  int   cv_d0, cv_d1, cv_d2, cv_d3;
  covergroup cg_mul;
    option.per_instance = 1;
    cp_a: coverpoint cv_a;
    cp_b: coverpoint cv_b;
    x_ab: cross cp_a, cp_b;
    // group 0 sees {b1, b0, 0}: the +2 pattern 011 cannot occur
    cp_d0: coverpoint cv_d0 { bins d[] = {[-2:1]}; }
    cp_d1: coverpoint cv_d1 { bins d[] = {[-2:2]}; }
    cp_d2: coverpoint cv_d2 { bins d[] = {[-2:2]}; }
    cp_d3: coverpoint cv_d3 { bins d[] = {[-2:2]}; }
  endgroup
  cg_mul cov = new();

  longint unsigned n_checks = 0, n_errors = 0;

  task automatic apply(logic [M-1:0] x, logic [N-1:0] y);
    longint expected;
    a = x; b = y;
    @(negedge clk);
    expected = longint'($signed(x)) * longint'($signed(y));
    n_checks++;
    if (p_op != expected[M+N-1:0]) begin
      n_errors++;
      if (n_errors <= 8) $display("[MISMATCH] %h * %h -> %h, expected %h", x, y, p_op, expected[M+N-1:0]);
    end
    cv_a = classify(longint'($signed(x)), M); cv_b = classify(longint'($signed(y)), N);
    cv_d0 = booth_digit(y, 0); cv_d1 = booth_digit(y, 1); cv_d2 = booth_digit(y, 2); cv_d3 = booth_digit(y, 3);
    cov.sample();
  endtask

  initial begin
    longint unsigned num = 2000000;
    logic [M-1:0] ca[$];
    logic [N-1:0] cb[$];
    void'($value$plusargs("NUM=%d", num));
    if (M + N <= 24) begin
      for (longint i = 0; i < (longint'(1) << (M + N)); i++) apply(i[M-1:0], i[M+N-1:M]);
    end else begin
      // corners: min, -1, 0, 1, max and single-bit / alternating patterns
      ca = '{{1'b1, {(M-1){1'b0}}}, '1, '0, 1, {1'b0, {(M-1){1'b1}}}, {(M/2){2'b10}}, {(M/2){2'b01}}};
      cb = '{{1'b1, {(N-1){1'b0}}}, '1, '0, 1, {1'b0, {(N-1){1'b1}}}, {(N/2){2'b10}}, {(N/2){2'b01}}};
      foreach (ca[i]) foreach (cb[j]) apply(ca[i], cb[j]);
      for (longint i = 0; i < num; i++) apply(M'($urandom), N'($urandom));
    end
    $display("\n================ project 03 results (%0dx%0d) ================", M, N);
    $display("  %-18s checks=%0d  errors=%0d  %s", $sformatf("multipliers_%0dx%0d", M, N), n_checks, n_errors,
             n_errors == 0 ? "PASS" : "FAIL");
    $display("COVERAGE cg_mul   %0.2f", cov.get_inst_coverage());
    $display("  %-18s failures=%0d  %s", "SVA", sva_errors, sva_errors == 0 ? "PASS" : "FAIL");
    if (n_errors != 0 || sva_errors != 0) $fatal(1, "TEST FAILED");
    $display("TEST PASSED");
    $finish;
  end
endmodule
