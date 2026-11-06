module D_FF (q, d, clk);
    output reg q;
    input d, clk;

    always @(posedge clk) begin
        q <= d;  // Store the value of d in q on the rising edge of the clock
    end
endmodule