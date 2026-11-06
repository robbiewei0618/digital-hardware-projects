// ============================================================
// File   : FXP_mul.v
// Desc   : Signed fixed-point multiplier (combinational only)
// Format : Q(WIDTH-FRAC-1).FRAC  (two’s complement, signed)
// Features: round-to-nearest-ties-to-even (RNE) + saturation
// 
// ============================================================

module FXP_mul #(
  parameter integer WIDTH = 32,  // 總位寬
  parameter integer FRAC  = 16   // 小數位
)(
  input  wire signed [WIDTH-1:0] a,
  input  wire signed [WIDTH-1:0] b,
  output wire signed [WIDTH-1:0] d
);

  // ------------------------------------------------------------
  // 1. 乘法：得到 2*WIDTH 位結果
  // ------------------------------------------------------------
  wire signed [2*WIDTH-1:0] product_full = a * b;

  // ------------------------------------------------------------
  // 2. 四捨五入 (Round-to-Nearest, Ties-to-Even)
  // ------------------------------------------------------------
  // 保留高 WIDTH 位，右移 FRAC 位以回到原比例
  wire signed [WIDTH-1:0] keep = product_full >>> FRAC;

  // Guard bit = FRAC-1 位，Sticky = 其餘低位 OR
  wire guard  = (FRAC == 0) ? 1'b0 : product_full[FRAC-1];
  wire sticky = (FRAC <= 1) ? 1'b0 : (|product_full[FRAC-2:0]);
  wire lsb_keep = keep[0];

  // ties-to-even 規則
  wire round_up = guard & (sticky | lsb_keep);

  // 執行加一
  wire signed [WIDTH:0] keep_ext = {keep[WIDTH-1], keep};
  wire signed [WIDTH:0] rounded_ext = keep_ext + {{WIDTH{1'b0}}, round_up};
  wire signed [WIDTH-1:0] rounded = rounded_ext[WIDTH-1:0];

  // ------------------------------------------------------------
  // 3. 飽和處理 (Saturation)
  // ------------------------------------------------------------
  localparam signed [WIDTH-1:0] SAT_MAX =  {1'b0, {WIDTH-1{1'b1}}}; // +max
  localparam signed [WIDTH-1:0] SAT_MIN =  {1'b1, {WIDTH-1{1'b0}}}; // -max-1

  wire sat_hi = (rounded > SAT_MAX);
  wire sat_lo = (rounded < SAT_MIN);

  assign d = sat_hi ? SAT_MAX :
             sat_lo ? SAT_MIN :
                      rounded;

endmodule
