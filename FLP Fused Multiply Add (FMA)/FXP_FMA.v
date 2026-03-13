// ============================================================
// File: FXP_FMA.v
// Fixed-Point Fused Multiply-Add: d = a*b + c
// ============================================================

module FXP_FMA (
    input  wire signed [31:0] a,
    input  wire signed [31:0] b,
    input  wire signed [31:0] c,
    output wire signed [31:0] d
);
    reg signed [63:0] product;
    reg signed [63:0] c_extended;
    reg signed [63:0] sum;
    
    // a * b
    assign product = a * b;
    
    // Sign-extend c to 64 bits
    assign c_extended = {{32{c[31]}}, c};
    
    // Add: a*b + c
    assign sum = product + c_extended;
    
    // Take upper 32 bits (MSB)
    assign d = sum[63:32];
    
endmodule