// =============================================================================
// FLP_FMA_4 - binary32 fused multiply-add, 4-stage pipeline
//   d = a*b + c, latency 4 cycles, one result per cycle; same arithmetic as
//   FLP_FMA (shared fma_datapath.v), so both give bit-identical results.
//   Stage 1: unpack + multiply + align   Stage 2: add
//   Stage 3: normalise                   Stage 4: round + pack (registered out)
//   rst: synchronous, active high.
// The first version of this design is in archive/FLP_FMA_4_v1.v (see BUGS.md).
// =============================================================================
module FLP_FMA_4 (
    input         clk,
    input         rst,
    input  [31:0] a,
    input  [31:0] b,
    input  [31:0] c,
    output [31:0] d
);
    // ---------------- stage 1 ----------------
    wire [78:0]        p_al_1, c_al_1;
    wire               sp_1, sc_1, zs_1, sp_case_1;
    wire signed [10:0] ef_1;
    wire [31:0]        sres_1;
    fma_stage1 u_s1 (.a(a), .b(b), .c(c), .p_al(p_al_1), .c_al(c_al_1), .sp(sp_1), .sc(sc_1),
                     .e_frame(ef_1), .zero_sign(zs_1), .special(sp_case_1), .special_res(sres_1));

    reg [78:0]        p_al_2, c_al_2;
    reg               sp_2, sc_2, zs_2, spc_2;
    reg signed [10:0] ef_2;
    reg [31:0]        sres_2;
    always @(posedge clk) begin
        if (rst) begin
            p_al_2 <= 79'd0; c_al_2 <= 79'd0; sp_2 <= 1'b0; sc_2 <= 1'b0;
            zs_2 <= 1'b0; spc_2 <= 1'b0; ef_2 <= 11'sd0; sres_2 <= 32'd0;
        end else begin
            p_al_2 <= p_al_1; c_al_2 <= c_al_1; sp_2 <= sp_1; sc_2 <= sc_1;
            zs_2 <= zs_1; spc_2 <= sp_case_1; ef_2 <= ef_1; sres_2 <= sres_1;
        end
    end

    // ---------------- stage 2 ----------------
    wire [78:0] mag_2;
    wire        sign_2;
    fma_stage2 u_s2 (.p_al(p_al_2), .c_al(c_al_2), .sp(sp_2), .sc(sc_2), .mag(mag_2), .sign(sign_2));

    reg [78:0]        mag_3;
    reg               sign_3, zs_3, spc_3;
    reg signed [10:0] ef_3;
    reg [31:0]        sres_3;
    always @(posedge clk) begin
        if (rst) begin
            mag_3 <= 79'd0; sign_3 <= 1'b0; zs_3 <= 1'b0; spc_3 <= 1'b0;
            ef_3 <= 11'sd0; sres_3 <= 32'd0;
        end else begin
            mag_3 <= mag_2; sign_3 <= sign_2; zs_3 <= zs_2; spc_3 <= spc_2;
            ef_3 <= ef_2; sres_3 <= sres_2;
        end
    end

    // ---------------- stage 3 ----------------
    wire [23:0]        sig_3;
    wire               g_3, st_3, z_3;
    wire signed [10:0] eb_3;
    fma_stage3 u_s3 (.mag(mag_3), .e_frame(ef_3), .sig(sig_3), .guard(g_3), .sticky(st_3),
                     .exp_b(eb_3), .is_zero(z_3));

    reg [23:0]        sig_4;
    reg               g_4, st_4, z_4, sign_4, zs_4, spc_4;
    reg signed [10:0] eb_4;
    reg [31:0]        sres_4;
    always @(posedge clk) begin
        if (rst) begin
            sig_4 <= 24'd0; g_4 <= 1'b0; st_4 <= 1'b0; z_4 <= 1'b0; sign_4 <= 1'b0;
            zs_4 <= 1'b0; spc_4 <= 1'b0; eb_4 <= 11'sd0; sres_4 <= 32'd0;
        end else begin
            sig_4 <= sig_3; g_4 <= g_3; st_4 <= st_3; z_4 <= z_3; sign_4 <= sign_3;
            zs_4 <= zs_3; spc_4 <= spc_3; eb_4 <= eb_3; sres_4 <= sres_3;
        end
    end

    // ---------------- stage 4 ----------------
    wire [31:0] r_4;
    fma_stage4 u_s4 (.sig(sig_4), .guard(g_4), .sticky(st_4), .exp_b(eb_4), .sign(sign_4),
                     .is_zero(z_4), .zero_sign(zs_4), .special(spc_4), .special_res(sres_4),
                     .r(r_4));

    reg [31:0] d_r;
    always @(posedge clk) begin
        if (rst) d_r <= 32'd0;
        else     d_r <= r_4;
    end
    assign d = d_r;
endmodule
