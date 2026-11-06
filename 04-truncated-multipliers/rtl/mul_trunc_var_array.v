// =============================================================================
// Module: mul_trunc_var_array
// Description: Truncated array multiplier with variable correction
//              Hardware-friendly using generate blocks
//              Only columns R to 2N-1 have FAs (true truncation)
//              
//              For n=8: k=2, r=6 → WIDTH=10 (vs 16 in full array)
//              For n=16: k=3, r=13 → WIDTH=19 (vs 32 in full array)
// Pure Verilog-2001
// =============================================================================

module mul_trunc_var_array #(
    parameter N = 16,
    parameter K = 3    // k=2 for n=8, k=3 for n=16
)(
    input  wire [N-1:0] a,
    input  wire [N-1:0] b,
    output wire [N-1:0] p_msb
);
    localparam R = N - K;           // Truncation point (6 for 8-bit)
    localparam WIDTH = 2*N - R;     // Retained columns (10 for 8-bit)
    
    //=========================================================================
    // Partial Products: pp[i][j] = a[j] & b[i]
    //=========================================================================
    wire [N-1:0] pp [0:N-1];
    
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : gen_pp
            assign pp[i] = a & {N{b[i]}};
        end
    endgenerate
    
    //=========================================================================
    // Variable Correction: sum of PP bits in column R-1
    // Column R-1 has pp[i][j] where i+j = R-1, so j = R-1-i
    //=========================================================================
    wire [N-1:0] col_r1_bits;
    
    genvar v;
    generate
        for (v = 0; v < N; v = v + 1) begin : gen_var_corr
            if ((R - 1 - v) >= 0 && (R - 1 - v) < N) begin : valid_bit
                assign col_r1_bits[v] = pp[v][R - 1 - v];
            end else begin : invalid_bit
                assign col_r1_bits[v] = 1'b0;
            end
        end
    endgenerate
    
    // Population count (adder tree for column R-1 sum)
    // For N=8: sum of up to 8 bits → needs 4 bits
    // For N=16: sum of up to 16 bits → needs 5 bits
    wire [4:0] var_corr;
    
    generate
        if (N == 8) begin : var_corr_8
            // 8-bit: col R-1 = col 5, has pp[0][5], pp[1][4], ..., pp[5][0]
            // 6 valid bits to sum
            wire [2:0] sum_lo = col_r1_bits[0] + col_r1_bits[1] + col_r1_bits[2];
            wire [2:0] sum_hi = col_r1_bits[3] + col_r1_bits[4] + col_r1_bits[5];
            assign var_corr = sum_lo + sum_hi;
        end else begin : var_corr_16
            // 16-bit: col R-1 = col 12, has pp[0][12], pp[1][11], ..., pp[12][0]
            // 13 valid bits to sum
            wire [2:0] s0 = col_r1_bits[0] + col_r1_bits[1] + col_r1_bits[2];
            wire [2:0] s1 = col_r1_bits[3] + col_r1_bits[4] + col_r1_bits[5];
            wire [2:0] s2 = col_r1_bits[6] + col_r1_bits[7] + col_r1_bits[8];
            wire [2:0] s3 = col_r1_bits[9] + col_r1_bits[10] + col_r1_bits[11];
            wire [3:0] s4 = s0 + s1;
            wire [3:0] s5 = s2 + s3 + col_r1_bits[12];
            assign var_corr = s4 + s5;
        end
    endgenerate
    
    // Total correction = var_corr + (2^K - 1)
    wire [4:0] total_corr = var_corr + ((1 << K) - 1);
    
    //=========================================================================
    // Truncated CSA Array: only WIDTH columns
    // Index 0 = full column R
    //=========================================================================
    wire [WIDTH-1:0] s [0:N-1];
    wire [WIDTH-1:0] c [0:N-1];
    
    // Row 0: Initialize with PP[0] for columns >= R
    genvar col;
    generate
        for (col = 0; col < WIDTH; col = col + 1) begin : gen_row0
            // full_col = col + R
            // PP[0][j] at column j, so j = col + R
            if ((col + R) < N) begin : has_pp0
                assign s[0][col] = pp[0][col + R];
            end else begin : no_pp0
                assign s[0][col] = 1'b0;
            end
            assign c[0][col] = 1'b0;
        end
    endgenerate
    
    // CSA Rows 1 to N-1: only WIDTH columns of FAs
    genvar row;
    generate
        for (row = 1; row < N; row = row + 1) begin : gen_csa_row
            for (col = 0; col < WIDTH; col = col + 1) begin : gen_csa_col
                // full_col = col + R
                // j_idx = full_col - row = col + R - row
                
                // PP bit: pp[row][j] where j = col + R - row
                wire pp_bit;
                if ((col + R - row) >= 0 && (col + R - row) < N) begin : has_pp
                    assign pp_bit = pp[row][col + R - row];
                end else begin : no_pp
                    assign pp_bit = 1'b0;
                end
                
                // Carry from left column (col-1) of previous row
                wire c_in;
                if (col > 0) begin : has_cin
                    assign c_in = c[row-1][col-1];
                end else begin : no_cin
                    assign c_in = 1'b0;  // No carry from truncated region
                end
                
                // Full Adder
                wire s_in = s[row-1][col];
                wire [1:0] fa_out = s_in + c_in + pp_bit;
                
                assign s[row][col] = fa_out[0];
                assign c[row][col] = fa_out[1];
            end
        end
    endgenerate
    
    //=========================================================================
    // Final CPA with correction
    // correction added at position 0 (column R)
    //=========================================================================
    wire [WIDTH-1:0] final_s = s[N-1];
    wire [WIDTH-1:0] final_c = {c[N-1][WIDTH-2:0], 1'b0};
    wire [WIDTH+4:0] product = final_s + final_c + total_corr;
    
    // Output: columns N to 2N-1 = truncated indices K to WIDTH-1
    assign p_msb = product[K +: N];
    
endmodule

// 8x8 wrapper with k=2, r=6
module mul_trunc_var_array_8x8 (
    input  wire [7:0] a,
    input  wire [7:0] b,
    output wire [7:0] p_msb
);
    mul_trunc_var_array #(.N(8), .K(2)) u_mul (.a(a), .b(b), .p_msb(p_msb));
endmodule

// 16x16 wrapper with k=3, r=13
module mul_trunc_var_array_16x16 (
    input  wire [15:0] a,
    input  wire [15:0] b,
    output wire [15:0] p_msb
);
    mul_trunc_var_array #(.N(16), .K(3)) u_mul (.a(a), .b(b), .p_msb(p_msb));
endmodule