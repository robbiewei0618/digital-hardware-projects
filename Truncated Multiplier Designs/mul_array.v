// =============================================================================
// Module: mul_array
// Description: Unsigned array multiplier - TRUE bit-level CSA structure
//              Hardware-friendly using generate blocks
//              Each FA is explicit hardware
// Pure Verilog-2001
// =============================================================================

module mul_array #(
    parameter N = 16
)(
    input  wire [N-1:0] a,
    input  wire [N-1:0] b,
    output wire [N-1:0] p_msb
);
    //=========================================================================
    // Partial Products: pp[i][j] = a[j] & b[i], at column i+j
    //=========================================================================
    wire [N-1:0] pp [0:N-1];
    
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : gen_pp
            assign pp[i] = a & {N{b[i]}};
        end
    endgenerate
    
    //=========================================================================
    // CSA Array: s[row][col], c[row][col]
    // Row 0 = first PP, Rows 1~N-1 = FA outputs
    //=========================================================================
    wire [2*N-1:0] s [0:N-1];
    wire [2*N-1:0] c [0:N-1];
    
    // Row 0: Initialize with PP[0]
    assign s[0] = {{N{1'b0}}, pp[0]};
    assign c[0] = {2*N{1'b0}};
    
    // Generate CSA rows 1 to N-1
    genvar row, col;
    generate
        for (row = 1; row < N; row = row + 1) begin : gen_csa_row
            for (col = 0; col < 2*N; col = col + 1) begin : gen_csa_col
                
                // PP bit for this position
                wire pp_bit;
                if (col >= row && col < row + N) begin : has_pp
                    assign pp_bit = pp[row][col - row];
                end else begin : no_pp
                    assign pp_bit = 1'b0;
                end
                
                // Carry input from left column of previous row
                wire c_in;
                if (col > 0) begin : has_cin
                    assign c_in = c[row-1][col-1];
                end else begin : no_cin
                    assign c_in = 1'b0;
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
    // Final CPA
    //=========================================================================
    wire [2*N-1:0] product = s[N-1] + {c[N-1][2*N-2:0], 1'b0};
    
    assign p_msb = product[2*N-1:N];
    
endmodule

// 8x8 wrapper
module mul_array_8x8 (
    input  wire [7:0] a,
    input  wire [7:0] b,
    output wire [7:0] p_msb
);
    mul_array #(.N(8)) u_mul (.a(a), .b(b), .p_msb(p_msb));
endmodule

// 16x16 wrapper
module mul_array_16x16 (
    input  wire [15:0] a,
    input  wire [15:0] b,
    output wire [15:0] p_msb
);
    mul_array #(.N(16)) u_mul (.a(a), .b(b), .p_msb(p_msb));
endmodule