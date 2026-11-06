//=============================================================================
// Module: multiply_booth_opt
// Description: Radix-4 Booth multiplier with Sign-Bit Reduction
//
// Sign-Bit Reduction Principle:
// -----------------------------
// Original: Each PP needs full sign extension {s,s,s,...,s, data}
//           This requires MN bits per PP
//
// Optimized: Use {~s, data} format (only M+3 bits per PP)
//           Plus constant correction: -2^(M+2+2*i) per PP
//
// Benefits:
// - Reduces PP width from MN bits to M+3 bits
// - Smaller adder tree = less area and power
//
// Parameters: M = multiplicand width, N = multiplier width
//=============================================================================
module multiply_booth_opt #(
    parameter M = 8,
    parameter N = 16
)(
    input  wire [M-1:0]   a,
    input  wire [N-1:0]   b,
    output wire [M+N-1:0] p
);

    localparam MN = M + N;
    localparam NUM_PP = (N + 2) / 2;
    
    // Extended multiplier: {2-bit sign extension, b, 1-bit padding}
    wire [N+2:0] b_ext;
    assign b_ext = {{2{b[N-1]}}, b, 1'b0};
    
    // Sign-extended multiplicand (M+2 bits for 2A handling)
    wire [M+1:0] a_sext;
    assign a_sext = {{2{a[M-1]}}, a};
    
    // 2A (left shift by 1)
    wire [M+1:0] a_2x;
    assign a_2x = {a_sext[M:0], 1'b0};
    
    // Partial products with sign-bit reduction
    // Each PP is only M+3 bits: {~sign_gated, booth_val[M+1:0]}
    wire [MN-1:0] pp [0:NUM_PP-1];
    
    // Correction terms: -2^(M+2+2*i) for each PP
    wire [MN-1:0] corr_term [0:NUM_PP-1];
    
    genvar i;
    generate
        for (i = 0; i < NUM_PP; i = i + 1) begin : gen_booth
            // 3-bit Booth selector
            wire [2:0] sel;
            assign sel = b_ext[2*i+2 : 2*i];
            
            // Decode Booth digit
            wire is_zero;
            wire is_neg;
            wire is_one;
            wire is_two;
            
            assign is_zero = (sel == 3'b000) || (sel == 3'b111);
            assign is_neg  = (sel == 3'b100) || (sel == 3'b101) || (sel == 3'b110);
            assign is_one  = (sel == 3'b001) || (sel == 3'b010) || 
                            (sel == 3'b101) || (sel == 3'b110);
            assign is_two  = (sel == 3'b011) || (sel == 3'b100);
            
            // Select magnitude (M+2 bits)
            wire [M+1:0] mag;
            assign mag = is_zero ? {(M+2){1'b0}} :
                        (is_one  ? a_sext : a_2x);
            
            // Apply negation (2's complement if negative)
            wire [M+1:0] booth_val;
            assign booth_val = (is_zero) ? {(M+2){1'b0}} :
                              (is_neg)  ? (~mag + 1'b1) : mag;
            
            // Sign bit of booth_val
            wire sign_bit;
            assign sign_bit = booth_val[M+1];
            
            // Sign-bit reduction:
            // Gated sign: when is_zero, treat sign as 0 so ~sign_gated = 1
            // This makes the correction formula work uniformly
            wire sign_gated;
            assign sign_gated = sign_bit & (~is_zero);
            
            // Inverted sign (for sign-bit reduction)
            wire inv_sign;
            assign inv_sign = ~sign_gated;
            
            // Build reduced PP: {~sign_gated, booth_val[M+1:0]} = M+3 bits
            wire [M+2:0] pp_reduced;
            assign pp_reduced = {inv_sign, booth_val};
            
            // Place at position 2*i (left shift by 2*i)
            assign pp[i] = {{(MN-M-3){1'b0}}, pp_reduced} << (2*i);
            
            // Correction term: -2^(M+2+2*i) for each PP
            // Implemented as subtraction, so we store positive value to subtract later
            // Only apply if M+2+2*i < MN (within valid bit range)
            if (M + 2 + 2*i < MN) begin : gen_corr_valid
                assign corr_term[i] = {{(MN-1){1'b0}}, 1'b1} << (M + 2 + 2*i);
            end else begin : gen_corr_overflow
                assign corr_term[i] = {MN{1'b0}};
            end
        end
    endgenerate
    
    // Calculate total correction (sum of all correction terms)
    wire [MN-1:0] total_corr [0:NUM_PP];
    
    assign total_corr[0] = {MN{1'b0}};
    
    generate
        for (i = 0; i < NUM_PP; i = i + 1) begin : gen_corr_sum
            assign total_corr[i+1] = total_corr[i] + corr_term[i];
        end
    endgenerate
    
    // Accumulate all PP
    wire [MN-1:0] pp_sum [0:NUM_PP];
    
    assign pp_sum[0] = {MN{1'b0}};
    
    generate
        for (i = 0; i < NUM_PP; i = i + 1) begin : gen_pp_sum
            assign pp_sum[i+1] = pp_sum[i] + pp[i];
        end
    endgenerate
    
    // Final result: PP sum - total correction
    assign p = pp_sum[NUM_PP] - total_corr[NUM_PP];

endmodule