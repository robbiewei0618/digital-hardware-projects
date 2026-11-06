// =============================================================================
// tb_top.sv - project 01: 32-bit adder in three modelling styles
//
//   combinational: adder_behavior, adder_dataflow, adder_structure, RCA_32bit
//   registered   : adder_behavior_reg, adder_dataflow_reg, adder_structure_reg
// Reference {co, s} = a + b + ci (33 bits). Registered versions: one cycle.
// Stimulus: corner operands plus random operands steered at long carry chains.
// SVA: the registered outputs equal last cycle's combinational sum.
// Coverage: longest carry-propagation run (0 .. 32 bits), carry-in, carry-out.
// =============================================================================
`timescale 1ns/1ps
module tb_top;
  logic clk = 0;
  always #5 clk = ~clk;
  logic [31:0] a, b;
  logic        ci;
  logic [31:0] s_beh, s_df, s_st, s_rca, s_beh_r, s_df_r, s_st_r;
  logic        c_beh, c_df, c_st, c_rca, c_beh_r, c_df_r, c_st_r;

  adder_behavior      u_beh   (.s(s_beh),   .co(c_beh),   .a, .b, .ci);
  adder_dataflow      u_df    (.s(s_df),    .co(c_df),    .a, .b, .ci);
  adder_structure     u_st    (.s(s_st),    .co(c_st),    .a, .b, .ci);
  RCA_32bit           u_rca   (.sum(s_rca), .c_out(c_rca), .a, .b, .c_in(ci));
  adder_behavior_reg  u_beh_r (.s(s_beh_r), .co(c_beh_r), .a, .b, .ci, .clk);
  adder_dataflow_reg  u_df_r  (.s(s_df_r),  .co(c_df_r),  .a, .b, .ci, .clk);
  adder_structure_reg u_st_r  (.s(s_st_r),  .co(c_st_r),  .a, .b, .ci, .clk);

  logic started = 0;
  int unsigned sva_errors = 0;
  wire [32:0] sum_now = {1'b0, a} + {1'b0, b} + {32'd0, ci};
  a_registered: assert property (@(posedge clk) started ##1 1 |->
                  {c_beh_r, s_beh_r} == $past(sum_now) && {c_df_r, s_df_r} == $past(sum_now) &&
                  {c_st_r, s_st_r} == $past(sum_now))
    else begin $error("[SVA] registered adder != previous sum"); sva_errors++; end

  // longest run of propagate bits (a ^ b) that a carry actually travels
  function automatic int carry_run(logic [31:0] x, logic [31:0] y, logic cin);
    int best = 0, cur = 0;
    logic c = cin;
    for (int i = 0; i < 32; i++) begin
      if (c && (x[i] ^ y[i])) cur++; else cur = 0;
      if (cur > best) best = cur;
      c = (x[i] & y[i]) | (c & (x[i] ^ y[i]));
    end
    return best;
  endfunction

  int cv_run; bit cv_ci, cv_co;
  covergroup cg_add;
    option.per_instance = 1;
    cp_run: coverpoint cv_run { bins none = {0}; bins short_ = {[1:7]}; bins mid = {[8:15]};
                                bins long_ = {[16:31]}; bins full = {32}; }
    cp_ci: coverpoint cv_ci;
    cp_co: coverpoint cv_co;
    // a carry that ripples through all 32 bits must come out: unreachable
    x_run_co: cross cp_run, cp_co { ignore_bins full_no_co = binsof(cp_run.full) && binsof(cp_co) intersect {0}; }
  endgroup
  cg_add cov = new();

  longint unsigned n_checks = 0, n_errors = 0;
  initial begin
    longint unsigned num = 200000;
    logic [31:0] x, y;
    logic [32:0] exp_v;
    void'($value$plusargs("NUM=%d", num));
    a = 0; b = 0; ci = 0;
    @(negedge clk); started = 1;
    for (longint i = 0; i < num; i++) begin
      case (i % 6)
        0: begin x = $urandom; y = $urandom; end
        1: begin x = $urandom; y = ~x; end                               // all propagate
        2: begin x = 32'hFFFF_FFFF << $urandom_range(0, 31); y = 32'h1 << $urandom_range(0, 31); end
        3: begin x = $urandom; y = ~x ^ (32'h1 << $urandom_range(0, 31)); end  // one generate/kill in the chain
        4: begin x = {$urandom_range(0, 1) ? 32'hFFFF_FFFF : 32'h0}; y = {31'd0, $urandom_range(0, 1)}; end
        default: begin x = $urandom & $urandom; y = $urandom | $urandom; end
      endcase
      a = x; b = y; ci = $urandom_range(0, 1);
      @(negedge clk);
      exp_v = {1'b0, x} + {1'b0, y} + {32'd0, ci};
      n_checks++;
      if ({c_beh, s_beh} != exp_v || {c_df, s_df} != exp_v || {c_st, s_st} != exp_v || {c_rca, s_rca} != exp_v) begin
        n_errors++;
        if (n_errors <= 8) $display("[MISMATCH] %h + %h + %0d: beh %h df %h st %h rca %h expected %h", x, y, ci,
                                    {c_beh, s_beh}, {c_df, s_df}, {c_st, s_st}, {c_rca, s_rca}, exp_v);
      end
      cv_run = carry_run(x, y, ci); cv_ci = ci; cv_co = exp_v[32];
      cov.sample();
    end
    $display("\n================ project 01 results ================");
    $display("  %-18s checks=%0d  errors=%0d  %s", "adders (7 DUTs)", n_checks, n_errors, n_errors == 0 ? "PASS" : "FAIL");
    $display("COVERAGE cg_add   %0.2f", cov.get_inst_coverage());
    $display("  %-18s failures=%0d  %s", "SVA", sva_errors, sva_errors == 0 ? "PASS" : "FAIL");
    if (n_errors != 0 || sva_errors != 0) $fatal(1, "TEST FAILED");
    $display("TEST PASSED");
    $finish;
  end
endmodule
