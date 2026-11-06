module adder_structure_reg (s, co, a, b, ci, clk);
    parameter width = 32;
    output [width-1:0] s;
    output co;
    input [width-1:0] a, b;
    input ci, clk;

    wire [width-1:0] sum;
    wire carry_out;

    RCA_32bit U1 (sum, carry_out, a, b, ci);  // Instantiate the ripple carry adder

    // Flip-flops to store the sum and carry-out
    genvar i;
    generate
        for (i = 0; i < width; i = i + 1) begin: store_sum
            D_FF sum_ff(s[i], sum[i], clk);  // Store each bit of the sum in a flip-flop
        end
    endgenerate
    D_FF carry_ff(co, carry_out, clk);  // Store carry-out in a flip-flop
endmodule
