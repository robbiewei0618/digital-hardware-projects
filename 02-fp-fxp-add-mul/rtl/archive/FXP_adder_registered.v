// File: FXP_adder.v
// 32-bit signed fixed-point adder (two's complement)
// I/O per TA: a,b,d,clk,rst; synchronous registered output.
module FXP_adder (
  input  wire        clk,
  input  wire        rst,        // synchronous, active-high
  input  wire [31:0] a,
  input  wire [31:0] b,
  output reg  [31:0] d
);
  wire signed [31:0] as = a;
  wire signed [31:0] bs = b;
  wire signed [31:0] sum = as + bs;

  always @(posedge clk) begin
    if (rst) d <= 32'sd0;
    else     d <= sum;
  end
endmodule
