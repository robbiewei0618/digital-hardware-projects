// =============================================================================
// Module: mul_trunc_const_row
// Description: Truncated unsigned multiplier with constant correction
//              Uses partial product row accumulation
//              r = n-k least significant columns are eliminated
//              Correction constant is added to compensate
//              For n=8: k=3, r=5
//              For n=16: k=4, r=12
//              Max error < 1 ULP = 2^(n-1)
// Pure Verilog-2001
// =============================================================================

module mul_trunc_const_row #(
    parameter N = 16,
    parameter K = 4    // k=3 for n=8, k=4 for n=16
)(
    input  wire [N-1:0] a,
    input  wire [N-1:0] b,
    output wire [N-1:0] p_msb
);
    // r = n - k = number of truncated columns
    // We compute columns [r, 2n-1] and output columns [n, 2n-1]
    
    // Correction constant: compensates for average truncation error
    // C = (2^k - 1) added at position r
    // In our reduced accumulator, position r is bit 0
    
    reg [2*N-1:0] pp_sum;
    reg [2*N-1:0] pp_row;
    integer i, j;
    integer r_val;
    
    always @(*) begin
        r_val = N - K;
        
        // Initialize with correction constant at position r
        // Correction = (2^K - 1) << r
        pp_sum = ((1 << K) - 1) << r_val;
        
        // Accumulate partial products, keeping only bits >= r
        for (i = 0; i < N; i = i + 1) begin
            if (b[i]) begin
                // Partial product: extend a to 2N bits, then shift
                pp_row = {{N{1'b0}}, a} << i;
                // Clear bits below r (truncation)
                pp_row = pp_row & (~((1 << r_val) - 1));
                pp_sum = pp_sum + pp_row;
            end
        end
    end
    
    assign p_msb = pp_sum[2*N-1:N];
    
endmodule

// 8x8 wrapper with k=3
module mul_trunc_const_row_8x8 (
    input  wire [7:0] a,
    input  wire [7:0] b,
    output wire [7:0] p_msb
);
    mul_trunc_const_row #(.N(8), .K(3)) u_mul (.a(a), .b(b), .p_msb(p_msb));
endmodule

// 16x16 wrapper with k=4
module mul_trunc_const_row_16x16 (
    input  wire [15:0] a,
    input  wire [15:0] b,
    output wire [15:0] p_msb
);
    mul_trunc_const_row #(.N(16), .K(4)) u_mul (.a(a), .b(b), .p_msb(p_msb));
endmodule