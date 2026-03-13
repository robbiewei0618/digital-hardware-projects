//=============================================================================
// Module: multiply_booth
// Description: Signed multiplier using Radix-4 Booth recoding
//              Hardware-friendly implementation using generate
//
// Radix-4 Booth Encoding:
// -----------------------
// For each group i, examine 3 bits: {b[2i+1], b[2i], b[2i-1]}
// where b[-1] = 0
//
// Encoding table:
//   sel    | digit | operation
//   000    |   0   | 0
//   001    |  +1   | +A
//   010    |  +1   | +A
//   011    |  +2   | +2A
//   100    |  -2   | -2A
//   101    |  -1   | -A
//   110    |  -1   | -A
//   111    |   0   | 0
//
// Parameters: M = multiplicand width, N = multiplier width
//=============================================================================
module multiply_booth #(
    parameter M = 8,
    parameter N = 16
)(
    input  wire [M-1:0]   a,
    input  wire [N-1:0]   b,
    output wire [M+N-1:0] p
);

    localparam MN = M + N;
    localparam NUM_PP = (N + 2) / 2;  // Number of Booth partial products
    
    // Extended multiplier: {2-bit sign extension, b, 1-bit zero padding}
    // This allows accessing b[2i+1], b[2i], b[2i-1] for all groups
    // b_ext[0] = 0 (padding for b[-1])
    // b_ext[1..N] = b[0..N-1]
    // b_ext[N+1..N+2] = sign extension
    wire [N+2:0] b_ext;
    assign b_ext = {{2{b[N-1]}}, b, 1'b0};
    
    // Sign-extended multiplicand to MN+1 bits
    // Extra bit to handle -2A without overflow (when A = most negative)
    wire [MN:0] a_sext;
    assign a_sext = {{(N+1){a[M-1]}}, a};
    
    // 2A (arithmetic left shift by 1)
    wire [MN:0] a_2x;
    assign a_2x = {a_sext[MN-1:0], 1'b0};
    
    // Booth partial products
    wire [MN:0] pp [0:NUM_PP-1];
    
    genvar i;
    generate
        for (i = 0; i < NUM_PP; i = i + 1) begin : gen_booth
            // 3-bit Booth selector: {b[2i+1], b[2i], b[2i-1]}
            // Using b_ext indexing: b_ext[2i+2], b_ext[2i+1], b_ext[2i]
            wire [2:0] sel;
            assign sel = b_ext[2*i+2 : 2*i];
            
            // Decode Booth digit
            // is_zero: digit = 0 (sel = 000 or 111)
            // is_neg:  digit < 0 (sel = 100, 101, 110)
            // is_one:  |digit| = 1 (sel = 001, 010, 101, 110)
            // is_two:  |digit| = 2 (sel = 011, 100)
            wire is_zero, is_neg, is_one, is_two;
            
            assign is_zero = (sel == 3'b000) || (sel == 3'b111);
            assign is_neg  = (sel == 3'b100) || (sel == 3'b101) || (sel == 3'b110);
            assign is_one  = (sel == 3'b001) || (sel == 3'b010) || 
                            (sel == 3'b101) || (sel == 3'b110);
            assign is_two  = (sel == 3'b011) || (sel == 3'b100);
            
            // Select magnitude (0, A, or 2A)
            wire [MN:0] magnitude;
            assign magnitude = is_zero ? {(MN+1){1'b0}} :
                              (is_one  ? a_sext : a_2x);
            
            // Apply sign (2's complement if negative)
            // IMPORTANT: Only negate when NOT zero, to avoid ~0+1 issue
            wire [MN:0] booth_val;
            assign booth_val = (is_zero) ? {(MN+1){1'b0}} :
                              (is_neg)  ? (~magnitude + 1'b1) : magnitude;
            
            // Shift by 2*i positions
            // Since booth_val is MN+1 bits and we only need MN bits in result,
            // the left shift will naturally truncate high bits
            assign pp[i] = booth_val << (2*i);
        end
    endgenerate
    
    // Accumulate all Booth partial products
    wire [MN:0] partial_sum [0:NUM_PP];
    
    assign partial_sum[0] = {(MN+1){1'b0}};
    
    generate
        for (i = 0; i < NUM_PP; i = i + 1) begin : gen_acc
            assign partial_sum[i+1] = partial_sum[i] + pp[i];
        end
    endgenerate
    
    // Take lower MN bits as final result
    assign p = partial_sum[NUM_PP][MN-1:0];

endmodule