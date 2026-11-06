`timescale 1ns/100ps
module testbench;

    parameter width = 32;
    reg [width-1:0] a, b;
    reg ci, clk;
    wire [width-1:0] s_structure, s_dataflow, s_behavior;
    wire [width-1:0] s_structure_reg, s_dataflow_reg, s_behavior_reg;
    wire co_structure, co_dataflow, co_behavior;
    wire co_structure_reg, co_dataflow_reg, co_behavior_reg;

    reg [width:0] expected_sum;  // Store the expected sum with carry-out
    integer i;

    // Instantiate the six adder designs
    adder_structure_reg U1 (s_structure_reg, co_structure_reg, a, b, ci, clk);
    adder_dataflow_reg  U2 (s_dataflow_reg, co_dataflow_reg, a, b, ci, clk);
    adder_behavior_reg  U3 (s_behavior_reg, co_behavior_reg, a, b, ci, clk);

    RCA_32bit U4 (s_structure, co_structure, a, b, ci);//structure
    adder_dataflow U5 (s_dataflow, co_dataflow, a, b, ci);
    adder_behavior U6 (s_behavior, co_behavior, a, b, ci, clk);

    initial $sdf_annotate("/home/M133040086_HDL/structure_reg/adder_structure_reg.sdf" , U1);
    initial $sdf_annotate("/home/M133040086_HDL/dataflow_reg/adder_dataflow_reg.sdf" , U2);
    initial $sdf_annotate("/home/M133040086_HDL/behavior_reg/adder_behavior_reg.sdf" , U3);
    initial $sdf_annotate("/home/M133040086_HDL/structure/adder_structure.sdf" , U4);
    initial $sdf_annotate("/home/M133040086_HDL/dataflow/adder_dataflow.sdf" , U5);
    initial $sdf_annotate("/home/M133040086_HDL/behavior/adder_behavior.sdf" , U6);


    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10 time units clock period
    end

    // Testbench logic
    initial begin
        $display("Starting testbench simulation...");

        for (i = 0; i < 10; i = i + 1) begin
            // Generate random test patterns for a, b, and ci
            a = {$random}%10;
            b = {$random}%10;
            ci = {$random} % 2;

            // Calculate the expected result using the Verilog + operator
            expected_sum = a + b + ci;

            // Wait for one clock cycle to capture results from reg versions
            @(posedge clk);
            #(1);
            // Compare the results with the expected values
            if ({co_structure, s_structure} !== expected_sum)
                $display("Mismatch in adder_structure at pattern %0d: Expected %0h, Got %0h", i, expected_sum, {co_structure, s_structure});
            
            if ({co_dataflow, s_dataflow} !== expected_sum)
                $display("Mismatch in adder_dataflow at pattern %0d: Expected %0h, Got %0h", i, expected_sum, {co_dataflow, s_dataflow});
            
            if ({co_behavior, s_behavior} !== expected_sum)
                $display("Mismatch in adder_behavior at pattern %0d: Expected %0h, Got %0h", i, expected_sum, {co_behavior, s_behavior});

            if ({co_structure_reg, s_structure_reg} !== expected_sum)
                $display("Mismatch in adder_structure_reg at pattern %0d: Expected %0h, Got %0h", i, expected_sum, {co_structure_reg, s_structure_reg});
            
            if ({co_dataflow_reg, s_dataflow_reg} !== expected_sum)
                $display("Mismatch in adder_dataflow_reg at pattern %0d: Expected %0h, Got %0h", i, expected_sum, {co_dataflow_reg, s_dataflow_reg});
            
            if ({co_behavior_reg, s_behavior_reg} !== expected_sum)
                $display("Mismatch in adder_behavior_reg at pattern %0d: Expected %0h, Got %0h", i, expected_sum, {co_behavior_reg, s_behavior_reg});

            // Display success message for the current test pattern
            $display("Test pattern %0d passed.", i);
        end

        $display("All test patterns completed.");
        $finish;
    end

endmodule
