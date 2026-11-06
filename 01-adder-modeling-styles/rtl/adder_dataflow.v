module adder_dataflow (s, co, a, b, ci);
    parameter width = 32;        // Define the width of the adder
    output [width-1:0] s;        // Output sum with width bits
    output co;                   // Output carry-out
    input [width-1:0] a, b;      // Inputs a and b, each with width bits
    input ci;                    // Input carry-in

    // Continuous assignment for sum and carry-out
    assign {co, s} = a + b + ci;  // Perform addition with carry-in and assign carry-out
endmodule