// =============================================================================
// Module: mul_row
// Description: Unsigned multiplier using partial product row accumulation
//              No truncation - returns full precision MSB half
// Pure Verilog-2001
// =============================================================================

module mul_row #(
    parameter N = 16
)(
    input  wire [N-1:0] a,
    input  wire [N-1:0] b,
    output wire [N-1:0] p_msb
);
    reg [2*N-1:0] pp_sum;
    integer i;
    
    always @(*) begin
        pp_sum = 0;
        for (i = 0; i < N; i = i + 1) begin
            if (b[i])
                pp_sum = pp_sum + ({{N{1'b0}}, a} << i);
        end
    end
    
    assign p_msb = pp_sum[2*N-1:N];
    
endmodule

// 8x8 wrapper
module mul_row_8x8 (
    input  wire [7:0] a,
    input  wire [7:0] b,
    output wire [7:0] p_msb
);
    mul_row #(.N(8)) u_mul (.a(a), .b(b), .p_msb(p_msb));
endmodule

// 16x16 wrapper
module mul_row_16x16 (
    input  wire [15:0] a,
    input  wire [15:0] b,
    output wire [15:0] p_msb
);
    mul_row #(.N(16)) u_mul (.a(a), .b(b), .p_msb(p_msb));
endmodule