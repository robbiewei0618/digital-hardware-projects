`timescale 1ns/1ps
module tb_16x16;
    parameter M = 16, N = 16, NUM_TESTS = 100;
    localparam MN = M + N;
    reg [M-1:0] a_mem [0:NUM_TESTS-1];
    reg [N-1:0] b_mem [0:NUM_TESTS-1];
    reg [MN-1:0] ans_mem [0:NUM_TESTS-1];
    reg [M-1:0] a; reg [N-1:0] b;
    wire [MN-1:0] golden, p_op, p_row, p_row_opt, p_mbw, p_booth, p_booth_opt;
    assign golden = ans_mem[i];
    integer err_op=0, err_row=0, err_row_opt=0, err_mbw=0, err_booth=0, err_booth_opt=0, i;
    
    multiply_op #(M,N) u_op(a,b,p_op);
    multiply_row #(M,N) u_row(a,b,p_row);
    multiply_row_opt #(M,N) u_row_opt(a,b,p_row_opt);
    multiply_mbw #(M,N) u_mbw(a,b,p_mbw);
    multiply_booth #(M,N) u_booth(a,b,p_booth);
    multiply_booth_opt #(M,N) u_booth_opt(a,b,p_booth_opt);
    
    initial begin
        $readmemh("16x16_a.txt", a_mem);
        $readmemh("16x16_b.txt", b_mem);
        $readmemh("16x16_ans.txt", ans_mem);
        #10;
        for (i = 0; i < NUM_TESTS; i = i + 1) begin
            a = a_mem[i]; b = b_mem[i]; #10;
            if (p_op !== golden) err_op = err_op + 1;
            if (p_row !== golden) err_row = err_row + 1;
            if (p_row_opt !== golden) err_row_opt = err_row_opt + 1;
            if (p_mbw !== golden) err_mbw = err_mbw + 1;
            if (p_booth !== golden) err_booth = err_booth + 1;
            if (p_booth_opt !== golden) err_booth_opt = err_booth_opt + 1;
        end
        $display("16x16: op=%0d row=%0d row_opt=%0d mbw=%0d booth=%0d booth_opt=%0d", 
                 err_op, err_row, err_row_opt, err_mbw, err_booth, err_booth_opt);
        if (err_op + err_row + err_row_opt + err_mbw + err_booth + err_booth_opt == 0)
            $display("ALL 16x16 TESTS PASSED!");
        $finish;
    end
endmodule
