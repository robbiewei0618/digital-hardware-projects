module RCA_32bit (sum, c_out, a, b, c_in);
    output [31:0] sum;
    output c_out;
    input [31:0] a, b;
    input c_in;
    
    wire [31:0] carry;  // Intermediate carry signals

    // First Full Adder
    FA FA0 (sum[0], carry[0], a[0], b[0], c_in);

    // Remaining 31 Full Adders
    genvar i;
    generate
        for (i = 1; i < 32; i = i + 1) begin: FA_Stages
            FA FA_inst (sum[i], carry[i], a[i], b[i], carry[i-1]);
        end
    endgenerate

    assign c_out = carry[31];  // Final carry out
endmodule
