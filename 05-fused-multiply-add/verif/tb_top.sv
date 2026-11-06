// =============================================================================
// tb_top.sv - self-checking testbench for project 05 (fused multiply-add)
//
//   FXP_FMA    d = (a*b + sign_ext(c))[63:32]   (course definition)
//   FLP_FMA    R = A*B + C, binary32, one rounding (RNE), gradual underflow
//   FLP_FMA_4  same, 4-stage pipeline (latency LAT_FMA4)
//
// Reference: common/fpref fpref_fma() in IEEE mode (subnormal results kept).
// Plusargs: +NUM=<n> random vectors (default 200000), +verilator+seed+<s>
// =============================================================================
`timescale 1ns/1ps

module tb_top;
  import fp_dv_pkg::*;

  localparam int HIST = 16;
  localparam int LAT_FMA4 = 4;

  logic clk = 1'b0, rst = 1'b1;
  always #5 clk = ~clk;

  logic [31:0] a, b, c, fx_a, fx_b, fx_c;
  logic [31:0] d_fx, d_fma0, d_fma4, d_fma0_sw;

  FXP_FMA   u_fx   (.a(fx_a), .b(fx_b), .c(fx_c), .d(d_fx));
  FLP_FMA   u_fma0 (.A(a), .B(b), .C(c), .R(d_fma0));
  FLP_FMA_4 u_fma4 (.clk(clk), .rst(rst), .a(a), .b(b), .c(c), .d(d_fma4));
  // metamorphic: a*b + c == b*a + c
  FLP_FMA   u_fma0_sw (.A(b), .B(a), .C(c), .R(d_fma0_sw));

  logic [7:0] t_valid;
  always_ff @(posedge clk) t_valid <= rst ? 8'd0 : (t_valid == 8'hFF ? t_valid : t_valid + 8'd1);

  fp_out_sva #(.FTZ(0), .NAME("FLP_FMA"))   sva_fma0 (.clk, .en(t_valid > 1), .d(d_fma0));
  fp_out_sva #(.FTZ(0), .NAME("FLP_FMA_4")) sva_fma4 (.clk, .en(t_valid > LAT_FMA4 + 1), .d(d_fma4));

  a_commutes: assert property (@(posedge clk) t_valid > 1 |-> d_fma0 == d_fma0_sw)
    else begin $error("[SVA] FLP_FMA: a*b+c != b*a+c for %h %h %h", a, b, c); sva_errors++; end

  // ----------------------------------------------------------- coverage
  fp_class_e cv_ca, cv_cb, cv_cc, cv_cr;
  round_e    cv_rd;
  int        cv_pc_gap;      // exponent(product) - exponent(c)
  int        cv_cancel_bits; // max operand exponent - result exponent
  bit        cv_effsub, cv_finite, cv_tiny, cv_ovf, cv_zero_exact;

  covergroup cg_fma;
    option.per_instance = 1;
    cp_a: coverpoint cv_ca;
    cp_b: coverpoint cv_cb;
    cp_c: coverpoint cv_cc;
    x_abc: cross cp_a, cp_b, cp_c;
    cp_res: coverpoint cv_cr;
    cp_round: coverpoint cv_rd iff (cv_finite);
    // where the addend sits relative to the product (alignment shift range)
    cp_gap: coverpoint cv_pc_gap iff (cv_finite) {
      bins c_dominates = {[$:-26]};
      bins c_larger    = {[-25:-2]};
      bins close       = {[-1:1]};
      bins p_larger    = {[2:48]};
      bins p_dominates = {[49:$]};
    }
    cp_effsub: coverpoint cv_effsub iff (cv_finite);
    x_gap_effsub: cross cp_gap, cp_effsub;
    x_effsub_round: cross cp_effsub, cp_round;
    // massive cancellation: result exponent far below the operands'
    cp_cancel: coverpoint cv_cancel_bits iff (cv_finite && cv_effsub && !cv_zero_exact) {
      bins none = {[$:1]}; bins some = {[2:23]}; bins massive = {[24:$]};
    }
    cp_zero:  coverpoint cv_zero_exact iff (cv_finite) { bins exact_zero = {1}; }
    cp_tiny:  coverpoint cv_tiny  { bins tiny = {1}; }
    cp_ovf:   coverpoint cv_ovf   { bins overflow = {1}; }
  endgroup
  cg_fma cov = new();

  function automatic int exp_unb(int unsigned x);
    int e = int'(fp_exp(FP32, x));
    return e == 0 ? 1 : e;
  endfunction

  // ---------------------------------------------------------- scoreboard
  check_stats st_fx   = new("FXP_FMA");
  check_stats st_fma0 = new("FLP_FMA");
  check_stats st_fma4 = new("FLP_FMA_4");

  logic [31:0] h_a[HIST], h_b[HIST], h_c[HIST], h_r[HIST];

  task automatic check_pipe(check_stats st, int lat, longint t, logic [31:0] dut);
    longint src = t - (lat < 1 ? 1 : lat);
    int k;
    if (src < 0) return;
    k = int'(src % HIST);
    st.check(fp_same(FP32, dut, h_r[k]),
             $sformatf("vec %0d: %h * %h + %h -> dut %h ref %h", src, h_a[k], h_b[k], h_c[k], dut, h_r[k]));
  endtask

  // ---------------------------------------------------------- stimulus
  int unsigned corners[$];
  initial begin
    int unsigned base[] = '{32'h0000_0000, 32'h0000_0001, 32'h007F_FFFF, 32'h0080_0000,
                            32'h3F80_0000, 32'h3F80_0001, 32'h7F7F_FFFF, 32'h7F80_0000,
                            32'h7FC0_0000, 32'h7F80_0001, 32'h3400_0000};
    foreach (base[i]) begin corners.push_back(base[i]); corners.push_back(base[i] | 32'h8000_0000); end
  end

  task automatic next_operands(output logic [31:0] x, output logic [31:0] y, output logic [31:0] z);
    int s = $urandom_range(0, 99);
    int fl;
    x = rand_any(FP32); y = rand_any(FP32); z = rand_any(FP32);
    if (s < 35) return;                                         // independent
    if (s < 55) begin                                           // c ~ -(a*b): cancellation
      x = rand_any(FP32, 0); y = rand_any(FP32, 0);
      z = fpref_mul(FP32, x, y, MODE_IEEE, fl) ^ 32'h8000_0000;
      case ($urandom_range(0, 3))
        0: ;                                                    // exact cancellation
        1: z = z + $urandom_range(1, 4);                        // a few ULPs off
        2: z = z - $urandom_range(1, 4);
        default: z = z ^ (1 << $urandom_range(0, 22));
      endcase
      return;
    end
    if (s < 75) begin                                           // controlled product/addend gap
      int ep;
      x = rand_any(FP32, 0); y = rand_any(FP32, 0);
      ep = exp_unb(x) + exp_unb(y) - 127 + $urandom_range(0, 1);
      ep = ep + ($urandom_range(0, 3) == 0 ? $urandom_range(0, 4) - 2 : $urandom_range(0, 100) - 50);
      if (ep < 0) ep = 0;
      if (ep > 254) ep = 254;
      z = fp_pack(FP32, $urandom_range(0, 1), ep, rand_mant(FP32));
      return;
    end
    if (s < 87) begin                                           // product on a tie, tiny addend
      int k = $urandom_range(0, 40) - 20;
      x = fp_pack(FP32, $urandom_range(0, 1), 127 + k, 23'h40_0000);       // 1.5 * 2^k
      y = fp_pack(FP32, $urandom_range(0, 1), 127 - k, ($urandom & 23'h7F_FFFE) | 23'h1);
      z = $urandom_range(0, 1) ? fp_pack(FP32, $urandom_range(0, 1), 0, $urandom_range(1, 8))
                               : fp_pack(FP32, $urandom_range(0, 1), 127 - 60 - $urandom_range(0, 30), rand_mant(FP32));
      return;
    end
    // tiny results: subnormal range and the normal/subnormal boundary
    x = fp_pack(FP32, $urandom_range(0, 1), $urandom_range(1, 70), rand_mant(FP32));
    y = fp_pack(FP32, $urandom_range(0, 1), $urandom_range(1, 70), rand_mant(FP32));
    if (fp_exp(FP32, x) + fp_exp(FP32, y) > 140) y = fp_pack(FP32, y[31], 1, rand_mant(FP32));
    z = $urandom_range(0, 1) ? rand_fp(FP32, G_SUB) : rand_fp(FP32, G_TINY);
  endtask

  task automatic next_fxp(output logic [31:0] x, output logic [31:0] y, output logic [31:0] z);
    case ($urandom_range(0, 4))
      0: begin x = $urandom; y = $urandom; z = $urandom; end
      1: begin x = 32'h8000_0000; y = 32'h8000_0000; z = $urandom; end      // most positive product
      2: begin x = 32'h7FFF_FFFF; y = 32'h8000_0000; z = 32'h8000_0000; end
      3: begin x = $urandom_range(0, 1 << 16); y = $urandom_range(0, 1 << 16); z = 32'hFFFF_FFFF - $urandom_range(0, 3); end
      default: begin x = -$urandom_range(1, 1 << 16); y = $urandom_range(1, 1 << 16); z = $urandom; end
    endcase
  endtask

  int unsigned num = 200000;
  longint t = 0;

  initial begin
    int fl;
    int unsigned r;
    logic [31:0] x, y, z, fx, fy, fz;
    logic [63:0] fx_full;
    longint n_dir, n_total;
    bit fail;

    if ($value$plusargs("NUM=%d", num)) ;
    a = '0; b = '0; c = '0; fx_a = '0; fx_b = '0; fx_c = '0;
    repeat (3) @(negedge clk);
    rst = 1'b0;

    n_dir = corners.size() * corners.size() * corners.size();
    n_total = n_dir + num;
    for (longint i = 0; i < n_total + 10; i++) begin
      @(negedge clk);
      fx_full = longint'($signed(fx_a)) * longint'($signed(fx_b)) + longint'($signed(fx_c));
      st_fx.check(d_fx == fx_full[63:32], $sformatf("%h*%h+%h -> dut %h ref %h", fx_a, fx_b, fx_c, d_fx, fx_full[63:32]));
      if (i > 0) begin
        check_pipe(st_fma0, 0, t, d_fma0);
        check_pipe(st_fma4, LAT_FMA4, t, d_fma4);
      end

      if (i < n_dir) begin
        x = corners[i / (corners.size() * corners.size())];
        y = corners[(i / corners.size()) % corners.size()];
        z = corners[i % corners.size()];
      end else next_operands(x, y, z);
      next_fxp(fx, fy, fz);
      a = x; b = y; c = z; fx_a = fx; fx_b = fy; fx_c = fz;

      r = fpref_fma(FP32, x, y, z, MODE_IEEE, fl);
      h_a[t % HIST] = x; h_b[t % HIST] = y; h_c[t % HIST] = z; h_r[t % HIST] = r;

      cv_ca = fp_class(FP32, x); cv_cb = fp_class(FP32, y); cv_cc = fp_class(FP32, z);
      cv_cr = fp_class(FP32, r);
      cv_finite = cv_ca inside {CL_SUB, CL_NORM} && cv_cb inside {CL_SUB, CL_NORM} && cv_cc inside {CL_SUB, CL_NORM};
      cv_rd = round_kind(fl, r);
      cv_pc_gap = (exp_unb(x) + exp_unb(y) - 127) - exp_unb(z);
      cv_effsub = x[31] ^ y[31] ^ z[31];
      cv_cancel_bits = ((exp_unb(x) + exp_unb(y) - 127) > exp_unb(z) ? (exp_unb(x) + exp_unb(y) - 127) : exp_unb(z)) - exp_unb(r);
      cv_tiny = (fl & F_TINY) != 0; cv_ovf = (fl & F_OVERFLOW) != 0;
      cv_zero_exact = (fl & F_EXACT_ZERO) != 0;
      cov.sample();
      t++;
    end

    $display("\n================ project 05 results ================");
    st_fx.report(); st_fma0.report(); st_fma4.report();
    $display("COVERAGE cg_fma   %0.2f", cov.get_inst_coverage());
    $display("  %-18s failures=%0d  %s", "SVA", sva_errors, sva_errors == 0 ? "PASS" : "FAIL");
    fail = !(st_fx.passed() && st_fma0.passed() && st_fma4.passed()) || sva_errors != 0;
    if (fail) $fatal(1, "TEST FAILED");
    $display("TEST PASSED");
    $finish;
  end
endmodule
