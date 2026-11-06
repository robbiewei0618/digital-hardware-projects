//==============================================================================
// Module: DP4_pipeline_CG - Clock-Gated 4-Stage Pipelined FP Dot Product
// Description: z = x1*y1 + x2*y2 + x3*y3 + x4*y4
// Pipeline: 4 stages with clock gating for power optimization
// Latency: 4 cycles (with input register, without output register)
// 
// Clock Gating Strategy:
// - 24x24 multiplier split into 4 x 12x12 multipliers
// - FP16: m_x[11:0] = 0 from unpack, so HL/LH/LL inputs are 0 -> no switching
// - FP32: All 4 x 12x12 multipliers active
// - Register clock gating for power reduction
//==============================================================================

module DP4_pipeline_CG (
    input         clk,
    input         rst_n,
    input  [31:0] x1, x2, x3, x4,
    input  [31:0] y1, y2, y3, y4,
    input         precision,
    output [31:0] z
);

    // =========================================================================
    // Clock Gating Control Logic with Pipeline Valid Tracking
    // =========================================================================
    // Description: z = x1*y1 + x2*y2 + x3*y3 + x4*y4
    wire current_inputs_active = (x1 != 32'd0) || (x2 != 32'd0) || (x3 != 32'd0) || (x4 != 32'd0) ||
                                 (y1 != 32'd0) || (y2 != 32'd0) || (y3 != 32'd0) || (y4 != 32'd0);
    
    reg valid_s1, valid_s2, valid_s3, valid_s4;//pipeline 內的「還有沒有東西在跑」
    
    reg precision_pipe_s1, precision_pipe_s2, precision_pipe_s3;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_s1 <= 1'b0;
            valid_s2 <= 1'b0;
            valid_s3 <= 1'b0;
            valid_s4 <= 1'b0;
            precision_pipe_s1 <= 1'b0;
            precision_pipe_s2 <= 1'b0;
            precision_pipe_s3 <= 1'b0;
        end else begin
            valid_s1 <= current_inputs_active;
            valid_s2 <= valid_s1;
            valid_s3 <= valid_s2;
            valid_s4 <= valid_s3;
            precision_pipe_s1 <= precision;
            precision_pipe_s2 <= precision_pipe_s1;
            precision_pipe_s3 <= precision_pipe_s2;
        end
    end
    
    wire pipeline_active = current_inputs_active || valid_s1 || valid_s2 || valid_s3 || valid_s4;
    //current_inputs_active = 0

    //valid_s1~s4 全部 = 0

    // pipeline 才能完全 clock-gate 掉
    // =========================================================================
    // Precision-based Clock Gating Enables
    // =========================================================================
    //*_all：不管 FP16 / FP32 都要用
    //*_fp32：只有 FP32 才會用，FP16 時關掉
    //precision=1
    wire enable_s1_all   = pipeline_active;//Stage 1 這一級，只要 pipeline 有資料，就要開
    wire enable_s1_fp32  = pipeline_active & ~precision;
    
    wire enable_s2_all   = pipeline_active;
    wire enable_s2_fp32  = pipeline_active & ~precision_pipe_s1;
    
    wire enable_s3_all   = pipeline_active;
    wire enable_s3_fp32  = pipeline_active & ~precision_pipe_s2;
    
    wire enable_s4_all   = pipeline_active;
    wire enable_s4_fp32  = pipeline_active & ~precision_pipe_s3;

    // =========================================================================
    // Stage-to-stage pipeline wires
    // =========================================================================
    wire signed [56:0] sm1_s2, sm2_s2, sm3_s2, sm4_s2;
    wire signed [9:0]  emax_s2;
    wire               precision_s2;

    wire signed [58:0] sum_s3;
    wire signed [9:0]  emax_s3;
    wire               precision_s3;

    wire [58:0]        normalized_s4;
    wire [7:0]         exp_adjusted_s4;
    wire               sign_result_s4;
    wire               result_zero_s4;
    wire               overflow_s4;
    wire               precision_s4;

    // =========================================================================
    // Stage1: input reg + unpack/mul/align + reg to Stage2
    // =========================================================================
    stage1 u_stage1 (
        .clk          (clk),
        .rst_n        (rst_n),
        .enable_all   (enable_s1_all),
        .enable_fp32  (enable_s1_fp32),
        .x1           (x1),
        .x2           (x2),
        .x3           (x3),
        .x4           (x4),
        .y1           (y1),
        .y2           (y2),
        .y3           (y3),
        .y4           (y4),
        .precision_in (precision),
        .sm1_s2       (sm1_s2),
        .sm2_s2       (sm2_s2),
        .sm3_s2       (sm3_s2),
        .sm4_s2       (sm4_s2),
        .emax_s2      (emax_s2),
        .precision_s2 (precision_s2)
    );

    // =========================================================================
    // Stage2: multi-operand addition + reg to Stage3
    // =========================================================================
    stage2 u_stage2 (
        .clk             (clk),
        .rst_n           (rst_n),
        .enable_all      (enable_s2_all),
        .enable_fp32     (enable_s2_fp32),
        .sm1_s2_in       (sm1_s2),
        .sm2_s2_in       (sm2_s2),
        .sm3_s2_in       (sm3_s2),
        .sm4_s2_in       (sm4_s2),
        .emax_s2_in      (emax_s2),
        .precision_s2_in (precision_s2),
        .sum_s3          (sum_s3),
        .emax_s3         (emax_s3),
        .precision_s3    (precision_s3)
    );

    // =========================================================================
    // Stage3: sign-magnitude, LOD, normalization + reg to Stage4
    // =========================================================================
    stage3 u_stage3 (
        .clk             (clk),
        .rst_n           (rst_n),
        .enable_all      (enable_s3_all),
        .enable_fp32     (enable_s3_fp32),
        .sum_s3_in       (sum_s3),
        .emax_s3_in      (emax_s3),
        .precision_s3_in (precision_s3),
        .normalized_s4   (normalized_s4),
        .exp_adjusted_s4 (exp_adjusted_s4),
        .sign_result_s4  (sign_result_s4),
        .result_zero_s4  (result_zero_s4),
        .overflow_s4     (overflow_s4),
        .precision_s4    (precision_s4)
    );

    // =========================================================================
    // Stage4: rounding + packing (pure combinational)
    // =========================================================================
    stage4 u_stage4 (
        .normalized_s4   (normalized_s4),
        .exp_adjusted_s4 (exp_adjusted_s4),
        .sign_result_s4  (sign_result_s4),
        .result_zero_s4  (result_zero_s4),
        .overflow_s4     (overflow_s4),
        .precision_s4    (precision_s4),
        .z               (z)
    );

endmodule

//==============================================================================
// Stage 1 - With Sub-word Parallel Multipliers (4 x 12x12)
// No extra latches - FP16 naturally has m_x[11:0]=0 from unpack
//==============================================================================
//unpack sign / exponent / mantissa

//exponent 相加

//mantissa unsigned 乘法

//對齊到 max exponent

//轉成 signed fixed-point
module stage1 (
    input         clk,
    input         rst_n,
    input         enable_all,
    input         enable_fp32,
    input  [31:0] x1, x2, x3, x4,
    input  [31:0] y1, y2, y3, y4,
    input         precision_in,
    output signed [56:0] sm1_s2, sm2_s2, sm3_s2, sm4_s2,
    output signed [9:0]  emax_s2,
    output               precision_s2
);

    // =========================================================================
    // Input Registers - Split HIGH/LOW for clock gating
    // =========================================================================
    
    reg [15:0] x1_s1_hi, x2_s1_hi, x3_s1_hi, x4_s1_hi;
    reg [15:0] y1_s1_hi, y2_s1_hi, y3_s1_hi, y4_s1_hi;
    reg        precision_s1;
    
    reg [15:0] x1_s1_lo, x2_s1_lo, x3_s1_lo, x4_s1_lo;
    reg [15:0] y1_s1_lo, y2_s1_lo, y3_s1_lo, y4_s1_lo;
    
    // HIGH part - FP16/FP32 shared
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            x1_s1_hi <= 16'd0; x2_s1_hi <= 16'd0; x3_s1_hi <= 16'd0; x4_s1_hi <= 16'd0;
            y1_s1_hi <= 16'd0; y2_s1_hi <= 16'd0; y3_s1_hi <= 16'd0; y4_s1_hi <= 16'd0;
            precision_s1 <= 1'b0;
        end else if (enable_all) begin
            x1_s1_hi <= x1[31:16]; x2_s1_hi <= x2[31:16]; x3_s1_hi <= x3[31:16]; x4_s1_hi <= x4[31:16];
            y1_s1_hi <= y1[31:16]; y2_s1_hi <= y2[31:16]; y3_s1_hi <= y3[31:16]; y4_s1_hi <= y4[31:16];
            precision_s1 <= precision_in;
        end
    end
    
    // LOW part - FP32 only (frozen in FP16)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            x1_s1_lo <= 16'd0; x2_s1_lo <= 16'd0; x3_s1_lo <= 16'd0; x4_s1_lo <= 16'd0;
            y1_s1_lo <= 16'd0; y2_s1_lo <= 16'd0; y3_s1_lo <= 16'd0; y4_s1_lo <= 16'd0;
        end else if (enable_fp32) begin
            x1_s1_lo <= x1[15:0]; x2_s1_lo <= x2[15:0]; x3_s1_lo <= x3[15:0]; x4_s1_lo <= x4[15:0];
            y1_s1_lo <= y1[15:0]; y2_s1_lo <= y2[15:0]; y3_s1_lo <= y3[15:0]; y4_s1_lo <= y4[15:0];
        end
    end
    
    wire [31:0] x1_s1 = {x1_s1_hi, x1_s1_lo};
    wire [31:0] x2_s1 = {x2_s1_hi, x2_s1_lo};
    wire [31:0] x3_s1 = {x3_s1_hi, x3_s1_lo};
    wire [31:0] x4_s1 = {x4_s1_hi, x4_s1_lo};
    wire [31:0] y1_s1 = {y1_s1_hi, y1_s1_lo};
    wire [31:0] y2_s1 = {y2_s1_hi, y2_s1_lo};
    wire [31:0] y3_s1 = {y3_s1_hi, y3_s1_lo};
    wire [31:0] y4_s1 = {y4_s1_hi, y4_s1_lo};

    // =========================================================================
    // Unpack (same as original)
    // =========================================================================
    
    wire s_x1, s_x2, s_x3, s_x4, s_y1, s_y2, s_y3, s_y4;
    wire [7:0] e_x1, e_x2, e_x3, e_x4, e_y1, e_y2, e_y3, e_y4;
    wire [23:0] m_x1, m_x2, m_x3, m_x4, m_y1, m_y2, m_y3, m_y4;
    wire zero_x1, zero_x2, zero_x3, zero_x4, zero_y1, zero_y2, zero_y3, zero_y4;
    
    FLP_unpack unpack_x1 (.flp(x1_s1), .precision(precision_s1), .sign(s_x1), .exp(e_x1), .mant(m_x1), .is_zero(zero_x1));
    FLP_unpack unpack_x2 (.flp(x2_s1), .precision(precision_s1), .sign(s_x2), .exp(e_x2), .mant(m_x2), .is_zero(zero_x2));
    FLP_unpack unpack_x3 (.flp(x3_s1), .precision(precision_s1), .sign(s_x3), .exp(e_x3), .mant(m_x3), .is_zero(zero_x3));
    FLP_unpack unpack_x4 (.flp(x4_s1), .precision(precision_s1), .sign(s_x4), .exp(e_x4), .mant(m_x4), .is_zero(zero_x4));
    
    FLP_unpack unpack_y1 (.flp(y1_s1), .precision(precision_s1), .sign(s_y1), .exp(e_y1), .mant(m_y1), .is_zero(zero_y1));
    FLP_unpack unpack_y2 (.flp(y2_s1), .precision(precision_s1), .sign(s_y2), .exp(e_y2), .mant(m_y2), .is_zero(zero_y2));
    FLP_unpack unpack_y3 (.flp(y3_s1), .precision(precision_s1), .sign(s_y3), .exp(e_y3), .mant(m_y3), .is_zero(zero_y3));
    FLP_unpack unpack_y4 (.flp(y4_s1), .precision(precision_s1), .sign(s_y4), .exp(e_y4), .mant(m_y4), .is_zero(zero_y4));
    
    // Product signs and zeros
    wire s_p1 = s_x1 ^ s_y1, s_p2 = s_x2 ^ s_y2, s_p3 = s_x3 ^ s_y3, s_p4 = s_x4 ^ s_y4;
    wire zero_p1 = zero_x1 | zero_y1, zero_p2 = zero_x2 | zero_y2;
    wire zero_p3 = zero_x3 | zero_y3, zero_p4 = zero_x4 | zero_y4;
    
    // Product exponents (same as original)
    wire signed [9:0] e_p1 = zero_p1 ? 10'sd0 : ($signed({2'b0, e_x1}) + $signed({2'b0, e_y1}) - (precision_s1 ? 10'sd15 : 10'sd127));
    wire signed [9:0] e_p2 = zero_p2 ? 10'sd0 : ($signed({2'b0, e_x2}) + $signed({2'b0, e_y2}) - (precision_s1 ? 10'sd15 : 10'sd127));
    wire signed [9:0] e_p3 = zero_p3 ? 10'sd0 : ($signed({2'b0, e_x3}) + $signed({2'b0, e_y3}) - (precision_s1 ? 10'sd15 : 10'sd127));
    wire signed [9:0] e_p4 = zero_p4 ? 10'sd0 : ($signed({2'b0, e_x4}) + $signed({2'b0, e_y4}) - (precision_s1 ? 10'sd15 : 10'sd127));
    
    // Find emax (same as original)
    wire signed [9:0] emax_12 = (e_p1 > e_p2) ? e_p1 : e_p2;
    wire signed [9:0] emax_34 = (e_p3 > e_p4) ? e_p3 : e_p4;
    wire signed [9:0] emax_s1 = (emax_12 > emax_34) ? emax_12 : emax_34;

    // =========================================================================
    // 4 x 12x12 Multipliers per product (16 total)
    // In FP16: m_x[11:0] = 0 from unpack, so HL/LH/LL inputs include 0
    //          -> No switching power in those multipliers
    // =========================================================================
    
    // Product 1: m_x1 * m_y1 = (m_x1_hi*2^12 + m_x1_lo) * (m_y1_hi*2^12 + m_y1_lo)
    wire [23:0] pp1_hh = m_x1[23:12] * m_y1[23:12];  // HH: always active
    wire [23:0] pp1_hl = m_x1[23:12] * m_y1[11:0];   // HL: m_y1[11:0]=0 in FP16
    wire [23:0] pp1_lh = m_x1[11:0] * m_y1[23:12];   // LH: m_x1[11:0]=0 in FP16
    wire [23:0] pp1_ll = m_x1[11:0] * m_y1[11:0];    // LL: both=0 in FP16
    
    // Product 2: m_x2 * m_y2
    wire [23:0] pp2_hh = m_x2[23:12] * m_y2[23:12];
    wire [23:0] pp2_hl = m_x2[23:12] * m_y2[11:0];
    wire [23:0] pp2_lh = m_x2[11:0] * m_y2[23:12];
    wire [23:0] pp2_ll = m_x2[11:0] * m_y2[11:0];
    
    // Product 3: m_x3 * m_y3
    wire [23:0] pp3_hh = m_x3[23:12] * m_y3[23:12];
    wire [23:0] pp3_hl = m_x3[23:12] * m_y3[11:0];
    wire [23:0] pp3_lh = m_x3[11:0] * m_y3[23:12];
    wire [23:0] pp3_ll = m_x3[11:0] * m_y3[11:0];
    
    // Product 4: m_x4 * m_y4
    wire [23:0] pp4_hh = m_x4[23:12] * m_y4[23:12];
    wire [23:0] pp4_hl = m_x4[23:12] * m_y4[11:0];
    wire [23:0] pp4_lh = m_x4[11:0] * m_y4[23:12];
    wire [23:0] pp4_ll = m_x4[11:0] * m_y4[11:0];
    
    // Combine partial products: result = HH*2^24 + (HL+LH)*2^12 + LL
    wire [47:0] m_p1 = zero_p1 ? 48'd0 : ({pp1_hh, 24'd0} + {12'd0, pp1_hl, 12'd0} + {12'd0, pp1_lh, 12'd0} + {24'd0, pp1_ll});
    wire [47:0] m_p2 = zero_p2 ? 48'd0 : ({pp2_hh, 24'd0} + {12'd0, pp2_hl, 12'd0} + {12'd0, pp2_lh, 12'd0} + {24'd0, pp2_ll});
    wire [47:0] m_p3 = zero_p3 ? 48'd0 : ({pp3_hh, 24'd0} + {12'd0, pp3_hl, 12'd0} + {12'd0, pp3_lh, 12'd0} + {24'd0, pp3_ll});
    wire [47:0] m_p4 = zero_p4 ? 48'd0 : ({pp4_hh, 24'd0} + {12'd0, pp4_hl, 12'd0} + {12'd0, pp4_lh, 12'd0} + {24'd0, pp4_ll});

    // =========================================================================
    // Alignment (same as original)
    // =========================================================================
    
    wire signed [9:0] diff1 = emax_s1 - e_p1;
    wire signed [9:0] diff2 = emax_s1 - e_p2;
    wire signed [9:0] diff3 = emax_s1 - e_p3;
    wire signed [9:0] diff4 = emax_s1 - e_p4;
    
    wire [6:0] shift1 = (diff1 > 10'sd55) ? 7'd55 : diff1[6:0];
    wire [6:0] shift2 = (diff2 > 10'sd55) ? 7'd55 : diff2[6:0];
    wire [6:0] shift3 = (diff3 > 10'sd55) ? 7'd55 : diff3[6:0];
    wire [6:0] shift4 = (diff4 > 10'sd55) ? 7'd55 : diff4[6:0];
    
    wire [55:0] m_p1_ext = {m_p1, 8'b0};
    wire [55:0] m_p2_ext = {m_p2, 8'b0};
    wire [55:0] m_p3_ext = {m_p3, 8'b0};
    wire [55:0] m_p4_ext = {m_p4, 8'b0};
    
    wire [55:0] m_aligned1 = m_p1_ext >> shift1;
    wire [55:0] m_aligned2 = m_p2_ext >> shift2;
    wire [55:0] m_aligned3 = m_p3_ext >> shift3;
    wire [55:0] m_aligned4 = m_p4_ext >> shift4;
    
    // Convert to signed (same as original)
    wire signed [56:0] sm1 = s_p1 ? -$signed({1'b0, m_aligned1}) : $signed({1'b0, m_aligned1});
    wire signed [56:0] sm2 = s_p2 ? -$signed({1'b0, m_aligned2}) : $signed({1'b0, m_aligned2});
    wire signed [56:0] sm3 = s_p3 ? -$signed({1'b0, m_aligned3}) : $signed({1'b0, m_aligned3});
    wire signed [56:0] sm4 = s_p4 ? -$signed({1'b0, m_aligned4}) : $signed({1'b0, m_aligned4});
    
    // =========================================================================
    // Pipeline Register 1 -> 2: Split HIGH/LOW for clock gating
    // =========================================================================
    
    reg signed [28:0] sm1_s2_hi, sm2_s2_hi, sm3_s2_hi, sm4_s2_hi;
    reg signed [9:0]  emax_s2_reg;
    reg               precision_s2_reg;
    reg [27:0] sm1_s2_lo, sm2_s2_lo, sm3_s2_lo, sm4_s2_lo;
    
    // HIGH part - FP16/FP32 shared
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sm1_s2_hi <= 29'sd0; sm2_s2_hi <= 29'sd0; sm3_s2_hi <= 29'sd0; sm4_s2_hi <= 29'sd0;
            emax_s2_reg <= 10'sd0;
            precision_s2_reg <= 1'b0;
        end else if (enable_all) begin
            sm1_s2_hi <= sm1[56:28]; sm2_s2_hi <= sm2[56:28]; sm3_s2_hi <= sm3[56:28]; sm4_s2_hi <= sm4[56:28];
            emax_s2_reg <= emax_s1;
            precision_s2_reg <= precision_s1;
        end
    end
    
    // LOW part - FP32 only (frozen in FP16)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sm1_s2_lo <= 28'd0; sm2_s2_lo <= 28'd0; sm3_s2_lo <= 28'd0; sm4_s2_lo <= 28'd0;
        end else if (enable_fp32) begin
            sm1_s2_lo <= sm1[27:0]; sm2_s2_lo <= sm2[27:0]; sm3_s2_lo <= sm3[27:0]; sm4_s2_lo <= sm4[27:0];
        end
    end
    
    assign sm1_s2 = {sm1_s2_hi, sm1_s2_lo};
    assign sm2_s2 = {sm2_s2_hi, sm2_s2_lo};
    assign sm3_s2 = {sm3_s2_hi, sm3_s2_lo};
    assign sm4_s2 = {sm4_s2_hi, sm4_s2_lo};
    assign emax_s2 = emax_s2_reg;
    assign precision_s2 = precision_s2_reg;

endmodule

//==============================================================================
// Stage 2 - Multi-operand Addition (same structure as original)
//==============================================================================
//Stage 2：Fixed-point 多輸入加法

//四個 product 相加
module stage2 (
    input         clk,
    input         rst_n,
    input         enable_all,
    input         enable_fp32,
    input  signed [56:0] sm1_s2_in,
    input  signed [56:0] sm2_s2_in,
    input  signed [56:0] sm3_s2_in,
    input  signed [56:0] sm4_s2_in,
    input  signed [9:0]  emax_s2_in,
    input                precision_s2_in,
    output signed [58:0] sum_s3,
    output signed [9:0]  emax_s3,
    output               precision_s3
);

    // Multi-operand addition
    wire signed [58:0] sum_s2 = sm1_s2_in + sm2_s2_in + sm3_s2_in + sm4_s2_in;
    
    // =========================================================================
    // Pipeline Register 2 -> 3: Split HIGH/LOW
    // =========================================================================
    
    reg signed [28:0] sum_s3_hi;
    reg [29:0] sum_s3_lo;
    reg signed [9:0] emax_s3_reg;
    reg precision_s3_reg;
    
    // HIGH part - FP16/FP32 shared
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum_s3_hi <= 29'sd0;
            emax_s3_reg <= 10'sd0;
            precision_s3_reg <= 1'b0;
        end else if (enable_all) begin
            sum_s3_hi <= sum_s2[58:30];
            emax_s3_reg <= emax_s2_in;
            precision_s3_reg <= precision_s2_in;
        end
    end
    
    // LOW part - FP32 only
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum_s3_lo <= 30'd0;
        end else if (enable_fp32) begin
            sum_s3_lo <= sum_s2[29:0];
        end
    end
    
    assign sum_s3 = {sum_s3_hi, sum_s3_lo};
    assign emax_s3 = emax_s3_reg;
    assign precision_s3 = precision_s3_reg;

endmodule

//==============================================================================
// Stage 3 - Normalization (same structure as original)
//=============================================================================

//LOD

//shift normalization

//exponent adjustment
module stage3 (
    input         clk,
    input         rst_n,
    input         enable_all,
    input         enable_fp32,
    input  signed [58:0] sum_s3_in,
    input  signed [9:0]  emax_s3_in,
    input                precision_s3_in,
    output [58:0]        normalized_s4,
    output [7:0]         exp_adjusted_s4,
    output               sign_result_s4,
    output               result_zero_s4,
    output               overflow_s4,
    output               precision_s4
);

    // Sign-magnitude conversion
    wire sign_result_s3 = sum_s3_in[58];
    wire [58:0] abs_sum = sign_result_s3 ? -sum_s3_in : sum_s3_in;
    wire result_zero_s3 = (abs_sum == 59'd0);
    
    // Leading zero detection
    wire [5:0] lzc_s3;
    LOD_59bit lod_inst (.in(abs_sum), .lzc(lzc_s3));
    
    // Normalization
    wire [58:0] normalized_s3 = abs_sum << lzc_s3;
    
    // Exponent adjustment
    wire signed [9:0] exp_adjusted_s3 = emax_s3_in - $signed({4'b0, lzc_s3}) + 10'sd4;
    
    // Overflow detection
    wire overflow_s3 = (exp_adjusted_s3 >= (precision_s3_in ? 10'sd31 : 10'sd255));
    
    // =========================================================================
    // Pipeline Register 3 -> 4: Split HIGH/LOW
    // =========================================================================
    
    reg [28:0] normalized_s4_hi;
    reg [29:0] normalized_s4_lo;
    reg [7:0]  exp_adjusted_s4_reg;
    reg        sign_result_s4_reg;
    reg        result_zero_s4_reg;
    reg        overflow_s4_reg;
    reg        precision_s4_reg;
    
    // HIGH part - FP16/FP32 shared
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            normalized_s4_hi <= 29'd0;
            exp_adjusted_s4_reg <= 8'd0;
            sign_result_s4_reg <= 1'b0;
            result_zero_s4_reg <= 1'b0;
            overflow_s4_reg <= 1'b0;
            precision_s4_reg <= 1'b0;
        end else if (enable_all) begin
            normalized_s4_hi <= normalized_s3[58:30];
            exp_adjusted_s4_reg <= exp_adjusted_s3[7:0];
            sign_result_s4_reg <= sign_result_s3;
            result_zero_s4_reg <= result_zero_s3;
            overflow_s4_reg <= overflow_s3;
            precision_s4_reg <= precision_s3_in;
        end
    end
    
    // LOW part - FP32 only
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            normalized_s4_lo <= 30'd0;
        end else if (enable_fp32) begin
            normalized_s4_lo <= normalized_s3[29:0];
        end
    end
    
    assign normalized_s4 = {normalized_s4_hi, normalized_s4_lo};
    assign exp_adjusted_s4 = exp_adjusted_s4_reg;
    assign sign_result_s4 = sign_result_s4_reg;
    assign result_zero_s4 = result_zero_s4_reg;
    assign overflow_s4 = overflow_s4_reg;
    assign precision_s4 = precision_s4_reg;

endmodule

//==============================================================================
// Stage 4 (Combinational - same as original)
//==============================================================================
//Stage 4：Rounding + Pack

//rounding

//pack 成 FP32 / FP16
module stage4 (
    input  [58:0] normalized_s4,
    input  [7:0]  exp_adjusted_s4,
    input         sign_result_s4,
    input         result_zero_s4,
    input         overflow_s4,
    input         precision_s4,
    output [31:0] z
);
    wire [25:0] mant_to_round_s4 = normalized_s4[58:33];
    wire        sticky_s4        = |normalized_s4[32:0];
    
    wire [23:0] mant_rounded_s4;
    wire [7:0]  exp_final_s4;
    
    FLP_round rounder (
        .mant_in   (mant_to_round_s4),
        .sticky    (sticky_s4),
        .exp_in    (exp_adjusted_s4),
        .sign      (sign_result_s4),
        .precision (precision_s4),
        .mant_out  (mant_rounded_s4),
        .exp_out   (exp_final_s4)
    );
    
    FLP_pack packer (
        .sign       (sign_result_s4),
        .exp        (exp_final_s4),
        .mant       (mant_rounded_s4),
        .precision  (precision_s4),
        .is_zero    (result_zero_s4),
        .is_overflow(overflow_s4),
        .flp        (z)
    );
endmodule

//==============================================================================
// Supporting Modules (same as original)
//==============================================================================

module FLP_unpack (
    input  [31:0] flp,
    input         precision,
    output        sign,
    output [7:0]  exp,
    output [23:0] mant,
    output        is_zero
);
    wire [15:0] fp16_data = flp[31:16];
    assign sign = precision ? fp16_data[15] : flp[31];
    wire [7:0] exp_raw   = precision ? {3'b0, fp16_data[14:10]} : flp[30:23];
    wire [22:0] mant_raw = precision ? {fp16_data[9:0], 13'b0}   : flp[22:0];
    assign is_zero = (exp_raw == 8'd0);
    assign exp  = exp_raw;
    assign mant = is_zero ? 24'd0 : {1'b1, mant_raw};
endmodule

module LOD_59bit (
    input  [58:0] in,
    output [5:0]  lzc
);
    wire [5:0] p [58:0];
    wire [58:0] v;

    assign v = in;
    assign p[0] = v[0] ? 6'd58 : 6'd59;

    genvar i;
    generate
        for (i = 1; i < 59; i = i + 1) begin : GEN_LOD
            assign p[i] = v[i] ? (6'd58 - i[5:0]) : p[i-1];
        end
    endgenerate

    assign lzc = p[58];
endmodule

module FLP_round (
    input  [25:0] mant_in,
    input         sticky,
    input  [7:0]  exp_in,
    input         sign,
    input         precision,
    output [23:0] mant_out,
    output [7:0]  exp_out
);
    wire [23:0] mant_trunc = precision ? {mant_in[25:15], 13'b0} : mant_in[25:2];
    wire        guard      = precision ? mant_in[14] : mant_in[1];
    wire        round_bit  = precision ? mant_in[13] : mant_in[0];
    wire        sticky_all = precision ? (|mant_in[12:0] | sticky) : sticky;
    wire        lsb        = precision ? mant_in[15] : mant_trunc[0];
    
    wire        round_up   = guard & (round_bit | sticky_all | lsb);
    wire [24:0] round_increment = precision ? 25'd8192 : 25'd1;
    wire [24:0] mant_rounded_temp = {1'b0, mant_trunc} + (round_up ? round_increment : 25'd0);
    wire        mant_overflow = mant_rounded_temp[24];
    
    assign mant_out = mant_overflow ? mant_rounded_temp[24:1] : mant_rounded_temp[23:0];
    assign exp_out  = mant_overflow ? (exp_in + 8'd1) : exp_in;
endmodule

module FLP_pack (
    input         sign,
    input  [7:0]  exp,
    input  [23:0] mant,
    input         precision,
    input         is_zero,
    input         is_overflow,
    output [31:0] flp
);
    wire [31:0] fp32_final = is_zero     ? {sign, 31'b0} :
                             is_overflow ? {sign, 8'hFF, 23'b0} :
                                           {sign, exp[7:0], mant[22:0]};
    wire [15:0] fp16_final = is_zero     ? {sign, 15'b0} :
                             is_overflow ? {sign, 5'h1F, 10'b0} :
                                           {sign, exp[4:0], mant[22:13]};
    assign flp = precision ? {fp16_final, 16'h0000} : fp32_final;
endmodule