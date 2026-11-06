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
  // 右移 FRAC 位回到原比例。保留完整 2*WIDTH 位：若在這裡就截成 WIDTH 位，
  // 溢位的高位會先被丟掉，後面的飽和判斷永遠不會成立。
  wire signed [2*WIDTH-1:0] keep = product_full >>> FRAC;

  // Guard bit = FRAC-1 位，Sticky = 其餘低位 OR
  wire guard  = (FRAC == 0) ? 1'b0 : product_full[FRAC-1];
  wire sticky = (FRAC <= 1) ? 1'b0 : (|product_full[FRAC-2:0]);
  wire lsb_keep = keep[0];

  // ties-to-even 規則
  wire round_up = guard & (sticky | lsb_keep);

  // 執行加一（多 1 位，避免 +1 本身溢位）
  wire signed [2*WIDTH:0] rounded = {keep[2*WIDTH-1], keep} + {{(2*WIDTH){1'b0}}, round_up};

  // ------------------------------------------------------------
  // 3. 飽和處理 (Saturation)：在全寬度下比較
  // ------------------------------------------------------------
  localparam signed [WIDTH-1:0] SAT_MAX =  {1'b0, {WIDTH-1{1'b1}}}; // +max
  localparam signed [WIDTH-1:0] SAT_MIN =  {1'b1, {WIDTH-1{1'b0}}}; // -max-1

  wire sat_hi = (rounded > $signed({{(WIDTH+1){1'b0}}, SAT_MAX}));
  wire sat_lo = (rounded < $signed({{(WIDTH+1){1'b1}}, SAT_MIN}));

  assign d = sat_hi ? SAT_MAX :
             sat_lo ? SAT_MIN :
                      rounded[WIDTH-1:0];

endmodule
