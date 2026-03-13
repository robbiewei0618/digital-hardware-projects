// ============================================================
// File: ALU_HW2_FMA_testbench.v
// Modified testbench with proper error checking
// ============================================================

`timescale 1ns/1ps

// Select which module to test
//`define TEST_FXP_FMA
`define TEST_FLP_FMA
//`define TEST_FLP_FMA_4

`define CYCLE 5.0
`define DATA_NUM 200

`define FILE_A "/MasterClass/M133040086_ALU/HW2/a.txt"
`define FILE_B "/MasterClass/M133040086_ALU/HW2/b.txt"
`define FILE_C "/MasterClass/M133040086_ALU/HW2/c.txt"
`define FILE_ANS "/MasterClass/M133040086_ALU/HW2/ans.txt"

module ALU_HW2_FMA_testbench();
    integer file_a, file_b, file_c, file_ans;
    integer garbage, i, flag, error;
    integer error_display_count;
    
    reg CLK, RST;
    reg is_error;  // 移到這裡宣告
    
    reg [31:0] data_a [0:`DATA_NUM-1];
    reg [31:0] data_b [0:`DATA_NUM-1];
    reg [31:0] data_c [0:`DATA_NUM-1];
    reg [31:0] input_a, input_b, input_c;
    reg [31:0] temp_a, temp_b, temp_c;
    
    wire [31:0] outcome;
    reg [31:0] answer;
    reg [63:0] temp_answer;
    reg [63:0] full_answer;
    real real_a, real_b, real_c, real_ans, real_outcome, real_error, total_error;
    
    // Instantiate module
    `ifdef TEST_FXP_FMA
        FXP_FMA test_module(.a(input_a), .b(input_b), .c(input_c), .d(outcome));
       
    `elsif TEST_FLP_FMA
        FLP_FMA test_module(.a(input_a), .b(input_b), .c(input_c), .d(outcome));
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
    
    initial begin
        // Read input files
        file_a = $fopen(`FILE_A, "r");
        file_b = $fopen(`FILE_B, "r");
        file_c = $fopen(`FILE_C, "r");
        
        if (file_a == 0 || file_b == 0 || file_c == 0) begin
            $display("ERROR: Cannot open input files!");
            $finish;
        end
        
        for(i=0; i<`DATA_NUM; i=i+1) begin
            garbage = $fscanf(file_a, "%X", data_a[i]);
            garbage = $fscanf(file_b, "%X", data_b[i]);
            garbage = $fscanf(file_c, "%X", data_c[i]);
        end
        
        $fclose(file_a);
        $fclose(file_b);
        $fclose(file_c);
    end
    
    initial begin
        CLK = 0;
        RST = 0;
        flag = 0;
        error = 0;
        error_display_count = 0;
        is_error = 0;
        input_a = 32'd0;
        input_b = 32'd0;
        input_c = 32'd0;
        
        file_ans = $fopen(`FILE_ANS, "w");
        
        $display("-----------------------------------------");
        `ifdef TEST_FXP_FMA
            $display("-              FXP_FMA                  -");
        `elsif TEST_FLP_FMA
            $display("-              FLP_FMA                  -");
        `elsif TEST_FLP_FMA_4
            $display("-            FLP_FMA_4                  -");
        `endif
        $display("-----------------------------------------");
        
        `ifdef TEST_FLP_FMA_4
            RST = 1;
            #(`CYCLE*2);
            RST = 0;
        `endif
        
        `ifdef TEST_FXP_FMA
            // Fixed-point test
            for(i=0; i<`DATA_NUM; i=i+1) begin
                input_a = data_a[i];
                input_b = data_b[i];
                input_c = data_c[i];
                
                #(`CYCLE);
                
                $fwrite(file_ans, "%X\n", outcome);
                
                full_answer = ($signed(input_a) * $signed(input_b)) + {{32{input_c[31]}}, input_c};
                
                if(full_answer[63:32] !== outcome) begin
                    error = error + 1;
                    if(error_display_count < 100) begin
                        $display("-----------------------------------------");
                        $display("Error #%d at testcase #%d", error, i+1);
                        $display("A=%X, B=%X, C=%X", input_a, input_b, input_c);
                        $display("Expected: %X, Got: %X", full_answer[63:32], outcome);
                        $display("-----------------------------------------");
                        error_display_count = error_display_count + 1;
                    end
                end
            end
            
            $display("-----------------------------------------");
            if (error == 0) begin
                $display("All tests passed!");
            end else begin
                $display("Total errors: %d / %d", error, `DATA_NUM);
                if (error > 100)
                    $display("(Only first 100 errors displayed)");
            end
            $display("-----------------------------------------");
            
        `elsif TEST_FLP_FMA
            // Floating-point non-pipelined test
            total_error = 0;
            
            for(i=0; i<`DATA_NUM; i=i+1) begin
                input_a = data_a[i];
                input_b = data_b[i];
                input_c = data_c[i];
                
                real_a = $bitstoreal({input_a[31], {3'd0, input_a[30:23]}-127+1023, input_a[22:0], 29'd0});
                real_b = $bitstoreal({input_b[31], {3'd0, input_b[30:23]}-127+1023, input_b[22:0], 29'd0});
                real_c = $bitstoreal({input_c[31], {3'd0, input_c[30:23]}-127+1023, input_c[22:0], 29'd0});
                
                real_ans = real_a * real_b + real_c;
                temp_answer = $realtobits(real_ans);
                answer = {temp_answer[63], temp_answer[62:52]-1023+127, temp_answer[51:29]};
                
                if(temp_answer[28] && ((|temp_answer[27:0]) || (answer%2==1)))
                    answer = answer + 1;
                
                #(`CYCLE);
                
                $fwrite(file_ans, "%X\n", outcome);
                
                real_outcome = $bitstoreal({outcome[31], {3'd0, outcome[30:23]}-127+1023, outcome[22:0], 29'd0});
                
                // Calculate relative error
                if(real_ans != 0) begin
                    real_error = (real_outcome > real_ans) ? 
                                ((real_outcome - real_ans) / real_ans) : 
                                ((real_ans - real_outcome) / real_ans);
                    total_error = real_error*(1.0/(i+1.0)) + total_error*(i*1.0/(i+1.0));
                end else begin
                    real_error = 0;
                end
                
                // Check error using relative tolerance
                is_error = 0;
                
                if(real_ans != 0) begin
                    // Allow 0.1% relative error
                    if(real_error > 0.001) begin
                        is_error = 1;
                    end
                end else begin
                    // If answer should be 0, check if outcome is close to 0
                    if((outcome[30:23] > 8'd10) || (|outcome[22:0])) begin
                        is_error = 1;
                    end
                end
                
                if(is_error) begin
                    error = error + 1;
                    if(error_display_count < 100) begin
                        $display("-----------------------------------------");
                        $display("Error #%d at testcase #%d", error, i+1);
                        $display("A=%X, B=%X, C=%X", input_a, input_b, input_c);
                        $display("Expected: %X, Got: %X, Diff: %d", answer, outcome, $signed(answer-outcome));
                        $display("Real: A=%e, B=%e, C=%e", real_a, real_b, real_c);
                        $display("A*B+C (real) = %e", real_ans);
                        $display("Expected(real)=%e, Got(real)=%e", real_ans, real_outcome);
                        $display("Relative error: %e", real_error);
                        $display("-----------------------------------------");
                        error_display_count = error_display_count + 1;
                    end
                end
            end
            
            $display("-----------------------------------------");
            $display("Score: %3d", 100-error);
            $display("Avg error: %e", total_error);
            if (error > 100)
                $display("(Only first 100 errors displayed)");
            $display("-----------------------------------------");
            
        `elsif TEST_FLP_FMA_4
            // Floating-point pipelined test
            total_error = 0;
            
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
                    
                    real_a = $bitstoreal({temp_a[31], {3'd0, temp_a[30:23]}-127+1023, temp_a[22:0], 29'd0});
                    real_b = $bitstoreal({temp_b[31], {3'd0, temp_b[30:23]}-127+1023, temp_b[22:0], 29'd0});
                    real_c = $bitstoreal({temp_c[31], {3'd0, temp_c[30:23]}-127+1023, temp_c[22:0], 29'd0});
                    
                    real_ans = real_a * real_b + real_c;
                    temp_answer = $realtobits(real_ans);
                    answer = {temp_answer[63], temp_answer[62:52]-1023+127, temp_answer[51:29]};
                    
                    if(temp_answer[28] && ((|temp_answer[27:0]) || (answer%2==1)))
                        answer = answer + 1;
                    
                    $fwrite(file_ans, "%X\n", outcome);
                    
                    real_outcome = $bitstoreal({outcome[31], {3'd0, outcome[30:23]}-127+1023, outcome[22:0], 29'd0});
                    
                    // Calculate relative error
                    if(real_ans != 0) begin
                        real_error = (real_outcome > real_ans) ? 
                                    ((real_outcome - real_ans) / real_ans) : 
                                    ((real_ans - real_outcome) / real_ans);
                        total_error = real_error*(1.0/(i-PIPE_STAGES+2.0)) + 
                                     total_error*((i-PIPE_STAGES+1.0)/(i-PIPE_STAGES+2.0));
                    end else begin
                        real_error = 0;
                    end
                    
                    // Check error using relative tolerance
                    is_error = 0;
                    
                    if(real_ans != 0) begin
                        // Allow 0.1% relative error
                        if(real_error > 0.001) begin
                            is_error = 1;
                        end
                    end else begin
                        // If answer should be 0, check if outcome is close to 0
                        if((outcome[30:23] > 8'd10) || (|outcome[22:0])) begin
                            is_error = 1;
                        end
                    end
                    
                    if(is_error) begin
                        error = error + 1;
                        if(error_display_count < 100) begin
                            $display("-----------------------------------------");
                            $display("Error #%d at testcase #%d", error, i-PIPE_STAGES+2);
                            $display("A=%X, B=%X, C=%X", temp_a, temp_b, temp_c);
                            $display("Expected: %X, Got: %X, Diff: %d", answer, outcome, $signed(answer-outcome));
                            $display("Real: A=%e, B=%e, C=%e", real_a, real_b, real_c);
                            $display("A*B+C (real) = %e", real_ans);
                            $display("Expected(real)=%e, Got(real)=%e", real_ans, real_outcome);
                            $display("Relative error: %e", real_error);
                            $display("-----------------------------------------");
                            error_display_count = error_display_count + 1;
                        end
                    end
                end
            end
            
            $display("-----------------------------------------");
            $display("Score: %3d", 100-error);
            $display("Avg error: %e", total_error);
            if (error > 100)
                $display("(Only first 100 errors displayed)");
            $display("-----------------------------------------");
        `endif
        
        $fclose(file_ans);
        $finish;
    end
    
endmodule