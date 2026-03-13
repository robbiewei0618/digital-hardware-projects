// ============================================================================
// 4-階段流水線浮點數融合乘加運算器 - 模組化版本
// Function: d = a × b + c (4-stage pipeline)
// ============================================================================

`timescale 1ns/1ps

module FLP_FMA_4 (
    input         clk,
    input         rst,
    input  [31:0] a,
    input  [31:0] b,
    input  [31:0] c,
    output [31:0] d
);

  parameter W = 80;

  // ========================================================================
  // Stage 1 信號
  // ========================================================================
  wire [W-1:0] s1_Pq_aln, s1_Cq_aln;
  wire s1_sp, s1_sc;
  wire signed [10:0] s1_eq_unb;
  wire s1_a_zero, s1_b_zero, s1_c_zero;
  wire s1_a_inf,  s1_b_inf,  s1_c_inf;
  wire s1_a_nan,  s1_b_nan,  s1_c_nan;

  // Stage 1 實例化
  stage1 u_stage1 (
    .a(a), .b(b), .c(c),
    .s1_Pq_aln(s1_Pq_aln),
    .s1_Cq_aln(s1_Cq_aln),
    .s1_sp(s1_sp),
    .s1_sc(s1_sc),
    .s1_eq_unb(s1_eq_unb),
    .s1_a_zero(s1_a_zero), .s1_b_zero(s1_b_zero), .s1_c_zero(s1_c_zero),
    .s1_a_inf(s1_a_inf),   .s1_b_inf(s1_b_inf),   .s1_c_inf(s1_c_inf),
    .s1_a_nan(s1_a_nan),   .s1_b_nan(s1_b_nan),   .s1_c_nan(s1_c_nan)
  );

  // ========================================================================
  // Stage 1 → Stage 2 Pipeline Registers
  // ========================================================================
  reg [W-1:0] r_Pq_aln, r_Cq_aln;
  reg r_sp, r_sc;
  reg signed [10:0] r_eq_unb;
  reg r_a_zero, r_b_zero, r_c_zero;
  reg r_a_inf,  r_b_inf,  r_c_inf;
  reg r_a_nan,  r_b_nan,  r_c_nan;

  always @(posedge clk) begin
    if (rst) begin
      r_Pq_aln  <= {W{1'b0}};
      r_Cq_aln  <= {W{1'b0}};
      r_sp      <= 1'b0;
      r_sc      <= 1'b0;
      r_eq_unb  <= 11'sd0;
      r_a_zero  <= 1'b0;
      r_b_zero  <= 1'b0;
      r_c_zero  <= 1'b0;
      r_a_inf   <= 1'b0;
      r_b_inf   <= 1'b0;
      r_c_inf   <= 1'b0;
      r_a_nan   <= 1'b0;
      r_b_nan   <= 1'b0;
      r_c_nan   <= 1'b0;
    end else begin
      r_Pq_aln  <= s1_Pq_aln;
      r_Cq_aln  <= s1_Cq_aln;
      r_sp      <= s1_sp;
      r_sc      <= s1_sc;
      r_eq_unb  <= s1_eq_unb;
      r_a_zero  <= s1_a_zero;
      r_b_zero  <= s1_b_zero;
      r_c_zero  <= s1_c_zero;
      r_a_inf   <= s1_a_inf;
      r_b_inf   <= s1_b_inf;
      r_c_inf   <= s1_c_inf;
      r_a_nan   <= s1_a_nan;
      r_b_nan   <= s1_b_nan;
      r_c_nan   <= s1_c_nan;
    end
  end

  // ========================================================================
  // Stage 2 信號
  // ========================================================================
  wire [W-1:0] s2_sum_abs;
  wire signed [10:0] s2_eq_adj;
  wire s2_res_sign;
  wire s2_mag_zero;

  // Stage 2 實例化
  stage2 u_stage2 (
    .r_Pq_aln(r_Pq_aln),
    .r_Cq_aln(r_Cq_aln),
    .r_sp(r_sp),
    .r_sc(r_sc),
    .r_eq_unb(r_eq_unb),
    .s2_sum_abs(s2_sum_abs),
    .s2_eq_adj(s2_eq_adj),
    .s2_res_sign(s2_res_sign),
    .s2_mag_zero(s2_mag_zero)
  );

  // ========================================================================
  // Stage 2 → Stage 3 Pipeline Registers
  // ========================================================================
  reg [W-1:0] r2_sum_abs;
  reg signed [10:0] r2_eq_adj;
  reg r2_res_sign;
  reg r2_mag_zero;
  reg r2_a_zero, r2_b_zero, r2_c_zero;
  reg r2_a_inf,  r2_b_inf,  r2_c_inf;
  reg r2_a_nan,  r2_b_nan,  r2_c_nan;
  reg r2_sp;

  always @(posedge clk) begin
    if (rst) begin
      r2_sum_abs <= {W{1'b0}};
      r2_eq_adj  <= 11'sd0;
      r2_res_sign<= 1'b0;
      r2_mag_zero<= 1'b0;
      r2_a_zero  <= 1'b0;
      r2_b_zero  <= 1'b0;
      r2_c_zero  <= 1'b0;
      r2_a_inf   <= 1'b0;
      r2_b_inf   <= 1'b0;
      r2_c_inf   <= 1'b0;
      r2_a_nan   <= 1'b0;
      r2_b_nan   <= 1'b0;
      r2_c_nan   <= 1'b0;
      r2_sp      <= 1'b0;
    end else begin
      r2_sum_abs <= s2_sum_abs;
      r2_eq_adj  <= s2_eq_adj;
      r2_res_sign<= s2_res_sign;
      r2_mag_zero<= s2_mag_zero;
      r2_a_zero  <= r_a_zero;
      r2_b_zero  <= r_b_zero;
      r2_c_zero  <= r_c_zero;
      r2_a_inf   <= r_a_inf;
      r2_b_inf   <= r_b_inf;
      r2_c_inf   <= r_c_inf;
      r2_a_nan   <= r_a_nan;
      r2_b_nan   <= r_b_nan;
      r2_c_nan   <= r_c_nan;
      r2_sp      <= r_sp;
    end
  end

  // ========================================================================
  // Stage 3 信號
  // ========================================================================
  wire [W-1:0] s3_sum_norm;
  wire signed [10:0] s3_exp_norm_unb;

  // Stage 3 實例化
  stage3 u_stage3 (
    .r2_sum_abs(r2_sum_abs),
    .r2_eq_adj(r2_eq_adj),
    .s3_sum_norm(s3_sum_norm),
    .s3_exp_norm_unb(s3_exp_norm_unb)
  );

  // ========================================================================
  // Stage 3 → Stage 4 Pipeline Registers
  // ========================================================================
  reg [W-1:0] r3_sum_norm;
  reg signed [10:0] r3_exp_norm_unb;
  reg r3_res_sign;
  reg r3_mag_zero;
  reg r3_a_zero, r3_b_zero, r3_c_zero;
  reg r3_a_inf,  r3_b_inf,  r3_c_inf;
  reg r3_a_nan,  r3_b_nan,  r3_c_nan;
  reg r3_sp, r3_sc;

  always @(posedge clk) begin
    if (rst) begin
      r3_sum_norm    <= {W{1'b0}};
      r3_exp_norm_unb<= 11'sd0;
      r3_res_sign    <= 1'b0;
      r3_mag_zero    <= 1'b0;
      r3_a_zero      <= 1'b0;
      r3_b_zero      <= 1'b0;
      r3_c_zero      <= 1'b0;
      r3_a_inf       <= 1'b0;
      r3_b_inf       <= 1'b0;
      r3_c_inf       <= 1'b0;
      r3_a_nan       <= 1'b0;
      r3_b_nan       <= 1'b0;
      r3_c_nan       <= 1'b0;
      r3_sp          <= 1'b0;
      r3_sc          <= 1'b0;
    end else begin
      r3_sum_norm    <= s3_sum_norm;
      r3_exp_norm_unb<= s3_exp_norm_unb;
      r3_res_sign    <= r2_res_sign;
      r3_mag_zero    <= r2_mag_zero;
      r3_a_zero      <= r2_a_zero;
      r3_b_zero      <= r2_b_zero;
      r3_c_zero      <= r2_c_zero;
      r3_a_inf       <= r2_a_inf;
      r3_b_inf       <= r2_b_inf;
      r3_c_inf       <= r2_c_inf;
      r3_a_nan       <= r2_a_nan;
      r3_b_nan       <= r2_b_nan;
      r3_c_nan       <= r2_c_nan;
      r3_sp          <= r2_sp;
      r3_sc          <= r_sc;
    end
  end

  // ========================================================================
  // Stage 4 信號
  // ========================================================================
  wire [31:0] s4_result;

  // Stage 4 實例化
  stage4 u_stage4 (
    .r3_sum_norm(r3_sum_norm),
    .r3_exp_norm_unb(r3_exp_norm_unb),
    .r3_res_sign(r3_res_sign),
    .r3_mag_zero(r3_mag_zero),
    .r3_a_zero(r3_a_zero), .r3_b_zero(r3_b_zero), .r3_c_zero(r3_c_zero),
    .r3_a_inf(r3_a_inf),   .r3_b_inf(r3_b_inf),   .r3_c_inf(r3_c_inf),
    .r3_a_nan(r3_a_nan),   .r3_b_nan(r3_b_nan),   .r3_c_nan(r3_c_nan),
    .r3_sp(r3_sp), .r3_sc(r3_sc),
    .s4_result(s4_result)
  );

  // ========================================================================
  // 最終輸出寄存器
  // ========================================================================
  reg [31:0] r4_output;

  always @(posedge clk) begin
    if (rst) begin
      r4_output <= 32'd0;
    end else begin
      r4_output <= s4_result;
    end
  end

  assign d = r4_output;

endmodule

// ============================================================================
// Stage 1: Unpack + Multiply + Alignment
// ============================================================================
module stage1 (
    input  [31:0] a,
    input  [31:0] b,
    input  [31:0] c,
    
    output [79:0] s1_Pq_aln,
    output [79:0] s1_Cq_aln,
    output        s1_sp,
    output        s1_sc,
    output signed [10:0] s1_eq_unb,
    
    // 特殊值標誌
    output s1_a_zero, s1_b_zero, s1_c_zero,
    output s1_a_inf,  s1_b_inf,  s1_c_inf,
    output s1_a_nan,  s1_b_nan,  s1_c_nan
);

  parameter W = 80;

  // ------------------------------------------------------------------------
  // 輸入拆解
  // ------------------------------------------------------------------------
  wire        sa, sb, sc;
  wire [7:0]  ea, eb, ec;
  wire [22:0] ma, mb, mc;

  assign {sa, ea, ma} = a;
  assign {sb, eb, mb} = b;
  assign {sc, ec, mc} = c;

  // ------------------------------------------------------------------------
  // 特殊值檢測
  // ------------------------------------------------------------------------
  assign s1_a_zero = (ea == 8'd0)   && (ma == 23'd0);
  assign s1_b_zero = (eb == 8'd0)   && (mb == 23'd0);
  assign s1_c_zero = (ec == 8'd0)   && (mc == 23'd0);
  
  assign s1_a_inf  = (ea == 8'd255) && (ma == 23'd0);
  assign s1_b_inf  = (eb == 8'd255) && (mb == 23'd0);
  assign s1_c_inf  = (ec == 8'd255) && (mc == 23'd0);
  
  assign s1_a_nan  = (ea == 8'd255) && (ma != 23'd0);
  assign s1_b_nan  = (eb == 8'd255) && (mb != 23'd0);
  assign s1_c_nan  = (ec == 8'd255) && (mc != 23'd0);

  // ------------------------------------------------------------------------
  // 加隱藏位
  // ------------------------------------------------------------------------
  wire [23:0] Ma, Mb, Mc;

  assign Ma = (ea == 8'd0) ? {1'b0, ma} : {1'b1, ma};
  assign Mb = (eb == 8'd0) ? {1'b0, mb} : {1'b1, mb};
  assign Mc = (ec == 8'd0) ? {1'b0, mc} : {1'b1, mc};

  // ------------------------------------------------------------------------
  // 指數處理
  // ------------------------------------------------------------------------
  wire [8:0] ea_eff, eb_eff, ec_eff;
  wire signed [10:0] ea_unb, eb_unb, ec_unb;

  assign ea_eff = (ea == 8'd0) ? 9'd1 : {1'b0, ea};
  assign eb_eff = (eb == 8'd0) ? 9'd1 : {1'b0, eb};
  assign ec_eff = (ec == 8'd0) ? 9'd1 : {1'b0, ec};

  assign ea_unb = $signed({2'b00, ea_eff}) - 11'sd127;
  assign eb_unb = $signed({2'b00, eb_eff}) - 11'sd127;
  assign ec_unb = $signed({2'b00, ec_eff}) - 11'sd127;

  // ------------------------------------------------------------------------
  // 乘法
  // ------------------------------------------------------------------------
  wire [47:0] Mp;
  wire signed [10:0] ep_unb;

  assign s1_sp = sa ^ sb;
  assign Mp = Ma * Mb;
  assign ep_unb = ea_unb + eb_unb;

  // ------------------------------------------------------------------------
  // 對齊
  // ------------------------------------------------------------------------
  wire [W-1:0] Pq_raw, Cq_raw;
  wire signed [10:0] diff_signed;
  wire use_ep;
  wire [10:0] diff_abs;
  wire [6:0] diff_clamped;

  assign Pq_raw = {{(W-48){1'b0}}, Mp};
  assign Cq_raw = {{(W-47){1'b0}}, Mc, 23'b0};

  assign diff_signed = ep_unb - ec_unb;
  assign use_ep = (diff_signed >= 11'sd0);
  assign diff_abs = (diff_signed[10]) ? (-diff_signed) : diff_signed;
  assign diff_clamped = (diff_abs > W) ? W[6:0] : diff_abs[6:0];
  assign s1_eq_unb = use_ep ? ep_unb : ec_unb;

  // ------------------------------------------------------------------------
  // Sticky 右移函數
  // ------------------------------------------------------------------------
  function [W-1:0] shr_sticky;
    input [W-1:0] val;
    input [6:0]   shamt;
    reg [W-1:0]   shifted;
    reg           sticky;
    integer i;
    begin
      if (shamt == 0) begin
        shr_sticky = val;
      end else if (shamt >= W) begin
        sticky = 1'b0;
        for (i = 0; i < W; i = i + 1) begin
          sticky = sticky | val[i];
        end
        shr_sticky = {{(W-1){1'b0}}, sticky};
      end else begin
        sticky = 1'b0;
        for (i = 0; i < shamt; i = i + 1) begin
          sticky = sticky | val[i];
        end
        shifted = (val >> shamt);
        shr_sticky = shifted | {{(W-1){1'b0}}, sticky};
      end
    end
  endfunction

  // ------------------------------------------------------------------------
  // 執行對齊
  // ------------------------------------------------------------------------
  assign s1_Pq_aln = use_ep ? Pq_raw : shr_sticky(Pq_raw, diff_clamped);
  assign s1_Cq_aln = use_ep ? shr_sticky(Cq_raw, diff_clamped) : Cq_raw;
  assign s1_sc = sc;

endmodule

// ============================================================================
// Stage 2: Fixed-point Addition
// ============================================================================
module stage2 (
    input  [79:0] r_Pq_aln,
    input  [79:0] r_Cq_aln,
    input         r_sp,
    input         r_sc,
    input  signed [10:0] r_eq_unb,
    
    output [79:0] s2_sum_abs,
    output signed [10:0] s2_eq_adj,
    output        s2_res_sign,
    output        s2_mag_zero
);

  parameter W = 80;

  // ------------------------------------------------------------------------
  // 二補數加法
  // ------------------------------------------------------------------------
  wire signed [W:0] p_2c, c_2c, sum_2c;

  assign p_2c = r_sp ? (-$signed({1'b0, r_Pq_aln})) : $signed({1'b0, r_Pq_aln});
  assign c_2c = r_sc ? (-$signed({1'b0, r_Cq_aln})) : $signed({1'b0, r_Cq_aln});
  assign sum_2c = p_2c + c_2c;

  // ------------------------------------------------------------------------
  // 提取符號和絕對值
  // ------------------------------------------------------------------------
  wire res_sign_raw;
  wire [W:0] sum_abs_wide;

  assign res_sign_raw = sum_2c[W];
  assign sum_abs_wide = res_sign_raw ? (-sum_2c) : sum_2c;

  // ------------------------------------------------------------------------
  // 溢位處理
  // ------------------------------------------------------------------------
  wire add_path;
  wire add_overflow;
  reg [W-1:0] sum_abs_reg;
  reg signed [10:0] eq_adj_reg;

  assign add_path = (r_sp == r_sc);
  assign add_overflow = add_path && sum_abs_wide[W];
  
  always @* begin
    if (add_overflow) begin
      sum_abs_reg = {sum_abs_wide[W:2], (sum_abs_wide[1] | sum_abs_wide[0])};
      eq_adj_reg = r_eq_unb + 11'sd1;
    end else begin
      sum_abs_reg = sum_abs_wide[W-1:0];
      eq_adj_reg = r_eq_unb;
    end
  end

  assign s2_sum_abs = sum_abs_reg;
  assign s2_eq_adj = eq_adj_reg;

  // ------------------------------------------------------------------------
  // 零值檢測
  // ------------------------------------------------------------------------
  assign s2_mag_zero = (sum_abs_reg == {W{1'b0}});
  assign s2_res_sign = s2_mag_zero ? 1'b0 : res_sign_raw;

endmodule
// ============================================================================
// Stage 3: Normalization
// ============================================================================
module stage3 (
    input  [79:0] r2_sum_abs,
    input  signed [10:0] r2_eq_adj,
    
    output [79:0] s3_sum_norm,
    output signed [10:0] s3_exp_norm_unb
);

  parameter W = 80;

  // ------------------------------------------------------------------------
  // 找 MSB 函數
  // ------------------------------------------------------------------------
  function [6:0] find_msb;
    input [W-1:0] val;
    integer i;
    reg found;
    begin
      find_msb = 7'd0;
      found = 1'b0;
      for (i = W-1; i >= 0; i = i - 1) begin
        if (val[i] && !found) begin
          find_msb = i[6:0];
          found = 1'b1;
        end
      end
    end
  endfunction

  // ------------------------------------------------------------------------
  // Sticky 右移函數
  // ------------------------------------------------------------------------
  function [W-1:0] shr_sticky;
    input [W-1:0] val;
    input [6:0]   shamt;
    reg [W-1:0]   shifted;
    reg           sticky;
    integer i;
    begin
      if (shamt == 0) begin
        shr_sticky = val;
      end else if (shamt >= W) begin
        sticky = 1'b0;
        for (i = 0; i < W; i = i + 1) begin
          sticky = sticky | val[i];
        end
        shr_sticky = {{(W-1){1'b0}}, sticky};
      end else begin
        sticky = 1'b0;
        for (i = 0; i < shamt; i = i + 1) begin
          sticky = sticky | val[i];
        end
        shifted = (val >> shamt);
        shr_sticky = shifted | {{(W-1){1'b0}}, sticky};
      end
    end
  endfunction

  // ------------------------------------------------------------------------
  // 歸一化
  // ------------------------------------------------------------------------
  wire [6:0] msb_pos;
  wire signed [7:0] shift_amt;

  assign msb_pos = find_msb(r2_sum_abs);
  assign shift_amt = $signed({1'b0, msb_pos}) - $signed(8'd46);

  // 歸一化移位
  reg [W-1:0] sum_norm_reg;
  
  always @* begin
    if (shift_amt > 0) begin
      sum_norm_reg = shr_sticky(r2_sum_abs, shift_amt[6:0]);
    end else if (shift_amt < 0) begin
      sum_norm_reg = r2_sum_abs << (-shift_amt);
    end else begin
      sum_norm_reg = r2_sum_abs;
    end
  end

  assign s3_sum_norm = sum_norm_reg;

  // 調整指數
  assign s3_exp_norm_unb = r2_eq_adj + $signed({{4{shift_amt[7]}}, shift_amt[6:0]});

endmodule

// ============================================================================
// Stage 4: Rounding + Pack
// ============================================================================
module stage4 (
    input  [79:0] r3_sum_norm,
    input  signed [10:0] r3_exp_norm_unb,
    input         r3_res_sign,
    input         r3_mag_zero,
    
    // 特殊值標誌
    input r3_a_zero, r3_b_zero, r3_c_zero,
    input r3_a_inf,  r3_b_inf,  r3_c_inf,
    input r3_a_nan,  r3_b_nan,  r3_c_nan,
    input r3_sp, r3_sc,
    
    output [31:0] s4_result
);

  // ------------------------------------------------------------------------
  // 捨入
  // ------------------------------------------------------------------------
  wire [23:0] mant_raw;
  wire g, r, s;
  wire round_up;
  wire [24:0] mant_rounded;
  wire round_carry;
  wire [22:0] frac_final;
  wire signed [10:0] exp_final_unb;

  assign mant_raw = r3_sum_norm[46:23];
  assign g = r3_sum_norm[22];
  assign r = r3_sum_norm[21];
  assign s = |r3_sum_norm[20:0];
  assign round_up = g && (r || s || mant_raw[0]);
  assign mant_rounded = {1'b0, mant_raw} + {24'd0, round_up};
  assign round_carry = mant_rounded[24];
  assign frac_final = round_carry ? mant_rounded[23:1] : mant_rounded[22:0];
  assign exp_final_unb = r3_exp_norm_unb + {10'd0, round_carry};

  // ------------------------------------------------------------------------
  // 特殊情況
  // ------------------------------------------------------------------------
  wire indet_mul, inf_cancel, any_nan;
  wire p_inf, any_inf;
  wire overflow, underflow, subnormal;

  assign indet_mul = (r3_a_inf && r3_b_zero) || (r3_a_zero && r3_b_inf);
  assign inf_cancel = ((r3_a_inf || r3_b_inf) && r3_c_inf && (r3_sp != r3_sc));
  assign any_nan = r3_a_nan || r3_b_nan || r3_c_nan || indet_mul || inf_cancel;
  assign p_inf = r3_a_inf || r3_b_inf;
  assign any_inf = p_inf || r3_c_inf;
  assign overflow  = (exp_final_unb > 11'sd127);
  assign underflow = (exp_final_unb < -11'sd149);
  assign subnormal = (!overflow && !underflow && (exp_final_unb < -11'sd126));

  // ------------------------------------------------------------------------
  // 次正規數處理
  // ------------------------------------------------------------------------
  wire signed [11:0] sub_shift_calc;
  wire [7:0] sub_shift;
  wire [24:0] sub_mant;

  assign sub_shift_calc = -11'sd126 - exp_final_unb;
  assign sub_shift = subnormal ? sub_shift_calc[7:0] : 8'd0;
  assign sub_mant = ({1'b1, frac_final} >> sub_shift);

  // ------------------------------------------------------------------------
  // 輸出封裝
  // ------------------------------------------------------------------------
  reg        sign_out;
  reg [7:0]  exp_out;
  reg [22:0] frac_out;

  always @* begin
    if (any_nan) begin
      sign_out = 1'b0;
      exp_out  = 8'd255;
      frac_out = 23'h400000;
    end else if (r3_mag_zero || (r3_a_zero && r3_b_zero)) begin
      sign_out = 1'b0;
      exp_out  = 8'd0;
      frac_out = 23'd0;
    end else if (any_inf) begin
      if (r3_c_inf && !p_inf) begin
        sign_out = r3_sc;
      end else begin
        sign_out = r3_sp;
      end
      exp_out  = 8'd255;
      frac_out = 23'd0;
    end else if (overflow) begin
      sign_out = r3_res_sign;
      exp_out  = 8'd255;
      frac_out = 23'd0;
    end else if (underflow) begin
      sign_out = r3_res_sign;
      exp_out  = 8'd0;
      frac_out = 23'd0;
    end else if (subnormal) begin
      sign_out = r3_res_sign;
      exp_out  = 8'd0;
      frac_out = sub_mant[22:0];
    end else begin
      sign_out = r3_res_sign;
      exp_out  = exp_final_unb[7:0] + 8'd127;
      frac_out = frac_final;
    end
  end

  assign s4_result = {sign_out, exp_out, frac_out};

endmodule