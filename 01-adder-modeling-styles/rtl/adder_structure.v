module adder_structure (s, co, a, b, ci);
    parameter width = 32;        // Define the bit-width of the adder
    output [width-1:0] s;        // Output sum
    output co;                   // Output carry-out
    input [width-1:0] a, b;      // Inputs a and b
    input ci;                    // Input carry-in
    
    wire [width-1:0] carry;      // Intermediate carry signals

    // First Full Adder
    FA FA0 (s[0], carry[0], a[0], b[0], ci);

    // Remaining 31 Full Adders
    genvar i;
    generate
        for (i = 1; i < width; i = i + 1) begin: FA_Stages
            FA FA_inst (s[i], carry[i], a[i], b[i], carry[i-1]);
        end
    endgenerate

    assign co = carry[width-1];  // Final carry out
endmodule
