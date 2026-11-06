module adder_behavior_reg (s, co, a, b, ci, clk);
    parameter width = 32;
    output reg [width-1:0] s;
    output reg co;
    input [width-1:0] a, b;
    input ci, clk;

    always @(posedge clk) begin
        {co, s} <= a + b + ci;  // Store sum and carry-out in flip-flops on clock edge
    end
endmodule
