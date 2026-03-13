//=============================================================================
// Module: multiply_row
// Description: Signed multiplier with full sign extension (row accumulation)
//              Hardware-friendly implementation using generate
// Parameters: M = multiplicand width, N = multiplier width
//=============================================================================
module multiply_row #(
    parameter M = 8,
    parameter N = 16
)(
    input  wire [M-1:0]   a,
    input  wire [N-1:0]   b,
    output wire [M+N-1:0] p
);

    localparam MN = M + N;
    
    // Sign-extended multiplicand
    wire [MN-1:0] a_ext;
    assign a_ext = {{N{a[M-1]}}, a};
    
    // Partial products
    wire [MN-1:0] pp [0:N-1];
    
    // Generate partial products
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : gen_pp
            // Each partial product: sign-extended a AND-ed with b[i], shifted by i
            assign pp[i] = (a_ext & {MN{b[i]}}) << i;
        end
    endgenerate
    
    // Accumulate partial products
    // Rows 0 to N-2 are added, row N-1 is subtracted
    wire [MN-1:0] sum_pos;  // Sum of rows 0 to N-2
    wire [MN-1:0] sum_neg;  // Row N-1 (to be subtracted)
    
    // Use generate to create adder tree for positive rows
    wire [MN-1:0] partial_sum [0:N-1];
    
    generate
        // First partial sum
        if (N > 1) begin : gen_first
            assign partial_sum[0] = pp[0];
        end
        
        // Accumulate rows 0 to N-2
        for (i = 1; i < N - 1; i = i + 1) begin : gen_sum
            assign partial_sum[i] = partial_sum[i-1] + pp[i];
        end
        
        // Handle different N values
        if (N == 1) begin : gen_n1
            assign sum_pos = {MN{1'b0}};
        end else if (N == 2) begin : gen_n2
            assign sum_pos = pp[0];
        end else begin : gen_ngt2
            assign sum_pos = partial_sum[N-2];
        end
    endgenerate
    
    assign sum_neg = pp[N-1];
    
    // Final result: sum_pos - sum_neg
    assign p = sum_pos + (~sum_neg + 1'b1);

endmodule
