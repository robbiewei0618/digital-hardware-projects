// =============================================================================
// Module: mul_operator
// Description: Unsigned multiplier using Verilog * operator
//              Returns n-bit MSB half of 2n-bit product
// Pure Verilog-2001
// =============================================================================

module mul_operator #(
    parameter N = 16
)(
    input  wire [N-1:0] a,
    input  wire [N-1:0] b,
    output wire [N-1:0] p_msb
);
    wire [2*N-1:0] full_product;
    
    assign full_product = a * b;
    assign p_msb = full_product[2*N-1:N];
    
endmodule

// 8x8 wrapper
module mul_operator_8x8 (
    input  wire [7:0] a,
    input  wire [7:0] b,
    output wire [7:0] p_msb
);
    mul_operator #(.N(8)) u_mul (.a(a), .b(b), .p_msb(p_msb));
endmodule

// 16x16 wrapper
module mul_operator_16x16 (
    input  wire [15:0] a,
    input  wire [15:0] b,
    output wire [15:0] p_msb
);
    mul_operator #(.N(16)) u_mul (.a(a), .b(b), .p_msb(p_msb));
endmodule
