// ============================================================================
// 4-階段流水線浮點數融合乘加運算器 (Pipelined FLP FMA)
// Function: R = A × B + C (4-stage pipeline)
// Standard: Pure Verilog-2001 (IEEE 1364-2001)
// 
// Pipeline Stages:
//   Stage 1: Unpack + Multiply + Alignment
//   Stage 2: Fixed-point Addition
//   Stage 3: Normalization
//   Stage 4: Rounding + Pack
// 
// Latency: 4 cycles
// Throughput: 1 result per cycle (after pipeline filled)
// ============================================================================

`timescale 1ns/1ps

module FLP_FMA_4 (
    input         clk,      // 時鐘信號
    input         rst,      // 同步重置（高電位有效）
    input  [31:0] a,        // 被乘數 A
    input  [31:0] b,        // 乘數 B
    input  [31:0] c,        // 加數 C
    output [31:0] d         // 輸出結果 D = A×B + C
);

  // ========================================================================
  // 參數定義
  // ========================================================================
  parameter W = 80;         // 內部計算寬度

  // ========================================================================
  // STAGE 1: Unpack + Multiply + Alignment
  // 功能：
  //   1. 拆解 IEEE-754 格式
  //   2. 檢測特殊值
  //   3. 執行乘法 Ma × Mb
  //   4. 對齊 P 和 C
  // ========================================================================

  // ------------------------------------------------------------------------
  // Stage 1 組合邏輯
  // ------------------------------------------------------------------------
  
  // 輸入拆解
  wire        sa, sb, sc;
  wire [7:0]  ea, eb, ec;
  wire [22:0] ma, mb, mc;

  assign {sa, ea, ma} = a;
  assign {sb, eb, mb} = b;
  assign {sc, ec, mc} = c;

  // 特殊值檢測
  wire s1_a_zero, s1_b_zero, s1_c_zero;
  wire s1_a_inf,  s1_b_inf,  s1_c_inf;
  wire s1_a_nan,  s1_b_nan,  s1_c_nan;

  assign s1_a_zero = (ea == 8'd0)   && (ma == 23'd0);
  assign s1_b_zero = (eb == 8'd0)   && (mb == 23'd0);
  assign s1_c_zero = (ec == 8'd0)   && (mc == 23'd0);
  
  assign s1_a_inf  = (ea == 8'd255) && (ma == 23'd0);
  assign s1_b_inf  = (eb == 8'd255) && (mb == 23'd0);
  assign s1_c_inf  = (ec == 8'd255) && (mc == 23'd0);
  
  assign s1_a_nan  = (ea == 8'd255) && (ma != 23'd0);
  assign s1_b_nan  = (eb == 8'd255) && (mb != 23'd0);
  assign s1_c_nan  = (ec == 8'd255) && (mc != 23'd0);

  // 加隱藏位
  wire [23:0] s1_Ma, s1_Mb, s1_Mc;

  assign s1_Ma = (ea == 8'd0) ? {1'b0, ma} : {1'b1, ma};
  assign s1_Mb = (eb == 8'd0) ? {1'b0, mb} : {1'b1, mb};
  assign s1_Mc = (ec == 8'd0) ? {1'b0, mc} : {1'b1, mc};

  // 指數處理
  wire [8:0] s1_ea_eff, s1_eb_eff, s1_ec_eff;
  wire signed [10:0] s1_ea_unb, s1_eb_unb, s1_ec_unb;

  assign s1_ea_eff = (ea == 8'd0) ? 9'd1 : {1'b0, ea};
  assign s1_eb_eff = (eb == 8'd0) ? 9'd1 : {1'b0, eb};
  assign s1_ec_eff = (ec == 8'd0) ? 9'd1 : {1'b0, ec};

  assign s1_ea_unb = $signed({2'b00, s1_ea_eff}) - 11'sd127;
  assign s1_eb_unb = $signed({2'b00, s1_eb_eff}) - 11'sd127;
  assign s1_ec_unb = $signed({2'b00, s1_ec_eff}) - 11'sd127;

  // 乘法
  wire s1_sp;
  wire [47:0] s1_Mp;
  wire signed [10:0] s1_ep_unb;

  assign s1_sp = sa ^ sb;
  assign s1_Mp = s1_Ma * s1_Mb;
  assign s1_ep_unb = s1_ea_unb + s1_eb_unb;

  // 對齊
  wire [W-1:0] s1_Pq_raw, s1_Cq_raw;
  wire signed [10:0] s1_diff_signed;
  wire s1_use_ep;
  wire [10:0] s1_diff_abs;
  wire [6:0] s1_diff_clamped;
  wire signed [10:0] s1_eq_unb;

  assign s1_Pq_raw = {{(W-48){1'b0}}, s1_Mp};
  assign s1_Cq_raw = {{(W-47){1'b0}}, s1_Mc, 23'b0};

  assign s1_diff_signed = s1_ep_unb - s1_ec_unb;
  assign s1_use_ep = (s1_diff_signed >= 11'sd0);
  assign s1_diff_abs = (s1_diff_signed[10]) ? (-s1_diff_signed) : s1_diff_signed;
  assign s1_diff_clamped = (s1_diff_abs > W) ? W[6:0] : s1_diff_abs[6:0];
  assign s1_eq_unb = s1_use_ep ? s1_ep_unb : s1_ec_unb;

  // Sticky 右移函數（與原版相同）
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

  wire [W-1:0] s1_Pq_aln, s1_Cq_aln;

  assign s1_Pq_aln = s1_use_ep ? s1_Pq_raw : shr_sticky(s1_Pq_raw, s1_diff_clamped);
  assign s1_Cq_aln = s1_use_ep ? shr_sticky(s1_Cq_raw, s1_diff_clamped) : s1_Cq_raw;

  // ------------------------------------------------------------------------
  // Stage 1 → Stage 2 Pipeline Registers
  // ------------------------------------------------------------------------
  reg [W-1:0] r_Pq_aln, r_Cq_aln;
  reg r_sp, r_sc;
  reg signed [10:0] r_eq_unb;
  
  // 特殊值標誌傳遞
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
      r_sc      <= sc;
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
  // STAGE 2: Fixed-point Addition
  // 功能：
  //   1. 二補數加法
  //   2. 溢位處理
  // ========================================================================

  // ------------------------------------------------------------------------
  // Stage 2 組合邏輯
  // ------------------------------------------------------------------------

  // 二補數加法
  wire signed [W:0] s2_p_2c, s2_c_2c, s2_sum_2c;

  assign s2_p_2c = r_sp ? (-$signed({1'b0, r_Pq_aln})) : $signed({1'b0, r_Pq_aln});
  assign s2_c_2c = r_sc ? (-$signed({1'b0, r_Cq_aln})) : $signed({1'b0, r_Cq_aln});
  assign s2_sum_2c = s2_p_2c + s2_c_2c;

  // 提取符號和絕對值
  wire s2_res_sign_raw;
  wire [W:0] s2_sum_abs_wide;

  assign s2_res_sign_raw = s2_sum_2c[W];
  assign s2_sum_abs_wide = s2_res_sign_raw ? (-s2_sum_2c) : s2_sum_2c;

  // 溢位處理
  wire s2_add_path;
  wire s2_add_overflow;
  reg [W-1:0] s2_sum_abs;
  reg signed [10:0] s2_eq_adj;

  assign s2_add_path = (r_sp == r_sc);
  assign s2_add_overflow = s2_add_path && s2_sum_abs_wide[W];
  
  always @* begin
    if (s2_add_overflow) begin
      s2_sum_abs = {s2_sum_abs_wide[W:2], (s2_sum_abs_wide[1] | s2_sum_abs_wide[0])};
      s2_eq_adj = r_eq_unb + 11'sd1;
    end else begin
      s2_sum_abs = s2_sum_abs_wide[W-1:0];
      s2_eq_adj = r_eq_unb;
    end
  end

  // 零值檢測
  wire s2_mag_zero;
  wire s2_res_sign;

  assign s2_mag_zero = (s2_sum_abs == {W{1'b0}});
  assign s2_res_sign = s2_mag_zero ? 1'b0 : s2_res_sign_raw;

  // ------------------------------------------------------------------------
  // Stage 2 → Stage 3 Pipeline Registers
  // ------------------------------------------------------------------------
  reg [W-1:0] r2_sum_abs;
  reg signed [10:0] r2_eq_adj;
  reg r2_res_sign;
  reg r2_mag_zero;
  
  // 特殊值標誌傳遞
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
  // STAGE 3: Normalization
  // 功能：
  //   1. 找到最高有效位 (MSB)
  //   2. 執行歸一化移位
  //   3. 調整指數
  // ========================================================================

  // ------------------------------------------------------------------------
  // Stage 3 組合邏輯
  // ------------------------------------------------------------------------

  // 找 MSB 函數（與原版相同）
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

  wire [6:0] s3_msb_pos;
  wire signed [7:0] s3_shift_amt;

  assign s3_msb_pos = find_msb(r2_sum_abs);
  assign s3_shift_amt = $signed({1'b0, s3_msb_pos}) - $signed(8'd46);

  // 歸一化移位
  reg [W-1:0] s3_sum_norm;
  
  always @* begin
    if (s3_shift_amt > 0) begin
      s3_sum_norm = shr_sticky(r2_sum_abs, s3_shift_amt[6:0]);
    end else if (s3_shift_amt < 0) begin
      s3_sum_norm = r2_sum_abs << (-s3_shift_amt);
    end else begin
      s3_sum_norm = r2_sum_abs;
    end
  end

  // 調整指數
  wire signed [10:0] s3_exp_norm_unb;

  assign s3_exp_norm_unb = r2_eq_adj + $signed({{4{s3_shift_amt[7]}}, s3_shift_amt[6:0]});

  // ------------------------------------------------------------------------
  // Stage 3 → Stage 4 Pipeline Registers
  // ------------------------------------------------------------------------
  reg [W-1:0] r3_sum_norm;
  reg signed [10:0] r3_exp_norm_unb;
  reg r3_res_sign;
  reg r3_mag_zero;
  
  // 特殊值標誌傳遞
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
  // STAGE 4: Rounding + Pack
  // 功能：
  //   1. 提取 GRS 捨入位
  //   2. 執行 Round-to-Nearest-Even
  //   3. 特殊值處理
  //   4. 輸出封裝
  // ========================================================================

  // ------------------------------------------------------------------------
  // Stage 4 組合邏輯
  // ------------------------------------------------------------------------

  // 捨入
  wire [23:0] s4_mant_raw;
  wire s4_g, s4_r, s4_s;
  wire s4_round_up;
  wire [24:0] s4_mant_rounded;
  wire s4_round_carry;
  wire [22:0] s4_frac_final;
  wire signed [10:0] s4_exp_final_unb;

  assign s4_mant_raw = r3_sum_norm[46:23];
  assign s4_g = r3_sum_norm[22];
  assign s4_r = r3_sum_norm[21];
  assign s4_s = |r3_sum_norm[20:0];
  assign s4_round_up = s4_g && (s4_r || s4_s || s4_mant_raw[0]);
  assign s4_mant_rounded = {1'b0, s4_mant_raw} + {24'd0, s4_round_up};
  assign s4_round_carry = s4_mant_rounded[24];
  assign s4_frac_final = s4_round_carry ? s4_mant_rounded[23:1] : s4_mant_rounded[22:0];
  assign s4_exp_final_unb = r3_exp_norm_unb + {10'd0, s4_round_carry};

  // 特殊情況
  wire s4_indet_mul, s4_inf_cancel, s4_any_nan;
  wire s4_p_inf, s4_any_inf;
  wire s4_overflow, s4_underflow, s4_subnormal;

  assign s4_indet_mul = (r3_a_inf && r3_b_zero) || (r3_a_zero && r3_b_inf);
  assign s4_inf_cancel = ((r3_a_inf || r3_b_inf) && r3_c_inf && (r3_sp != r3_sc));
  assign s4_any_nan = r3_a_nan || r3_b_nan || r3_c_nan || s4_indet_mul || s4_inf_cancel;
  assign s4_p_inf = r3_a_inf || r3_b_inf;
  assign s4_any_inf = s4_p_inf || r3_c_inf;
  assign s4_overflow  = (s4_exp_final_unb > 11'sd127);
  assign s4_underflow = (s4_exp_final_unb < -11'sd149);
  assign s4_subnormal = (!s4_overflow && !s4_underflow && (s4_exp_final_unb < -11'sd126));

  // 次正規數處理
  wire signed [11:0] s4_sub_shift_calc;
  wire [7:0] s4_sub_shift;
  wire [24:0] s4_sub_mant;

  assign s4_sub_shift_calc = -11'sd126 - s4_exp_final_unb;
  assign s4_sub_shift = s4_subnormal ? s4_sub_shift_calc[7:0] : 8'd0;
  assign s4_sub_mant = ({1'b1, s4_frac_final} >> s4_sub_shift);

  // 輸出封裝
  reg        s4_sign_out;
  reg [7:0]  s4_exp_out;
  reg [22:0] s4_frac_out;

  always @* begin
    if (s4_any_nan) begin
      s4_sign_out = 1'b0;
      s4_exp_out  = 8'd255;
      s4_frac_out = 23'h400000;
    end else if (r3_mag_zero || (r3_a_zero && r3_b_zero)) begin
      s4_sign_out = 1'b0;
      s4_exp_out  = 8'd0;
      s4_frac_out = 23'd0;
    end else if (s4_any_inf) begin
      if (r3_c_inf && !s4_p_inf) begin
        s4_sign_out = r3_sc;
      end else begin
        s4_sign_out = r3_sp;
      end
      s4_exp_out  = 8'd255;
      s4_frac_out = 23'd0;
    end else if (s4_overflow) begin
      s4_sign_out = r3_res_sign;
      s4_exp_out  = 8'd255;
      s4_frac_out = 23'd0;
    end else if (s4_underflow) begin
      s4_sign_out = r3_res_sign;
      s4_exp_out  = 8'd0;
      s4_frac_out = 23'd0;
    end else if (s4_subnormal) begin
      s4_sign_out = r3_res_sign;
      s4_exp_out  = 8'd0;
      s4_frac_out = s4_sub_mant[22:0];
    end else begin
      s4_sign_out = r3_res_sign;
      s4_exp_out  = s4_exp_final_unb[7:0] + 8'd127;
      s4_frac_out = s4_frac_final;
    end
  end

  // ------------------------------------------------------------------------
  // 最終輸出寄存器（可選，用於改善時序）
  // ------------------------------------------------------------------------
  reg [31:0] r4_output;

  always @(posedge clk) begin
    if (rst) begin
      r4_output <= 32'd0;
    end else begin
      r4_output <= {s4_sign_out, s4_exp_out, s4_frac_out};
    end
  end

  assign d = r4_output;

endmodule
