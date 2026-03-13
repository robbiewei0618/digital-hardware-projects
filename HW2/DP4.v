//==============================================================================
// Module: DP4 - Floating-Point Dot Product of 4D Vectors (Non-Pipelined)
// Description: z = x1*y1 + x2*y2 + x3*y3 + x4*y4
// Precision: Supports both FP32 (single-precision) and FP16 (half-precision)
// Author: ALU HW3
// Date: 2025/11/03
//==============================================================================

module DP4 (
    // Input vectors (use MSB 16 bits for FP16 mode)
    input  [31:0] x1, x2, x3, x4,  // Vector x components
    input  [31:0] y1, y2, y3, y4,  // Vector y components
    input         precision,        // 0: FP32, 1: FP16
    output [31:0] z                 // Result
);

    // =========================================================================
    // Stage 1: Unpack, Multiply, Alignment
    // =========================================================================
    
    // Unpacked components for each input
    wire s_x1, s_x2, s_x3, s_x4;
    wire s_y1, s_y2, s_y3, s_y4;
    wire [7:0] e_x1, e_x2, e_x3, e_x4;
    wire [7:0] e_y1, e_y2, e_y3, e_y4;
    wire [23:0] m_x1, m_x2, m_x3, m_x4;  // Mantissa with implicit 1
    wire [23:0] m_y1, m_y2, m_y3, m_y4;
    
    // Unpack all inputs
    FLP_unpack unpack_x1 (.flp(x1), .precision(precision), .sign(s_x1), .exp(e_x1), .mant(m_x1));
    FLP_unpack unpack_x2 (.flp(x2), .precision(precision), .sign(s_x2), .exp(e_x2), .mant(m_x2));
    FLP_unpack unpack_x3 (.flp(x3), .precision(precision), .sign(s_x3), .exp(e_x3), .mant(m_x3));
    FLP_unpack unpack_x4 (.flp(x4), .precision(precision), .sign(s_x4), .exp(e_x4), .mant(m_x4));
    
    FLP_unpack unpack_y1 (.flp(y1), .precision(precision), .sign(s_y1), .exp(e_y1), .mant(m_y1));
    FLP_unpack unpack_y2 (.flp(y2), .precision(precision), .sign(s_y2), .exp(e_y2), .mant(m_y2));
    FLP_unpack unpack_y3 (.flp(y3), .precision(precision), .sign(s_y3), .exp(e_y3), .mant(m_y3));
    FLP_unpack unpack_y4 (.flp(y4), .precision(precision), .sign(s_y4), .exp(e_y4), .mant(m_y4));
    
    // Product signs and exponents
    wire s_p1, s_p2, s_p3, s_p4;
    wire [8:0] e_p1, e_p2, e_p3, e_p4;  // 9 bits for addition overflow
    wire [47:0] m_p1, m_p2, m_p3, m_p4;  // 24*24 = 48 bits
    
    assign s_p1 = s_x1 ^ s_y1;
    assign s_p2 = s_x2 ^ s_y2;
    assign s_p3 = s_x3 ^ s_y3;
    assign s_p4 = s_x4 ^ s_y4;
    
    // Exponent addition (with bias correction)
    // For FP32: bias = 127, exp_result = e_x + e_y - 127
    // For FP16: bias = 15,  exp_result = e_x + e_y - 15
    wire [7:0] bias;
    assign bias = precision ? 8'd15 : 8'd127;
    
    assign e_p1 = {1'b0, e_x1} + {1'b0, e_y1} - {1'b0, bias};
    assign e_p2 = {1'b0, e_x2} + {1'b0, e_y2} - {1'b0, bias};
    assign e_p3 = {1'b0, e_x3} + {1'b0, e_y3} - {1'b0, bias};
    assign e_p4 = {1'b0, e_x4} + {1'b0, e_y4} - {1'b0, bias};
    
    // Mantissa multiplication (24-bit × 24-bit = 48-bit)
    assign m_p1 = m_x1 * m_y1;
    assign m_p2 = m_x2 * m_y2;
    assign m_p3 = m_x3 * m_y3;
    assign m_p4 = m_x4 * m_y4;
    
    // Find maximum exponent
    wire [8:0] emax_12, emax_34, emax;
    assign emax_12 = (e_p1 > e_p2) ? e_p1 : e_p2;
    assign emax_34 = (e_p3 > e_p4) ? e_p3 : e_p4;
    assign emax = (emax_12 > emax_34) ? emax_12 : emax_34;
    
    // Alignment shifts
    wire [5:0] shift1, shift2, shift3, shift4;
    assign shift1 = (emax > e_p1) ? ((emax - e_p1 > 51) ? 6'd51 : emax[5:0] - e_p1[5:0]) : 6'd0;
    assign shift2 = (emax > e_p2) ? ((emax - e_p2 > 51) ? 6'd51 : emax[5:0] - e_p2[5:0]) : 6'd0;
    assign shift3 = (emax > e_p3) ? ((emax - e_p3 > 51) ? 6'd51 : emax[5:0] - e_p3[5:0]) : 6'd0;
    assign shift4 = (emax > e_p4) ? ((emax - e_p4 > 51) ? 6'd51 : emax[5:0] - e_p4[5:0]) : 6'd0;
    
    // Aligned mantissas (extended to 52 bits: 48-bit product + 2 guard + 2 round bits)
    wire [51:0] m_aligned1, m_aligned2, m_aligned3, m_aligned4;
    assign m_aligned1 = {m_p1, 4'b0000} >> shift1;
    assign m_aligned2 = {m_p2, 4'b0000} >> shift2;
    assign m_aligned3 = {m_p3, 4'b0000} >> shift3;
    assign m_aligned4 = {m_p4, 4'b0000} >> shift4;
    
    // =========================================================================
    // Stage 2: Convert to signed and add
    // =========================================================================
    
    // Convert to signed (2's complement)
    wire signed [54:0] sm1, sm2, sm3, sm4;  // 55 bits: sign + 52-bit mantissa + 2 bits for overflow
    assign sm1 = s_p1 ? -{3'b0, m_aligned1} : {3'b0, m_aligned1};
    assign sm2 = s_p2 ? -{3'b0, m_aligned2} : {3'b0, m_aligned2};
    assign sm3 = s_p3 ? -{3'b0, m_aligned3} : {3'b0, m_aligned3};
    assign sm4 = s_p4 ? -{3'b0, m_aligned4} : {3'b0, m_aligned4};
    
    // Sum all products
    wire signed [54:0] sum;
    assign sum = sm1 + sm2 + sm3 + sm4;
    
    // =========================================================================
    // Stage 3: Normalize
    // =========================================================================
    
    wire sign_result;
    wire [53:0] abs_sum;
    
    assign sign_result = sum[54];
    assign abs_sum = sign_result ? -sum[53:0] : sum[53:0];
    
    // Leading one detection
    wire [5:0] lod;
    wire [53:0] normalized;
    wire [8:0] exp_normalized;
    
    LOD_54bit lod_inst (
        .in(abs_sum),
        .lod(lod)
    );
    
    // Normalize by shifting left
    assign normalized = abs_sum << lod;
    assign exp_normalized = emax - {3'b0, lod} + 9'd1;  // +1 because mantissa is 1.xxx
    
    // =========================================================================
    // Stage 4: Round and Pack
    // =========================================================================
    
    // Rounding (round to nearest, ties to even)
    wire [23:0] mant_rounded;
    wire [7:0] exp_rounded;
    wire overflow;
    
    FLP_round rounder (
        .mant_in(normalized[53:28]),      // Take top 26 bits (1.xxx + guard + round)
        .exp_in(exp_normalized[7:0]),
        .precision(precision),
        .mant_out(mant_rounded),
        .exp_out(exp_rounded),
        .overflow(overflow)
    );
    
    // Pack result
    FLP_pack packer (
        .sign(sign_result),
        .exp(exp_rounded),
        .mant(mant_rounded),
        .precision(precision),
        .flp(z)
    );

endmodule

//==============================================================================
// Module: FLP_unpack - Unpack floating-point number
//==============================================================================
module FLP_unpack (
    input  [31:0] flp,        // Input floating-point (use MSB 16 bits for FP16)
    input         precision,  // 0: FP32, 1: FP16
    output        sign,
    output [7:0]  exp,       // Extended to 8 bits for both formats
    output [23:0] mant       // Mantissa with implicit 1 (1.xxx format)
);

    wire [15:0] fp16_data;
    assign fp16_data = flp[31:16];  // Use MSB 16 bits for FP16
    
    // Extract fields based on precision
    assign sign = precision ? fp16_data[15] : flp[31];
    
    wire [7:0] exp_raw;
    wire [22:0] mant_raw;
    
    assign exp_raw  = precision ? {3'b0, fp16_data[14:10]} : flp[30:23];
    assign mant_raw = precision ? {fp16_data[9:0], 13'b0} : flp[22:0];
    
    // Handle special cases
    wire is_zero, is_denorm;
    assign is_zero   = (exp_raw == 8'd0) && (mant_raw == 23'd0);
    assign is_denorm = (exp_raw == 8'd0) && (mant_raw != 23'd0);
    
    // Output exponent (convert bias if needed)
    assign exp = is_zero ? 8'd0 : exp_raw;
    
    // Output mantissa with implicit 1
    assign mant = is_zero ? 24'd0 : 
                  is_denorm ? {1'b0, mant_raw} :  // Denormal: 0.xxx
                              {1'b1, mant_raw};   // Normal: 1.xxx

endmodule

//==============================================================================
// Module: FLP_round - Round mantissa
//==============================================================================
module FLP_round (
    input  [25:0] mant_in,    // Input mantissa (1.xxx + guard + round bits)
    input  [7:0]  exp_in,     // Input exponent
    input         precision,  // 0: FP32, 1: FP16
    output [23:0] mant_out,   // Rounded mantissa
    output [7:0]  exp_out,    // Adjusted exponent
    output        overflow    // Exponent overflow
);

    // Round to nearest, ties to even
    wire guard_bit, round_bit, sticky_bit;
    assign guard_bit  = mant_in[1];
    assign round_bit  = mant_in[0];
    assign sticky_bit = 1'b0;  // Simplified for now
    
    wire round_up;
    assign round_up = guard_bit && (round_bit || sticky_bit || mant_in[2]);
    
    wire [24:0] mant_rounded_temp;
    assign mant_rounded_temp = {1'b0, mant_in[25:2]} + (round_up ? 25'd1 : 25'd0);
    
    // Check for mantissa overflow (1.xxx became 10.xxx)
    wire mant_overflow;
    assign mant_overflow = mant_rounded_temp[24];
    
    // Adjust mantissa and exponent
    assign mant_out = mant_overflow ? mant_rounded_temp[24:1] : mant_rounded_temp[23:0];
    assign exp_out  = mant_overflow ? (exp_in + 8'd1) : exp_in;
    
    // Check exponent overflow
    assign overflow = precision ? (exp_out >= 8'd31) : (exp_out >= 8'd255);

endmodule

//==============================================================================
// Module: FLP_pack - Pack floating-point number
//==============================================================================
module FLP_pack (
    input         sign,
    input  [7:0]  exp,
    input  [23:0] mant,      // Mantissa with implicit 1
    input         precision, // 0: FP32, 1: FP16
    output [31:0] flp
);

    // Pack based on precision
    wire [31:0] fp32_result;
    wire [15:0] fp16_result;
    
    // FP32: sign(1) | exp(8) | mant(23)
    assign fp32_result = {sign, exp[7:0], mant[22:0]};
    
    // FP16: sign(1) | exp(5) | mant(10)
    assign fp16_result = {sign, exp[4:0], mant[22:13]};
    
    // Output (FP16 in MSB 16 bits, LSB 16 bits are zero)
    assign flp = precision ? {fp16_result, 16'h0000} : fp32_result;

endmodule

//==============================================================================
// Module: LOD_54bit - Leading One Detector for 54-bit number
//==============================================================================
module LOD_54bit (
    input  [53:0] in,
    output [5:0]  lod   // Leading zero count
);

    reg [5:0] count;
    integer i;
    
    always @(*) begin
        count = 6'd54;  // Default: all zeros
        for (i = 53; i >= 0; i = i - 1) begin
            if (in[i]) begin
                count = 6'd53 - i[5:0];
            end
        end
    end
    
    assign lod = count;

endmodule