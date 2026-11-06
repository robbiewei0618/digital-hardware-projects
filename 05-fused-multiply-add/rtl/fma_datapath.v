// =============================================================================
// fma_datapath.v - shared datapath of the binary32 fused multiply-add
//
//   R = A*B + C, one rounding (round-to-nearest-even), IEEE-754 subnormals
//   (inputs and results), Inf/NaN rules of IEEE-754, canonical qNaN output.
//
// FLP_FMA (combinational) chains the four stages; FLP_FMA_4 registers
// between them. Fixed-point frame used by every stage (79-bit magnitude):
//
//   bit 78 ............................................................ 0
//   [ addend C, placed by exponent difference ][ product A*B ][ G R/S ]
//
//   * the product significand (48 bits) never moves: it sits at [49:2], so
//     bit 48 has weight 2^(ep) where ep = unbiased exponent of A*B;
//   * the addend significand (24 bits) is placed exactly at its own weight
//     when it fits in the frame (ec - ep in [-25, 29]); above that it is
//     pinned at the top and the product is shifted down instead; below it,
//     it is shifted into a sticky bit. Either way only an operand that is
//     entirely below the result's rounding position is ever approximated,
//     and that operand is jammed into bit 0 *before* the add, so it acts as
//     a borrow in an effective subtraction;
//   * normalisation shifts the leading one to bit 78, but never below the
//     subnormal exponent, so subnormal results are rounded exactly once.
// =============================================================================

// -----------------------------------------------------------------------------
// stage 1: unpack, special cases, 24x24 multiply, addend alignment
// -----------------------------------------------------------------------------
module fma_stage1 (
    input  [31:0]        a, b, c,
    output [78:0]        p_al,        // aligned product magnitude
    output [78:0]        c_al,        // aligned addend magnitude
    output               sp, sc,      // signs of A*B and C
    output signed [10:0] e_frame,     // biased exponent of frame bit 78 if it were the leading one
    output               zero_sign,   // sign of an exact zero result
    output               special,     // result is fully determined by the specials below
    output [31:0]        special_res
);
    wire        sa = a[31], sb = b[31];
    assign      sc = c[31];
    wire [7:0]  ea = a[30:23], eb = b[30:23], ec = c[30:23];
    wire [22:0] fa = a[22:0],  fb = b[22:0],  fc = c[22:0];

    wire a_zero = (ea == 8'd0) && (fa == 23'd0);
    wire b_zero = (eb == 8'd0) && (fb == 23'd0);
    wire c_zero = (ec == 8'd0) && (fc == 23'd0);
    wire a_inf  = (ea == 8'hFF) && (fa == 23'd0);
    wire b_inf  = (eb == 8'hFF) && (fb == 23'd0);
    wire c_inf  = (ec == 8'hFF) && (fc == 23'd0);
    wire a_nan  = (ea == 8'hFF) && (fa != 23'd0);
    wire b_nan  = (eb == 8'hFF) && (fb != 23'd0);
    wire c_nan  = (ec == 8'hFF) && (fc != 23'd0);

    assign sp = sa ^ sb;
    wire p_zero = a_zero | b_zero;
    wire p_inf  = a_inf  | b_inf;

    // ---- IEEE-754 special cases --------------------------------------------
    wire is_nan = a_nan | b_nan | c_nan | (p_inf & p_zero) | (p_inf & c_inf & (sp != sc));
    assign special     = is_nan | p_inf | c_inf;
    assign special_res = is_nan ? 32'h7FC0_0000 :
                         p_inf  ? {sp, 8'hFF, 23'd0} :
                                  {sc, 8'hFF, 23'd0};          // C = +-Inf
    // exact zero: (+-0 * x) + (+-0) keeps the sign only if both are negative;
    // any other exact zero (x*y == -c) is +0 under round-to-nearest
    assign zero_sign = p_zero & c_zero & sp & sc;

    // ---- significands and unbiased exponents (subnormal: exponent 1, no hidden 1)
    wire [23:0] ma = {(ea != 8'd0), fa};
    wire [23:0] mb = {(eb != 8'd0), fb};
    wire [23:0] mc = {(ec != 8'd0), fc};
    wire signed [10:0] ea_u = $signed({3'b0, (ea == 8'd0) ? 8'd1 : ea}) - 11'sd127;
    wire signed [10:0] eb_u = $signed({3'b0, (eb == 8'd0) ? 8'd1 : eb}) - 11'sd127;
    wire signed [10:0] ec_u = $signed({3'b0, (ec == 8'd0) ? 8'd1 : ec}) - 11'sd127;

    wire [47:0] mp_raw = ma * mb;                     // exact, value in [0, 4)

    // A subnormal operand leaves leading zeros in the product. Normalise it so
    // its leading one is at bit 46 or 47 again: the jam/sticky argument below
    // needs at least two frame bits between the result LSB and frame bit 0.
    function [5:0] lz46;                              // shift that brings the MSB to bit 46
        input [47:0] v;
        integer i;
        begin
            lz46 = 6'd0;
            for (i = 0; i < 46; i = i + 1)
                if (v[i]) lz46 = 6'd46 - i[5:0];
            if (v[47] | v[46]) lz46 = 6'd0;
        end
    endfunction
    wire [5:0]  p_lz = lz46(mp_raw);
    wire [47:0] mp   = mp_raw << p_lz;
    // a zero product does not constrain the frame: anchor it at C instead,
    // so the addend is always placed exactly
    wire signed [10:0] ep_u = p_zero ? ec_u : (ea_u + eb_u - $signed({5'd0, p_lz}));

    // ---- alignment ------------------------------------------------------------
    // frame bit 0 has weight 2^(ep_u - 48); the addend LSB has weight
    // 2^(ec_u - 23), i.e. frame position k = ec_u - ep_u + 25
    wire signed [11:0] k = $signed({ec_u[10], ec_u}) - $signed({ep_u[10], ep_u}) + 12'sd25;

    wire [78:0] p_frame = {29'd0, mp, 2'b00};
    wire [78:0] c_frame = {55'd0, mc};

    // logical right shift of v by n with every shifted-out bit ORed into bit 0
    function [78:0] shr_jam;
        input [78:0] v;
        input [11:0] n;                               // unsigned, may exceed 78
        begin
            if (n == 12'd0)       shr_jam = v;
            else if (n >= 12'd79) shr_jam = {78'd0, |v};
            else                  shr_jam = (v >> n) | {78'd0, |(v & ~({79{1'b1}} << n))};
        end
    endfunction

    wire c_above  = (k > 12'sd54);                    // addend MSB would pass bit 78
    wire c_below  = (k < 12'sd0);                     // addend LSB below frame bit 0
    wire [11:0] k_u    = k[11:0];
    wire [11:0] n_down = k_u - 12'd54;                // product shift when C is pinned on top
    wire [11:0] n_c    = -k_u;                        // addend shift when it is below the frame

    assign p_al = c_above ? shr_jam(p_frame, n_down) : p_frame;
    assign c_al = c_above ? (c_frame << 54) :
                  c_below ? shr_jam(c_frame, n_c) :
                            (c_frame << k_u[6:0]);

    // biased exponent of frame bit 78: bit 48 <-> ep_u, so bit 78 <-> ep_u + 30.
    // With C pinned on top (product shifted down by k - 54) bit 48 <-> ec_u - 29.
    assign e_frame = (c_above ? (ec_u - 11'sd29) : ep_u) + 11'sd30 + 11'sd127;
endmodule

// -----------------------------------------------------------------------------
// stage 2: signed addition of the aligned operands
// -----------------------------------------------------------------------------
module fma_stage2 (
    input  [78:0] p_al, c_al,
    input         sp, sc,
    output [78:0] mag,            // |sum|
    output        sign            // sign of the sum (valid when mag != 0)
);
    wire signed [80:0] ps = sp ? -$signed({2'b00, p_al}) : $signed({2'b00, p_al});
    wire signed [80:0] cs = sc ? -$signed({2'b00, c_al}) : $signed({2'b00, c_al});
    wire signed [80:0] s  = ps + cs;
    assign sign = s[80];
    wire [80:0] abs_s = s[80] ? -s : s;
    assign mag = abs_s[78:0];     // |p| + |c| < 2^79 by construction
endmodule

// -----------------------------------------------------------------------------
// stage 3: normalisation (leading one to bit 78, limited by the subnormal
//          exponent), producing a 24-bit significand + guard + sticky
// -----------------------------------------------------------------------------
module fma_stage3 (
    input  [78:0]        mag,
    input  signed [10:0] e_frame,
    output [23:0]        sig,      // significand before rounding (bit 23 = leading 1 if normal)
    output               guard,
    output               sticky,
    output signed [10:0] exp_b,    // biased exponent (0 = subnormal path)
    output               is_zero
);
    assign is_zero = (mag == 79'd0);

    function [6:0] msb79;          // index of the leading one (0 if none)
        input [78:0] v;
        integer i;
        begin
            msb79 = 7'd0;
            for (i = 0; i < 79; i = i + 1)
                if (v[i]) msb79 = i[6:0];
        end
    endfunction

    wire [6:0] m = msb79(mag);
    // biased exponent the result would have with the leading one at bit m
    wire signed [10:0] e_lead = e_frame - $signed({4'd0, 7'd78 - m});
    // normalise to bit 78; if that would go below the smallest exponent (1)
    // shift only as far as exponent 1 allows (subnormal result)
    wire               sub  = (e_lead < 11'sd1);
    wire signed [11:0] lsh  = sub ? ($signed({1'b0, e_frame}) - 12'sd1)   // shift so that bit 78 <-> 2^-126
                                  : $signed({5'd0, 7'd78 - m});
    wire [78:0] shl  = (lsh > 12'sd78) ? 79'd0 : (mag << lsh[6:0]);
    wire [11:0] rsh  = -lsh;
    wire [78:0] shr  = (rsh >= 12'd79) ? {78'd0, |mag}
                                       : ((mag >> rsh[6:0]) | {78'd0, |(mag & ~({79{1'b1}} << rsh[6:0]))});
    wire [78:0] norm = (lsh >= 12'sd0) ? shl : shr;

    assign sig    = norm[78:55];
    assign guard  = norm[54];
    assign sticky = |norm[53:0];
    assign exp_b  = sub ? 11'sd0 : e_lead;
endmodule

// -----------------------------------------------------------------------------
// stage 4: round to nearest even, overflow, pack
// -----------------------------------------------------------------------------
module fma_stage4 (
    input  [23:0]        sig,
    input                guard, sticky,
    input  signed [10:0] exp_b,
    input                sign,
    input                is_zero,
    input                zero_sign,
    input                special,
    input  [31:0]        special_res,
    output [31:0]        r
);
    wire        up   = guard & (sticky | sig[0]);
    wire [24:0] sum  = {1'b0, sig} + {24'd0, up};
    wire        cout = sum[24];                              // 1.11..1 + 1 = 10.0
    wire [22:0] frac = cout ? sum[23:1] : sum[22:0];
    // subnormal path (exp_b == 0): the result is normal iff bit 23 became 1
    wire signed [10:0] e_res = (exp_b == 11'sd0) ? {10'd0, sum[23]}
                                                 : exp_b + {10'd0, cout};
    wire ovf = (e_res >= 11'sd255);

    assign r = special ? special_res :
               is_zero ? {zero_sign, 31'd0} :
               ovf     ? {sign, 8'hFF, 23'd0} :
                         {sign, e_res[7:0], frac};
endmodule
