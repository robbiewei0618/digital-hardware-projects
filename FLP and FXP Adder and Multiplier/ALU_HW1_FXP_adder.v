module FXP_adder(
    input signed [31:0] a,
    input signed [31:0] b,
    output signed [31:0] d
);
    assign d = a + b;
endmodule