//=============================================================================
// Module: multiply_op
// Description: Signed multiplier using Verilog * operator
// Parameters: M = multiplicand width, N = multiplier width
//=============================================================================
module multiply_op #(
    parameter M = 8,
    parameter N = 16
)(
    input  wire [M-1:0]   a,
    input  wire [N-1:0]   b,
    output wire [M+N-1:0] p
);

    wire signed [M-1:0]   sa;
    wire signed [N-1:0]   sb;
    wire signed [M+N-1:0] sp;
    
    assign sa = a;
    assign sb = b;
    assign sp = sa * sb;
    assign p  = sp;

endmodule
