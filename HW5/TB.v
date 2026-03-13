//=============================================================================
// Testbench: tb_truncated_mul
// Description: 從檔案讀取測試資料的測試平台
//              使用 $readmemh 讀取 a.txt, b.txt, ans.txt
//              For HW5 Truncated Multipliers (Unsigned)
//=============================================================================
`timescale 1ns/1ps

module tb_truncated_mul;

    // 測試配置 - 修改這裡切換不同精度
    parameter N = 8;           // 位寬 (8 or 16)
    parameter NUM_TESTS = 100; // 測試數量
    
    // 測試檔案路徑 - 根據 N 修改
    // 8x8:   "8x8_a.txt",   "8x8_b.txt",   "8x8_ans.txt"
    // 16x16: "16x16_a.txt", "16x16_b.txt", "16x16_ans.txt"
    parameter A_FILE   = "8x8_a.txt";
    parameter B_FILE   = "8x8_b.txt";
    parameter ANS_FILE = "8x8_ans.txt";
    
    //parameter A_FILE   = "16x16_a.txt";
    //parameter B_FILE   = "16x16_b.txt";
    //parameter ANS_FILE = "16x16_ans.txt";

    // 1 ULP = 2^(n-1) - truncated multipliers should have error < 1 ULP
    localparam ULP = 1 << (N-1);
    
    // 測試資料記憶體
    reg [N-1:0]   a_mem   [0:NUM_TESTS-1];
    reg [N-1:0]   b_mem   [0:NUM_TESTS-1];
    reg [N-1:0]   ans_mem [0:NUM_TESTS-1];  // MSB half of product [2N-1:N]
    
    // 測試信號
    reg [N-1:0]  a;
    reg [N-1:0]  b;
    wire [N-1:0] golden;
    
    // 待測模組輸出 - n-bit MSB half
    wire [N-1:0] p_op, p_row, p_trunc_const, p_array, p_trunc_var;
    
    // 錯誤計數
    integer err_op, err_row, err_trunc_const, err_array, err_trunc_var;
    integer i;
    
    // 誤差追蹤 (for truncated multipliers)
    integer max_err_trunc_const, max_err_trunc_var;
    integer curr_err_const, curr_err_var;
    
    // 從檔案讀取的答案
    assign golden = ans_mem[i];
    
    //=========================================================================
    // 實例化所有乘法器
    //=========================================================================
    mul_operator #(.N(N)) u_op (
        .a(a), .b(b), .p_msb(p_op)
    );
    
    mul_row #(.N(N)) u_row (
        .a(a), .b(b), .p_msb(p_row)
    );
    
    mul_trunc_const_row #(.N(N), .K((N==8)?3:4)) u_trunc_const (
        .a(a), .b(b), .p_msb(p_trunc_const)
    );
    
    mul_array #(.N(N)) u_array (
        .a(a), .b(b), .p_msb(p_array)
    );
    
    mul_trunc_var_array #(.N(N), .K((N==8)?2:3)) u_trunc_var (
        .a(a), .b(b), .p_msb(p_trunc_var)
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
        err_trunc_const = 0;
        err_array = 0;
        err_trunc_var = 0;
        max_err_trunc_const = 0;
        max_err_trunc_var = 0;
        
        $display("=========================================================");
        $display("Testing %0dx%0d Unsigned Truncated Multipliers from files", N, N);
        $display("  A file:   %s", A_FILE);
        $display("  B file:   %s", B_FILE);
        $display("  ANS file: %s", ANS_FILE);
        $display("  1 ULP = 2^%0d = %0d", N-1, ULP);
        $display("=========================================================");
        
        #10;
        
        for (i = 0; i < NUM_TESTS; i = i + 1) begin
            // 載入測試資料
            a = a_mem[i];
            b = b_mem[i];
            
            #10;
            
            // 檢查 operator (應該精確匹配)
            if (p_op !== golden) begin
                err_op = err_op + 1;
                $display("Test %3d: OP ERROR       a=%h b=%h exp=%h got=%h", i, a, b, golden, p_op);
            end
            
            // 檢查 row (應該精確匹配)
            if (p_row !== golden) begin
                err_row = err_row + 1;
                $display("Test %3d: ROW ERROR      a=%h b=%h exp=%h got=%h", i, a, b, golden, p_row);
            end
            
            // 檢查 trunc_const_row (允許誤差 < 1 ULP)
            curr_err_const = (p_trunc_const > golden) ? (p_trunc_const - golden) : (golden - p_trunc_const);
            if (curr_err_const > max_err_trunc_const)
                max_err_trunc_const = curr_err_const;
            if (curr_err_const >= ULP) begin
                err_trunc_const = err_trunc_const + 1;
                $display("Test %3d: TRUNC_CONST ER a=%h b=%h exp=%h got=%h err=%0d", i, a, b, golden, p_trunc_const, curr_err_const);
            end
            
            // 檢查 array (應該精確匹配)
            if (p_array !== golden) begin
                err_array = err_array + 1;
                $display("Test %3d: ARRAY ERROR    a=%h b=%h exp=%h got=%h", i, a, b, golden, p_array);
            end
            
            // 檢查 trunc_var_array (允許誤差 < 1 ULP)
            curr_err_var = (p_trunc_var > golden) ? (p_trunc_var - golden) : (golden - p_trunc_var);
            if (curr_err_var > max_err_trunc_var)
                max_err_trunc_var = curr_err_var;
            if (curr_err_var >= ULP) begin
                err_trunc_var = err_trunc_var + 1;
                $display("Test %3d: TRUNC_VAR ERR  a=%h b=%h exp=%h got=%h err=%0d", i, a, b, golden, p_trunc_var, curr_err_var);
            end
        end
        
        // 輸出結果摘要
        $display("");
        $display("=========================================================");
        $display("SUMMARY for %0dx%0d Unsigned Truncated Multipliers", N, N);
        $display("=========================================================");
        $display("Method          | Errors | Max Err | Status");
        $display("----------------|--------|---------|-------");
        $display("operator        | %5d  |    0    | %s", err_op,          (err_op == 0)          ? "PASS" : "FAIL");
        $display("row             | %5d  |    0    | %s", err_row,         (err_row == 0)         ? "PASS" : "FAIL");
        $display("trunc_const_row | %5d  | %5d   | %s", err_trunc_const, max_err_trunc_const, (err_trunc_const == 0) ? "PASS" : "FAIL");
        $display("array           | %5d  |    0    | %s", err_array,       (err_array == 0)       ? "PASS" : "FAIL");
        $display("trunc_var_array | %5d  | %5d   | %s", err_trunc_var,   max_err_trunc_var,   (err_trunc_var == 0)   ? "PASS" : "FAIL");
        $display("=========================================================");
        $display("Note: Truncated multipliers allow error < 1 ULP = %0d", ULP);
        $display("=========================================================");
        
        if ((err_op + err_row + err_trunc_const + err_array + err_trunc_var) == 0)
            $display("ALL TESTS PASSED!");
        else
            $display("SOME TESTS FAILED!");
        
        $finish;
    end

endmodule
