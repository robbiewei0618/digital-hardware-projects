//=============================================================================
// Testbench: tb_with_file
// Description: 從檔案讀取測試資料的測試平台
//              使用 $readmemh 讀取 a.txt, b.txt, ans.txt
//=============================================================================
`timescale 1ns/1ps

module tb_with_file;

    // 測試配置 - 修改這裡切換不同精度
    parameter M = 8;           // 被乘數位寬
    parameter N = 8;           // 乘數位寬
    parameter NUM_TESTS = 100; // 測試數量
    
    // 測試檔案路徑 - 根據 M, N 修改
    // 8x8:   "8x8_a.txt",   "8x8_b.txt",   "8x8_ans.txt"
    // 16x8:  "16x8_a.txt",  "16x8_b.txt",  "16x8_ans.txt"
    // 16x16: "16x16_a.txt", "16x16_b.txt", "16x16_ans.txt"
    parameter A_FILE   = "8x8_a.txt";
    parameter B_FILE   = "8x8_b.txt";
    parameter ANS_FILE = "8x8_ans.txt";
    
    localparam MN = M + N;
    
    // 測試資料記憶體
    reg [M-1:0]   a_mem   [0:NUM_TESTS-1];
    reg [N-1:0]   b_mem   [0:NUM_TESTS-1];
    reg [MN-1:0]  ans_mem [0:NUM_TESTS-1];
    
    // 測試信號
    reg [M-1:0]  a;
    reg [N-1:0]  b;
    wire [MN-1:0] golden;
    
    // 待測模組輸出
    wire [MN-1:0] p_op, p_row, p_row_opt, p_mbw, p_booth, p_booth_opt;
    
    // 錯誤計數
    integer err_op, err_row, err_row_opt, err_mbw, err_booth, err_booth_opt;
    integer i;
    
    // 從檔案讀取的答案
    assign golden = ans_mem[i];
    
    //=========================================================================
    // 實例化所有乘法器
    //=========================================================================
    multiply_op #(.M(M), .N(N)) u_op (
        .a(a), .b(b), .p(p_op)
    );
    
    multiply_row #(.M(M), .N(N)) u_row (
        .a(a), .b(b), .p(p_row)
    );
    
    multiply_row_opt #(.M(M), .N(N)) u_row_opt (
        .a(a), .b(b), .p(p_row_opt)
    );
    
    multiply_mbw #(.M(M), .N(N)) u_mbw (
        .a(a), .b(b), .p(p_mbw)
    );
    
    multiply_booth #(.M(M), .N(N)) u_booth (
        .a(a), .b(b), .p(p_booth)
    );
    
    multiply_booth_opt #(.M(M), .N(N)) u_booth_opt (
        .a(a), .b(b), .p(p_booth_opt)
    );
    
    //=========================================================================
    // 測試程序
    //=========================================================================
    initial begin
        // 從檔案載入測試資料
        $readmemh(A_FILE, a_mem);
        $readmemh(B_FILE, b_mem);
        $readmemh(ANS_FILE, ans_mem);
        
        // 初始化
        a = 0;
        b = 0;
        err_op = 0;
        err_row = 0;
        err_row_opt = 0;
        err_mbw = 0;
        err_booth = 0;
        err_booth_opt = 0;
        
        $display("=========================================================");
        $display("Testing %0dx%0d Signed Multipliers from files", M, N);
        $display("  A file:   %s", A_FILE);
        $display("  B file:   %s", B_FILE);
        $display("  ANS file: %s", ANS_FILE);
        $display("=========================================================");
        
        #10;
        
        for (i = 0; i < NUM_TESTS; i = i + 1) begin
            // 載入測試資料
            a = a_mem[i];
            b = b_mem[i];
            
            #10;
            
            // 檢查每個乘法器
            if (p_op !== golden) begin
                err_op = err_op + 1;
                $display("Test %3d: OP ERROR     a=%h b=%h exp=%h got=%h", i, a, b, golden, p_op);
            end
            
            if (p_row !== golden) begin
                err_row = err_row + 1;
                $display("Test %3d: ROW ERROR    a=%h b=%h exp=%h got=%h", i, a, b, golden, p_row);
            end
            
            if (p_row_opt !== golden) begin
                err_row_opt = err_row_opt + 1;
                $display("Test %3d: ROW_OPT ERR  a=%h b=%h exp=%h got=%h", i, a, b, golden, p_row_opt);
            end
            
            if (p_mbw !== golden) begin
                err_mbw = err_mbw + 1;
                $display("Test %3d: MBW ERROR    a=%h b=%h exp=%h got=%h", i, a, b, golden, p_mbw);
            end
            
            if (p_booth !== golden) begin
                err_booth = err_booth + 1;
                $display("Test %3d: BOOTH ERROR  a=%h b=%h exp=%h got=%h", i, a, b, golden, p_booth);
            end
            
            if (p_booth_opt !== golden) begin
                err_booth_opt = err_booth_opt + 1;
                $display("Test %3d: BOOTH_OPT ER a=%h b=%h exp=%h got=%h", i, a, b, golden, p_booth_opt);
            end
        end
        
        // 輸出結果摘要
        $display("");
        $display("=========================================================");
        $display("SUMMARY for %0dx%0d Multipliers", M, N);
        $display("=========================================================");
        $display("Method      | Errors | Status");
        $display("------------|--------|-------");
        $display("op          | %5d  | %s", err_op,      (err_op == 0)      ? "PASS" : "FAIL");
        $display("row         | %5d  | %s", err_row,     (err_row == 0)     ? "PASS" : "FAIL");
        $display("row_opt     | %5d  | %s", err_row_opt, (err_row_opt == 0) ? "PASS" : "FAIL");
        $display("mbw         | %5d  | %s", err_mbw,     (err_mbw == 0)     ? "PASS" : "FAIL");
        $display("booth       | %5d  | %s", err_booth,   (err_booth == 0)   ? "PASS" : "FAIL");
        $display("booth_opt   | %5d  | %s", err_booth_opt, (err_booth_opt == 0) ? "PASS" : "FAIL");
        $display("=========================================================");
        
        if ((err_op + err_row + err_row_opt + err_mbw + err_booth + err_booth_opt) == 0)
            $display("ALL TESTS PASSED!");
        else
            $display("SOME TESTS FAILED!");
        
        $finish;
    end

endmodule
