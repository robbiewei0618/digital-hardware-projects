// ============================================================
// File: DP4_testbench.v
// Description: Universal testbench for DP4 (Dot Product of 4D vectors)
// Supports: Non-pipelined / Pipelined / Clock-gating versions
// Precision: FP32 (single-precision) and FP16 (half-precision)
// ============================================================

`timescale 1ns/1ps

// ============================================================
// Configuration Section - Select test configuration
// ============================================================

// Step 1: Select which module to test (uncomment ONE)
`define TEST_DP4              // Non-pipelined version
//`define TEST_DP4_PIPELINE   // Pipelined version (4 stages)
//`define TEST_DP4_CG         // Clock-gating version (4 stages)

// Step 2: Select precision (uncomment ONE)
//`define TEST_FP32             // Test single-precision (32-bit)
`define TEST_FP16           // Test half-precision (16-bit)

// Step 3: Cycle time and data count
`define CYCLE 10.0            // Clock period (ns)
`define DATA_NUM 1000         // Number of test vectors

// Step 4: File paths (modify according to your environment)
`ifdef TEST_FP32
    `define FILE_INPUT "/MasterClass/M133040086_ALU/HW3/FP32.txt"
    `define FILE_ANS   "/MasterClass/M133040086_ALU/HW3/ans32.txt"
`else
    `define FILE_INPUT "/MasterClass/M133040086_ALU/HW3/FP16.txt"
    `define FILE_ANS   "/MasterClass/M133040086_ALU/HW3/ans16.txt"
`endif

// ============================================================
// Main Testbench Module
// ============================================================

module DP4_testbench();
    // File handles
    integer file_input, file_ans;
    integer garbage, i, j;
    integer error, error_display_count;
    
    // Clock and reset (for pipelined versions)
    reg CLK, RST_N;
    
    // Input data storage
    reg [31:0] data_x1 [0:`DATA_NUM-1];
    reg [31:0] data_x2 [0:`DATA_NUM-1];
    reg [31:0] data_x3 [0:`DATA_NUM-1];
    reg [31:0] data_x4 [0:`DATA_NUM-1];
    reg [31:0] data_y1 [0:`DATA_NUM-1];
    reg [31:0] data_y2 [0:`DATA_NUM-1];
    reg [31:0] data_y3 [0:`DATA_NUM-1];
    reg [31:0] data_y4 [0:`DATA_NUM-1];
    reg [31:0] data_ans [0:`DATA_NUM-1];
    
    // Input/output signals
    reg  [31:0] x1, x2, x3, x4;
    reg  [31:0] y1, y2, y3, y4;
    reg         precision;
    wire [31:0] z;
    
    // For checking
    reg  [31:0] expected;
    
    // ============================================================
    // Module Instantiation
    // ============================================================
    
    `ifdef TEST_DP4
        // Non-pipelined version
        DP4 dut (
            .x1(x1), .x2(x2), .x3(x3), .x4(x4),
            .y1(y1), .y2(y2), .y3(y3), .y4(y4),
            .precision(precision),
            .z(z)
        );
        localparam PIPE_STAGES = 0;
        
    `elsif TEST_DP4_PIPELINE
        // Pipelined version
        DP4_pipeline dut (
            .clk(CLK),
            .rst_n(RST_N),
            .x1(x1), .x2(x2), .x3(x3), .x4(x4),
            .y1(y1), .y2(y2), .y3(y3), .y4(y4),
            .precision(precision),
            .z(z)
        );
        localparam PIPE_STAGES = 3;
        
    `elsif TEST_DP4_CG
        // Clock-gating version
        DP4_pipeline_CG dut (
            .clk(CLK),
            .rst_n(RST_N),
            .x1(x1), .x2(x2), .x3(x3), .x4(x4),
            .y1(y1), .y2(y2), .y3(y3), .y4(y4),
            .precision(precision),
            .z(z)
        );
        localparam PIPE_STAGES = 3;
    `endif
    
    // ============================================================
    // SDF Annotation (for post-synthesis simulation)
    // ============================================================
    `ifdef SDF_FILE
        initial $sdf_annotate(`SDF_FILE, dut);
    `endif
    
    // ============================================================
    // Clock Generation (for pipelined versions)
    // ============================================================
    `ifdef TEST_DP4_PIPELINE
        initial CLK = 0;
        always #(`CYCLE/2) CLK = ~CLK;
    `elsif TEST_DP4_CG
        initial CLK = 0;
        always #(`CYCLE/2) CLK = ~CLK;
    `endif
    
    // ============================================================
    // Read Input Files
    // ============================================================
    initial begin
        file_input = $fopen(`FILE_INPUT, "r");
        
        if (file_input == 0) begin
            $display("ERROR: Cannot open input file: %s", `FILE_INPUT);
            $finish;
        end
        
        for(i=0; i<`DATA_NUM; i=i+1) begin
            garbage = $fscanf(file_input, "%h %h %h %h %h %h %h %h\n",
                             data_x1[i], data_x2[i], data_x3[i], data_x4[i],
                             data_y1[i], data_y2[i], data_y3[i], data_y4[i]);
            
            // ===== FP16 數據位置調整：從 [15:0] 移到 [31:16] =====
            `ifdef TEST_FP16
                data_x1[i] = {data_x1[i][15:0], 16'h0000};
                data_x2[i] = {data_x2[i][15:0], 16'h0000};
                data_x3[i] = {data_x3[i][15:0], 16'h0000};
                data_x4[i] = {data_x4[i][15:0], 16'h0000};
                data_y1[i] = {data_y1[i][15:0], 16'h0000};
                data_y2[i] = {data_y2[i][15:0], 16'h0000};
                data_y3[i] = {data_y3[i][15:0], 16'h0000};
                data_y4[i] = {data_y4[i][15:0], 16'h0000};
            `endif
            // =====================================================
            
            if (garbage != 8) begin
                $display("WARNING: Line %0d has incomplete data (read %0d values)", i+1, garbage);
            end
        end
        
        $fclose(file_input);
        $display("[INFO] Loaded %0d test vectors from %s", `DATA_NUM, `FILE_INPUT);
    end
    
    // ============================================================
    // Read Answer File
    // ============================================================
    initial begin
        #1;
        
        file_ans = $fopen(`FILE_ANS, "r");
        
        if (file_ans == 0) begin
            $display("ERROR: Cannot open answer file: %s", `FILE_ANS);
            $finish;
        end
        
        for(i=0; i<`DATA_NUM; i=i+1) begin
            `ifdef TEST_FP32
                garbage = $fscanf(file_ans, "dec %*e  float32 %h\n", data_ans[i]);
            `else
                garbage = $fscanf(file_ans, "dec %*e  float16 %h\n", data_ans[i]);
                data_ans[i] = {data_ans[i][15:0], 16'h0000};
            `endif
            
            if (garbage != 1) begin
                $display("WARNING: Cannot read answer at line %0d", i+1);
            end
        end
        
        $fclose(file_ans);
        $display("[INFO] Loaded %0d answers from %s", `DATA_NUM, `FILE_ANS);
    end
    
    // ============================================================
    // Main Test Process
    // ============================================================
    initial begin
        // Initialize
        CLK = 0;
        RST_N = 0;
        error = 0;
        error_display_count = 0;
        x1 = 32'd0;
        x2 = 32'd0;
        x3 = 32'd0;
        x4 = 32'd0;
        y1 = 32'd0;
        y2 = 32'd0;
        y3 = 32'd0;
        y4 = 32'd0;
        
        // Set precision
        `ifdef TEST_FP32
            precision = 1'b0;
        `else
            precision = 1'b1;
        `endif
        
        #10;
        
        // Print header
        $display("============================================================");
        `ifdef TEST_DP4
            $display("  Testing: DP4 (Non-pipelined)");
        `elsif TEST_DP4_PIPELINE
            $display("  Testing: DP4_pipeline (4-stage pipeline)");
        `elsif TEST_DP4_CG
            $display("  Testing: DP4_pipeline_CG (Clock-gating)");
        `endif
        
        `ifdef TEST_FP32
            $display("  Precision: FP32 (Single-precision, 32-bit)");
        `else
            $display("  Precision: FP16 (Half-precision, 16-bit)");
        `endif
        
        $display("  Test vectors: %0d", `DATA_NUM);
        $display("  Pipeline stages: %0d", PIPE_STAGES);
        $display("============================================================");
        
        // Reset sequence
        `ifdef TEST_DP4_PIPELINE
            RST_N = 0;
            repeat(3) @(posedge CLK);
            RST_N = 1;
            $display("[INFO] Reset completed");
        `elsif TEST_DP4_CG
            RST_N = 0;
            repeat(3) @(posedge CLK);
            RST_N = 1;
            $display("[INFO] Reset completed");
        `endif
        
        // ============================================================
        // Test Loop
        // ============================================================
        `ifdef TEST_DP4
            // Non-pipelined test
            for(i=0; i<`DATA_NUM; i=i+1) begin
                x1 = data_x1[i];
                x2 = data_x2[i];
                x3 = data_x3[i];
                x4 = data_x4[i];
                y1 = data_y1[i];
                y2 = data_y2[i];
                y3 = data_y3[i];
                y4 = data_y4[i];
                
                #(`CYCLE);
                
                expected = data_ans[i];
                
                `ifdef TEST_FP32
                    if (z !== expected) begin
                        error = error + 1;
                        if (error_display_count < 300) begin
                            $display("----------------------------------------------------");
                            $display("[ERROR #%0d] Test #%0d failed", error, i+1);
                            $display("  Input x: %h %h %h %h", x1, x2, x3, x4);
                            $display("  Input y: %h %h %h %h", y1, y2, y3, y4);
                            $display("  Expected: %h", expected);
                            $display("  Got:      %h", z);
                            $display("  Diff:     %h", z ^ expected);
                            $display("----------------------------------------------------");
                            error_display_count = error_display_count + 1;
                        end
                    end
                `else
                    if (z[31:16] !== expected[31:16]) begin
                        error = error + 1;
                        if (error_display_count < 300) begin
                            $display("----------------------------------------------------");
                            $display("[ERROR #%0d] Test #%0d failed", error, i+1);
                            $display("  Input x: %h %h %h %h", x1[31:16], x2[31:16], x3[31:16], x4[31:16]);
                            $display("  Input y: %h %h %h %h", y1[31:16], y2[31:16], y3[31:16], y4[31:16]);
                            $display("  Expected: %h", expected[31:16]);
                            $display("  Got:      %h", z[31:16]);
                            $display("  Diff:     %h", z[31:16] ^ expected[31:16]);
                            $display("----------------------------------------------------");
                            error_display_count = error_display_count + 1;
                        end
                    end
                `endif
                
                if ((i+1) % 300 == 0) begin
                    $display("[INFO] Progress: %0d/%0d tests completed", i+1, `DATA_NUM);
                end
            end
            
        `else
            // ========================================================
            // Pipelined test - Single unified loop
            // ========================================================
            
            for(i=0; i<(`DATA_NUM + PIPE_STAGES); i=i+1) begin
                // ===== STEP 1: Apply inputs BEFORE clock edge =====
                if (i < `DATA_NUM) begin
                    // Feed test data
                    x1 = data_x1[i];
                    x2 = data_x2[i];
                    x3 = data_x3[i];
                    x4 = data_x4[i];
                    y1 = data_y1[i];
                    y2 = data_y2[i];
                    y3 = data_y3[i];
                    y4 = data_y4[i];
                end else begin
                    // Flush pipeline with zeros
                    x1 = 32'd0;
                    x2 = 32'd0;
                    x3 = 32'd0;
                    x4 = 32'd0;
                    y1 = 32'd0;
                    y2 = 32'd0;
                    y3 = 32'd0;
                    y4 = 32'd0;
                end
                
                // ===== STEP 2: Wait for clock edge =====
                @(posedge CLK);
                // ===== STEP 3: Wait for non-blocking assignments =====
                #1;
                
                // ===== STEP 4: Check output (after PIPE_STAGES cycles) =====
                if (i >= PIPE_STAGES) begin
                    j = i - PIPE_STAGES;
                    expected = data_ans[j];
                    
                    `ifdef TEST_FP32
                        if (z !== expected) begin
                            error = error + 1;
                            if (error_display_count < 300) begin
                                $display("----------------------------------------------------");
                                $display("[ERROR #%0d] Test #%0d failed (cycle %0d)", error, j+1, i);
                                $display("  Input x: %h %h %h %h", data_x1[j], data_x2[j], data_x3[j], data_x4[j]);
                                $display("  Input y: %h %h %h %h", data_y1[j], data_y2[j], data_y3[j], data_y4[j]);
                                $display("  Expected: %h", expected);
                                $display("  Got:      %h", z);
                                $display("  Diff:     %h", z ^ expected);
                                $display("----------------------------------------------------");
                                error_display_count = error_display_count + 1;
                            end
                        end
                    `else
                        if (z[31:16] !== expected[31:16]) begin
                            error = error + 1;
                            if (error_display_count < 300) begin
                                $display("----------------------------------------------------");
                                $display("[ERROR #%0d] Test #%0d failed (cycle %0d)", error, j+1, i);
                                $display("  Input x: %h %h %h %h", data_x1[j][31:16], data_x2[j][31:16], data_x3[j][31:16], data_x4[j][31:16]);
                                $display("  Input y: %h %h %h %h", data_y1[j][31:16], data_y2[j][31:16], data_y3[j][31:16], data_y4[j][31:16]);
                                $display("  Expected: %h", expected[31:16]);
                                $display("  Got:      %h", z[31:16]);
                                $display("  Diff:     %h", z[31:16] ^ expected[31:16]);
                                $display("----------------------------------------------------");
                                error_display_count = error_display_count + 1;
                            end
                        end
                    `endif
                    
                    if ((j+1) % 300 == 0) begin
                        $display("[INFO] Progress: %0d/%0d tests completed", j+1, `DATA_NUM);
                    end
                end
            end
        `endif
        
        // ============================================================
        // Final Report
        // ============================================================
        $display("============================================================");
        $display("  Test Summary");
        $display("============================================================");
        $display("  Total tests:  %0d", `DATA_NUM);
        $display("  Passed:       %0d", `DATA_NUM - error);
        $display("  Failed:       %0d", error);
        
        if (error == 0) begin
            $display("");
            $display("  *** ALL TESTS PASSED! ***");
            $display("");
        end else begin
            $display("");
            $display("  *** %0d TESTS FAILED ***", error);
            if (error > 300) begin
                $display("  (Only first 100 errors displayed)");
            end
            $display("");
        end
        
        $display("  Pass rate:    %.2f%%", ((`DATA_NUM - error) * 100.0) / `DATA_NUM);
        $display("============================================================");
        
        $finish;
    end
    
    // ============================================================
    // Timeout Protection
    // ============================================================
    initial begin
        #(`CYCLE * (`DATA_NUM * 3));
        $display("ERROR: Simulation timeout!");
        $finish;
    end
    
endmodule