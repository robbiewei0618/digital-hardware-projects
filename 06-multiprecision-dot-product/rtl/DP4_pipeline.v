// =============================================================================
// DP4_pipeline - 4-stage pipelined FP32/FP16 fused dot product
//   z = x1*y1 + x2*y2 + x3*y3 + x4*y4      latency 4, throughput 1/cycle
// Datapath in dp4_datapath.v (shared with DP4 and DP4_pipeline_CG).
// =============================================================================
module DP4_pipeline (
    input         clk,
    input         rst_n,
    input  [31:0] x1, x2, x3, x4,
    input  [31:0] y1, y2, y3, y4,
    input         precision,
    output [31:0] z
);

    // -------------------------------------------------------------------------
    // Stage 1 outputs (combinational)
    // -------------------------------------------------------------------------
    wire signed [56:0] sm1_s1, sm2_s1, sm3_s1, sm4_s1;
    wire signed [9:0]  emax_s1;
    wire               sticky_align_s1;

    // -------------------------------------------------------------------------
    // Stage 1: combinational
    // -------------------------------------------------------------------------
    dp4_stage1 u_stage1 (
        .x1(x1), .x2(x2), .x3(x3), .x4(x4),
        .y1(y1), .y2(y2), .y3(y3), .y4(y4),
        .precision(precision),
        .sm1_s1(sm1_s1),
        .sm2_s1(sm2_s1),
        .sm3_s1(sm3_s1),
        .sm4_s1(sm4_s1),
        .emax_s1(emax_s1),
        .sticky_align_s1(sticky_align_s1)
    );

    // -------------------------------------------------------------------------
    // Pipeline reg: Stage1 -> Stage2
    // -------------------------------------------------------------------------
    reg signed [56:0] sm1_s2, sm2_s2, sm3_s2, sm4_s2;
    reg signed [9:0]  emax_s2;
    reg               precision_s2;
    reg               sticky_align_s2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sm1_s2         <= 57'sd0;
            sm2_s2         <= 57'sd0;
            sm3_s2         <= 57'sd0;
            sm4_s2         <= 57'sd0;
            emax_s2        <= 10'sd0;
            precision_s2   <= 1'b0;
            sticky_align_s2<= 1'b0;
        end else begin
            sm1_s2         <= sm1_s1;
            sm2_s2         <= sm2_s1;
            sm3_s2         <= sm3_s1;
            sm4_s2         <= sm4_s1;
            emax_s2        <= emax_s1;
            precision_s2   <= precision;
            sticky_align_s2<= sticky_align_s1;
        end
    end

    // -------------------------------------------------------------------------
    // Stage 2 outputs (combinational)
    // -------------------------------------------------------------------------
    wire signed [58:0] sum_s2;

    // -------------------------------------------------------------------------
    // Stage 2: combinational
    // -------------------------------------------------------------------------
    dp4_stage2 u_stage2 (
        .sm1_s2(sm1_s2),
        .sm2_s2(sm2_s2),
        .sm3_s2(sm3_s2),
        .sm4_s2(sm4_s2),
        .sum_s2(sum_s2)
    );

    // -------------------------------------------------------------------------
    // Pipeline reg: Stage2 -> Stage3
    // -------------------------------------------------------------------------
    reg signed [58:0] sum_s3;
    reg signed [9:0]  emax_s3;
    reg               precision_s3;
    reg               sticky_align_s3;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum_s3          <= 59'sd0;
            emax_s3         <= 10'sd0;
            precision_s3    <= 1'b0;
            sticky_align_s3 <= 1'b0;
        end else begin
            sum_s3          <= sum_s2;
            emax_s3         <= emax_s2;
            precision_s3    <= precision_s2;
            sticky_align_s3 <= sticky_align_s2;
        end
    end

    // -------------------------------------------------------------------------
    // Stage 3 outputs (combinational)
    // -------------------------------------------------------------------------
    wire               sign_s3;
    wire [58:0]        norm_s3;
    wire signed [9:0]  exp_adj_s3;
    wire               is_zero_s3;
    wire               ovf_s3;
    wire               udf_s3;

    // -------------------------------------------------------------------------
    // Stage 3: combinational
    // -------------------------------------------------------------------------
    dp4_stage3 u_stage3 (
        .sum_s3(sum_s3),
        .emax_s3(emax_s3),
        .precision_s3(precision_s3),
        .sign_s3(sign_s3),
        .norm_s3(norm_s3),
        .exp_adj_s3(exp_adj_s3),
        .is_zero_s3(is_zero_s3),
        .ovf_s3(ovf_s3),
        .udf_s3(udf_s3)
    );

    // -------------------------------------------------------------------------
    // Pipeline reg: Stage3 -> Stage4
    // -------------------------------------------------------------------------
    reg [58:0]        norm_s4;
    reg signed [9:0]  exp_adj_s4;
    reg               sign_s4;
    reg               is_zero_s4;
    reg               ovf_s4;
    reg               udf_s4;
    reg               prec_s4;
    reg               sticky_s4;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            norm_s4   <= 59'd0;
            exp_adj_s4<= 10'sd0;
            sign_s4   <= 1'b0;
            is_zero_s4<= 1'b0;
            ovf_s4    <= 1'b0;
            udf_s4    <= 1'b0;
            prec_s4   <= 1'b0;
            sticky_s4 <= 1'b0;
        end else begin
            norm_s4   <= norm_s3;
            exp_adj_s4<= exp_adj_s3;
            sign_s4   <= sign_s3;
            is_zero_s4<= is_zero_s3;
            ovf_s4    <= ovf_s3;
            udf_s4    <= udf_s3;
            prec_s4   <= precision_s3;
            sticky_s4 <= sticky_align_s3;
        end
    end

    // -------------------------------------------------------------------------
    // Stage 4 outputs (combinational)
    // -------------------------------------------------------------------------
    wire [31:0] z_comb;

    // -------------------------------------------------------------------------
    // Stage 4: combinational
    // -------------------------------------------------------------------------
    dp4_stage4 u_stage4 (
        .norm_s4(norm_s4),
        .exp_adj_s4(exp_adj_s4),
        .sign_s4(sign_s4),
        .is_zero_s4(is_zero_s4),
        .ovf_s4(ovf_s4),
        .udf_s4(udf_s4),
        .prec_s4(prec_s4),
        .sticky_s4(sticky_s4),
        .z_comb(z_comb)
    );

    // -------------------------------------------------------------------------
    // Final output register (Stage 4 -> z)
    // -------------------------------------------------------------------------
    reg [31:0] z_reg;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            z_reg <= 32'd0;
        else
            z_reg <= z_comb;
    end

    assign z = z_reg;

endmodule
