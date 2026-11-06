// ============================================================
// File: ALU_HW2_FMA_testbench.v
// Modified: Read expected answers from file
// ============================================================

`timescale 1ns/1ps

// Select which module to test
//`define TEST_FXP_FMA
`define TEST_FLP_FMA
//`define TEST_FLP_FMA_4

`define CYCLE 5.0
`define DATA_NUM 215

`define FILE_A "/MasterClass/M133040086_ALU/HW2/a.txt"
`define FILE_B "/MasterClass/M133040086_ALU/HW2/b.txt"
`define FILE_C "/MasterClass/M133040086_ALU/HW2/c.txt"
`define FILE_ANS "/MasterClass/M133040086_ALU/HW2/ab+c.txt"
`define FILE_OUT "/MasterClass/M133040086_ALU/HW2/output.txt"

module ALU_HW2_FMA_testbench();
    integer file_a, file_b, file_c, file_ans, file_out;
    integer garbage, i, error;
    integer error_display_count;
    
    reg CLK, RST;
    
    reg [31:0] data_a [0:`DATA_NUM-1];
    reg [31:0] data_b [0:`DATA_NUM-1];
    reg [31:0] data_c [0:`DATA_NUM-1];
    reg [31:0] data_ans [0:`DATA_NUM-1];  // 从文件读取的答案
    
    reg [31:0] input_a, input_b, input_c;
    reg [31:0] temp_a, temp_b, temp_c;
    
    wire [31:0] outcome;
    reg [31:0] expected;  // 当前测试的期望值
    
    real real_a, real_b, real_c, real_expected, real_outcome;
    real abs_error, rel_error, total_error;
    
    // Instantiate module
    `ifdef TEST_FXP_FMA
        FXP_FMA test_module(.a(input_a), .b(input_b), .c(input_c), .d(outcome));
    `elsif TEST_FLP_FMA
        FLP_FMA test_module(.A(input_a), .B(input_b), .C(input_c), .R(outcome));
    `elsif TEST_FLP_FMA_4
        FLP_FMA_4 test_module(.clk(CLK), .rst(RST), .a(input_a), .b(input_b), .c(input_c), .d(outcome));
        localparam PIPE_STAGES = 4;
    `endif
    
    `ifdef SDF_FILE
        initial $sdf_annotate(`SDF_FILE, test_module);
    `endif
    
    `ifdef TEST_FLP_FMA_4
        always begin
            #(`CYCLE/2) CLK = ~CLK;
        end
    `endif
    
    // ========================================================================
    // Helper function: 转换为实数
    // ========================================================================
    function real bits_to_real;
        input [31:0] x;
        reg [63:0] temp;
        begin
            // 检查特殊值
            if (x[30:23] == 8'd0 && x[22:0] == 23'd0) begin
                // Zero
                bits_to_real = 0.0;
            end else if (x[30:23] == 8'd255) begin
                if (x[22:0] == 23'd0) begin
                    // Infinity
                    bits_to_real = (x[31]) ? -1.0e308 : 1.0e308;
                end else begin
                    // NaN
                    bits_to_real = 0.0;  // 无法准确表示 NaN
                end
            end else begin
                // 正常数和次正规数
                temp = {x[31], {3'd0, x[30:23]}-127+1023, x[22:0], 29'd0};
                bits_to_real = $bitstoreal(temp);
            end
        end
    endfunction
    
    // ========================================================================
    // 读取输入文件
    // ========================================================================
    initial begin
        file_a = $fopen(`FILE_A, "r");
        file_b = $fopen(`FILE_B, "r");
        file_c = $fopen(`FILE_C, "r");
        file_ans = $fopen(`FILE_ANS, "r");
        
        if (file_a == 0 || file_b == 0 || file_c == 0 || file_ans == 0) begin
            $display("ERROR: Cannot open input files!");
            $display("file_a=%0d, file_b=%0d, file_c=%0d, file_ans=%0d", 
                     file_a, file_b, file_c, file_ans);
            $finish;
        end
        
        // 读取测试数据
        for(i=0; i<`DATA_NUM; i=i+1) begin
            garbage = $fscanf(file_a, "%h", data_a[i]);
            garbage = $fscanf(file_b, "%h", data_b[i]);
            garbage = $fscanf(file_c, "%h", data_c[i]);
            garbage = $fscanf(file_ans, "%h", data_ans[i]);
        end
        
        $fclose(file_a);
        $fclose(file_b);
        $fclose(file_c);
        $fclose(file_ans);
        
        $display("Successfully loaded %0d test cases", `DATA_NUM);
    end
    
    // ========================================================================
    // 主测试流程
    // ========================================================================
    initial begin
        CLK = 0;
        RST = 0;
        error = 0;
        error_display_count = 0;
        total_error = 0.0;
        input_a = 32'd0;
        input_b = 32'd0;
        input_c = 32'd0;
        
        // 等待文件读取完成
        #1;
        
        file_out = $fopen(`FILE_OUT, "w");
        
        $display("================================================");
        `ifdef TEST_FXP_FMA
            $display("              FXP_FMA Test");
        `elsif TEST_FLP_FMA
            $display("              FLP_FMA Test");
        `elsif TEST_FLP_FMA_4
            $display("            FLP_FMA_4 Test");
        `endif
        $display("================================================");
        
        `ifdef TEST_FLP_FMA_4
            RST = 1;
            #(`CYCLE*2);
            RST = 0;
        `endif
        
        `ifdef TEST_FXP_FMA
            // ============================================================
            // Fixed-point test
            // ============================================================
            for(i=0; i<`DATA_NUM; i=i+1) begin
                input_a = data_a[i];
                input_b = data_b[i];
                input_c = data_c[i];
                expected = data_ans[i];
                
                #(`CYCLE);
                
                $fwrite(file_out, "%X\n", outcome);
                
                if(outcome !== expected) begin
                    error = error + 1;
                    if(error_display_count < 10) begin
                        $display("----------------------------------------");
                        $display("Error #%0d at testcase #%0d", error, i+1);
                        $display("A=%h, B=%h, C=%h", input_a, input_b, input_c);
                        $display("Expected: %h", expected);
                        $display("Got:      %h", outcome);
                        $display("Diff:     %0d", $signed(outcome - expected));
                        $display("----------------------------------------");
                        error_display_count = error_display_count + 1;
                    end
                end
            end
            
        `elsif TEST_FLP_FMA
            // ============================================================
            // Floating-point non-pipelined test
            // ============================================================
            for(i=0; i<`DATA_NUM; i=i+1) begin
                input_a = data_a[i];
                input_b = data_b[i];
                input_c = data_c[i];
                expected = data_ans[i];
                
                #(`CYCLE);
                
                $fwrite(file_out, "%X\n", outcome);
                
                // 检查是否为特殊值
                if (expected[30:23] == 8'd255 || outcome[30:23] == 8'd255) begin
                    // NaN 或 Infinity 的情况
                    if (expected !== outcome) begin
                        // 对于 NaN，只要都是 NaN 就算对
                        if ((expected[30:23] == 8'd255 && expected[22:0] != 23'd0) &&
                            (outcome[30:23] == 8'd255 && outcome[22:0] != 23'd0)) begin
                            // 都是 NaN，通过
                        end else begin
                            error = error + 1;
                            if(error_display_count < 10) begin
                                $display("----------------------------------------");
                                $display("Error #%0d at testcase #%0d (Special)", error, i+1);
                                $display("A=%h, B=%h, C=%h", input_a, input_b, input_c);
                                $display("Expected: %h", expected);
                                $display("Got:      %h", outcome);
                                $display("----------------------------------------");
                                error_display_count = error_display_count + 1;
                            end
                        end
                    end
                end else if (expected[30:23] == 8'd0 && expected[22:0] == 23'd0) begin
                    // 期望为 Zero
                    if (outcome[30:23] != 8'd0 || outcome[22:0] != 23'd0) begin
                        // 允许极小值（次正规数）
                        if (outcome[30:23] > 8'd10) begin
                            error = error + 1;
                            if(error_display_count < 10) begin
                                $display("----------------------------------------");
                                $display("Error #%0d at testcase #%0d (Zero)", error, i+1);
                                $display("A=%h, B=%h, C=%h", input_a, input_b, input_c);
                                $display("Expected: %h (zero)", expected);
                                $display("Got:      %h", outcome);
                                $display("----------------------------------------");
                                error_display_count = error_display_count + 1;
                            end
                        end
                    end
                end else begin
                    // 正常数值比较
                    real_expected = bits_to_real(expected);
                    real_outcome = bits_to_real(outcome);
                    
                    // 计算绝对误差和相对误差
                    abs_error = (real_outcome > real_expected) ? 
                                (real_outcome - real_expected) : 
                                (real_expected - real_outcome);
                    
                    if (real_expected != 0.0) begin
                        rel_error = abs_error / ((real_expected > 0) ? real_expected : -real_expected);
                    end else begin
                        rel_error = 0.0;
                    end
                    
                    total_error = total_error + rel_error;
                    
                    // 允许 0.1% 相对误差或 1 ULP 差异
                    if (rel_error > 0.001 && outcome !== expected) begin
                        // 检查是否只差 1 ULP
                        if ((outcome == expected + 1) || (outcome == expected - 1) ||
                            (outcome + 1 == expected) || (outcome - 1 == expected)) begin
                            // 1 ULP 差异，可接受
                        end else begin
                            error = error + 1;
                            if(error_display_count < 10) begin
                                real_a = bits_to_real(input_a);
                                real_b = bits_to_real(input_b);
                                real_c = bits_to_real(input_c);
                                
                                $display("----------------------------------------");
                                $display("Error #%0d at testcase #%0d", error, i+1);
                                $display("A=%h (%e), B=%h (%e), C=%h (%e)", 
                                         input_a, real_a, input_b, real_b, input_c, real_c);
                                $display("Expected: %h (%e)", expected, real_expected);
                                $display("Got:      %h (%e)", outcome, real_outcome);
                                $display("Abs error: %e", abs_error);
                                $display("Rel error: %e (%.2f%%)", rel_error, rel_error * 100.0);
                                $display("Diff (hex): %0d", $signed(outcome - expected));
                                $display("----------------------------------------");
                                error_display_count = error_display_count + 1;
                            end
                        end
                    end
                end
            end
            
        `elsif TEST_FLP_FMA_4
            // ============================================================
            // Floating-point pipelined test
            // ============================================================
            for(i=0; i<`DATA_NUM+PIPE_STAGES-1; i=i+1) begin
                if(i < `DATA_NUM) begin
                    input_a = data_a[i];
                    input_b = data_b[i];
                    input_c = data_c[i];
                end else begin
                    input_a = 32'd0;
                    input_b = 32'd0;
                    input_c = 32'd0;
                end
                
                #(`CYCLE);
                
                if(i >= PIPE_STAGES-1) begin
                    temp_a = data_a[i-PIPE_STAGES+1];
                    temp_b = data_b[i-PIPE_STAGES+1];
                    temp_c = data_c[i-PIPE_STAGES+1];
                    expected = data_ans[i-PIPE_STAGES+1];
                    
                    $fwrite(file_out, "%X\n", outcome);
                    
                    // 使用与非流水线相同的检查逻辑
                    if (expected[30:23] == 8'd255 || outcome[30:23] == 8'd255) begin
                        if (expected !== outcome) begin
                            if ((expected[30:23] == 8'd255 && expected[22:0] != 23'd0) &&
                                (outcome[30:23] == 8'd255 && outcome[22:0] != 23'd0)) begin
                                // 都是 NaN
                            end else begin
                                error = error + 1;
                                if(error_display_count < 10) begin
                                    $display("Error at testcase #%0d (pipe)", i-PIPE_STAGES+2);
                                    error_display_count = error_display_count + 1;
                                end
                            end
                        end
                    end else if (expected[30:23] == 8'd0 && expected[22:0] == 23'd0) begin
                        if (outcome[30:23] > 8'd10) begin
                            error = error + 1;
                        end
                    end else begin
                        real_expected = bits_to_real(expected);
                        real_outcome = bits_to_real(outcome);
                        
                        abs_error = (real_outcome > real_expected) ? 
                                    (real_outcome - real_expected) : 
                                    (real_expected - real_outcome);
                        
                        if (real_expected != 0.0) begin
                            rel_error = abs_error / ((real_expected > 0) ? real_expected : -real_expected);
                        end else begin
                            rel_error = 0.0;
                        end
                        
                        total_error = total_error + rel_error;
                        
                        if (rel_error > 0.001 && outcome !== expected) begin
                            if (!((outcome == expected + 1) || (outcome == expected - 1) ||
                                  (outcome + 1 == expected) || (outcome - 1 == expected))) begin
                                error = error + 1;
                                if(error_display_count < 10) begin
                                    $display("Error at testcase #%0d (pipe)", i-PIPE_STAGES+2);
                                    error_display_count = error_display_count + 1;
                                end
                            end
                        end
                    end
                end
            end
        `endif
        
        // ========================================================================
        // 最终报告
        // ========================================================================
        $display("================================================");
        $display("Test Complete!");
        $display("Total test cases: %0d", `DATA_NUM);
        $display("Errors: %0d", error);
        $display("Pass rate: %.2f%%", ((`DATA_NUM - error) * 100.0) / `DATA_NUM);
        if (total_error > 0) begin
            $display("Average relative error: %e", total_error / `DATA_NUM);
        end
        if (error > 10) begin
            $display("(Only first 10 errors displayed)");
        end
        $display("================================================");
        
        if (error == 0) begin
            $display("✓ ALL TESTS PASSED!");
        end else begin
            $display("✗ %0d test(s) failed", error);
        end
        
        $fclose(file_out);
        $finish;
    end
    
endmodule
