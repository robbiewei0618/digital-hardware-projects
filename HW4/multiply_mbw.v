//=============================================================================
// Module: multiply_mbw
// Description: Signed multiplier using Modified Baugh-Wooley method
//              Hardware-friendly implementation using generate
// Parameters: M = multiplicand width, N = multiplier width
//=============================================================================
module multiply_mbw #(
    parameter M = 8,
    parameter N = 16
)(
    input  wire [M-1:0]   a,
    input  wire [N-1:0]   b,
    output wire [M+N-1:0] p
);

    localparam MN = M + N;
    
    // Partial products
    wire [MN-1:0] pp [0:N-1];
    
    genvar i, j;
    
    // Generate partial products for rows 0 to N-2
    generate
        for (i = 0; i < N - 1; i = i + 1) begin : gen_pp_normal
            wire [M-1:0] row_bits;
            
            // a[0:M-2] & b[i]: normal AND
            for (j = 0; j < M - 1; j = j + 1) begin : gen_low
                assign row_bits[j] = a[j] & b[i];
            end
            // a[M-1] & b[i]: complemented
            assign row_bits[M-1] = ~(a[M-1] & b[i]);
            
            // Shift and zero-extend
            assign pp[i] = {{(N-1){1'b0}}, row_bits} << i;
        end
    endgenerate
    
    // Generate partial product for row N-1
    wire [M-1:0] last_row;
    
    generate
        // a[0:M-2] & b[N-1]: complemented
        for (j = 0; j < M - 1; j = j + 1) begin : gen_comp
            assign last_row[j] = ~(a[j] & b[N-1]);
        end
    endgenerate
    
    // a[M-1] & b[N-1]: normal (neg * neg = pos)
    assign last_row[M-1] = a[M-1] & b[N-1];
    
    assign pp[N-1] = {{(N-1){1'b0}}, last_row} << (N-1);
    
    // Correction constant: 2^(M-1) + 2^(N-1) + 2^(MN-1)
    wire [MN-1:0] correction;
    assign correction = (1 << (M-1)) + (1 << (N-1)) + (1 << (MN-1));
    
    // Accumulate
    wire [MN-1:0] partial_sum [0:N];
    
    assign partial_sum[0] = correction;
    
    generate
        for (i = 0; i < N; i = i + 1) begin : gen_acc
            assign partial_sum[i+1] = partial_sum[i] + pp[i];
        end
    endgenerate
    
    assign p = partial_sum[N];

endmodule