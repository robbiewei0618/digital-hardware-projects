module adder_behavior (s, co, a, b, ci);
    parameter width = 32;          // Define the bit-width of the adder
    output reg [width-1:0] s;      // Output sum
    output reg co;                 // Output carry-out
    input [width-1:0] a, b;        // Inputs a and b
    input ci;                      // Input carry-in

    // Behavioral modeling using an always block
    always @ (a or b or ci) begin
        {co, s} = a + b + ci;  // Use blocking assignment to calculate sum and carry-out
    end

endmodule