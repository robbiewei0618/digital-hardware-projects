// ============================================================
// 檔案: FLP_FMA.v
// 功能: IEEE-754 單精度浮點數融合乘加運算 (FMA)
//       計算 D = A * B + C
// 作者: [你的名字]
// 日期: 2025
// ============================================================

module FLP_FMA(
    input  [31:0] a,    // 輸入 A (IEEE-754 單精度)
    input  [31:0] b,    // 輸入 B (IEEE-754 單精度)
    input  [31:0] c,    // 輸入 C (IEEE-754 單精度)
    output [31:0] d     // 輸出 D = A*B+C (IEEE-754 單精度)
);

    // ========================================
    // 階段 1: 解包輸入 (Unpack Inputs)
    // ========================================
    wire sa, sb, sc;              // 符號位
    wire [7:0] ea, eb, ec;        // 指數部分 (8 bits)
    wire [22:0] ma, mb, mc;       // 尾數部分 (23 bits)
    
    assign {sa, ea, ma} = a;
    assign {sb, eb, mb} = b;
    assign {sc, ec, mc} = c;
    
    // 特殊數值檢測
    wire a_zero, b_zero, c_zero;  // 零
    wire a_inf, b_inf, c_inf;     // 無限大
    wire a_nan, b_nan, c_nan;     // 非數字 (NaN)
    
    assign a_zero = (ea == 8'd0) && (ma == 23'd0);
    assign b_zero = (eb == 8'd0) && (mb == 23'd0);
    assign c_zero = (ec == 8'd0) && (mc == 23'd0);
    assign a_inf = (ea == 8'd255) && (ma == 23'd0);
    assign b_inf = (eb == 8'd255) && (mb == 23'd0);
    assign c_inf = (ec == 8'd255) && (mc == 23'd0);
    assign a_nan = (ea == 8'd255) && (ma != 23'd0);
    assign b_nan = (eb == 8'd255) && (mb != 23'd0);
    assign c_nan = (ec == 8'd255) && (mc != 23'd0);
    
    // 加上隱藏位 (Hidden Bit)
    // 正規數：1.mantissa，次正規數：0.mantissa
    wire [23:0] ma_h, mb_h, mc_h;
    assign ma_h = (ea == 8'd0) ? {1'b0, ma} : {1'b1, ma};
    assign mb_h = (eb == 8'd0) ? {1'b0, mb} : {1'b1, mb};
    assign mc_h = (ec == 8'd0) ? {1'b0, mc} : {1'b1, mc};
    
    // ========================================
    // 階段 2: 乘法運算 A × B
    // ========================================
    wire sp;                      // 乘積符號
    wire [8:0] ea_adj, eb_adj;   // 調整後的指數 (處理次正規數)
    wire [47:0] mp;              // 48-bit 乘積 (24×24)
    
    assign sp = sa ^ sb;  // 符號：XOR 運算
    
    // 次正規數的指數視為 1 (而非 0)
    assign ea_adj = (ea == 8'd0) ? 9'd1 : {1'b0, ea};
    assign eb_adj = (eb == 8'd0) ? 9'd1 : {1'b0, eb};
    
    // 24-bit × 24-bit = 48-bit
    assign mp = ma_h * mb_h;
    
    // 歸一化乘積
    wire mp_ovf;              // 乘積溢位旗標 (最高位為 1)
    wire [47:0] mp_norm;      // 歸一化後的乘積
    wire [8:0] ep;            // 乘積指數
    
    assign mp_ovf = mp[47];
    // 如果溢位，不移位；否則左移 1 位使最高位為 1
    assign mp_norm = mp_ovf ? mp : {mp[46:0], 1'b0};
    // 指數計算：ea + eb - bias + 溢位調整
    assign ep = ea_adj + eb_adj - 9'd127 + {8'b0, mp_ovf};
    
    // ========================================
    // 階段 3: 指數對齊 (Exponent Alignment)
    // ========================================
    wire [8:0] ec_adj;
    assign ec_adj = (ec == 8'd0) ? 9'd1 : {1'b0, ec};
    
    // 計算指數差異
    wire signed [9:0] exp_diff;
    wire c_larger;               // C 的指數較大
    wire [8:0] exp_aligned;      // 對齊後的共同指數
    
    assign exp_diff = $signed({1'b0, ep}) - $signed({1'b0, ec_adj});
    assign c_larger = exp_diff[9];  // 符號位表示誰較大
    
    // 選擇較大的指數作為對齊基準
    assign exp_aligned = c_larger ? ec_adj : ep;
    
    // 計算位移量 (絕對值)
    wire [9:0] exp_diff_abs;
    assign exp_diff_abs = c_larger ? (~exp_diff + 10'd1) : exp_diff;
    
    // 限制最大位移量為 75 (避免硬體過大)
    wire [7:0] shift_amt;
    assign shift_amt = (exp_diff_abs > 10'd75) ? 8'd75 : exp_diff_abs[7:0];
    
    // 建立擴展尾數 (Q2.73 格式: 2位整數 + 73位小數)
    wire [74:0] prod_ext, c_ext;
    assign prod_ext = {1'b0, mp_norm, 26'b0};  // 乘積：48-bit尾數 + 26-bit guard
    assign c_ext = {1'b0, mc_h, 50'b0};        // C：24-bit尾數 + 50-bit guard
    
    // 對齊：將指數較小的右移
    wire [74:0] prod_aligned, c_aligned;
    assign prod_aligned = c_larger ? (prod_ext >> shift_amt) : prod_ext;
    assign c_aligned = c_larger ? c_ext : (c_ext >> shift_amt);
    
    // ========================================
    // 階段 4: 加法/減法運算
    // ========================================
    wire eff_add;                // 有效加法 (同號為真)
    wire [75:0] sum_temp;        // 76-bit 暫存結果
    wire result_sign;            // 結果符號
    
    assign eff_add = (sp == sc); // 符號相同 → 加法，否則 → 減法
    
    // 根據操作類型計算
    assign sum_temp = eff_add ?
                      // 加法：直接相加
                      {1'b0, prod_aligned} + {1'b0, c_aligned} :
                      // 減法：大減小 (比較尾數大小)
                      (prod_aligned >= c_aligned) ?
                       {1'b0, prod_aligned - c_aligned} :
                       {1'b0, c_aligned - prod_aligned};
    
    // 符號判斷
    // 加法：使用乘積符號
    // 減法：使用絕對值較大者的符號
    assign result_sign = eff_add ? sp : 
                         (prod_aligned >= c_aligned ? sp : sc);
    
    wire [74:0] sum_abs;
    assign sum_abs = sum_temp[74:0];
    
    // ========================================
    // 階段 5: 歸一化 (Normalization)
    // ========================================
    
    // 前導零計數 (Leading Zero Count)
    wire [6:0] lzc;
    wire upper_zero;
    
    // 檢查高 38 位是否全為零
    assign upper_zero = (sum_abs[74:37] == 38'd0);
    
    // 高 38 位的前導零計數 (優先搜尋)
    wire [3:0] lzc_h;
    assign lzc_h = 
        sum_abs[74] ? 4'd0 : sum_abs[73] ? 4'd1 : sum_abs[72] ? 4'd2 : sum_abs[71] ? 4'd3 :
        sum_abs[70] ? 4'd4 : sum_abs[69] ? 4'd5 : sum_abs[68] ? 4'd6 : sum_abs[67] ? 4'd7 :
        sum_abs[66] ? 4'd8 : sum_abs[65] ? 4'd9 : sum_abs[64] ? 4'd10 : sum_abs[63] ? 4'd11 :
        sum_abs[62] ? 4'd12 : sum_abs[61] ? 4'd13 : sum_abs[60] ? 4'd14 : sum_abs[59] ? 4'd15 :
        sum_abs[58] ? 4'd16 : sum_abs[57] ? 4'd17 : sum_abs[56] ? 4'd18 : sum_abs[55] ? 4'd19 :
        sum_abs[54] ? 4'd20 : sum_abs[53] ? 4'd21 : sum_abs[52] ? 4'd22 : sum_abs[51] ? 4'd23 :
        sum_abs[50] ? 4'd24 : sum_abs[49] ? 4'd25 : sum_abs[48] ? 4'd26 : sum_abs[47] ? 4'd27 :
        sum_abs[46] ? 4'd28 : sum_abs[45] ? 4'd29 : sum_abs[44] ? 4'd30 : sum_abs[43] ? 4'd31 :
        sum_abs[42] ? 4'd32 : sum_abs[41] ? 4'd33 : sum_abs[40] ? 4'd34 : sum_abs[39] ? 4'd35 :
        sum_abs[38] ? 4'd36 : sum_abs[37] ? 4'd37 : 4'd38;
    
    // 低 37 位的前導零計數 (次要搜尋)
    wire [5:0] lzc_l;
    assign lzc_l = 
        sum_abs[36] ? 6'd0 : sum_abs[35] ? 6'd1 : sum_abs[34] ? 6'd2 : sum_abs[33] ? 6'd3 :
        sum_abs[32] ? 6'd4 : sum_abs[31] ? 6'd5 : sum_abs[30] ? 6'd6 : sum_abs[29] ? 6'd7 :
        sum_abs[28] ? 6'd8 : sum_abs[27] ? 6'd9 : sum_abs[26] ? 6'd10 : sum_abs[25] ? 6'd11 :
        sum_abs[24] ? 6'd12 : sum_abs[23] ? 6'd13 : sum_abs[22] ? 6'd14 : sum_abs[21] ? 6'd15 :
        sum_abs[20] ? 6'd16 : sum_abs[19] ? 6'd17 : sum_abs[18] ? 6'd18 : sum_abs[17] ? 6'd19 :
        sum_abs[16] ? 6'd20 : sum_abs[15] ? 6'd21 : sum_abs[14] ? 6'd22 : sum_abs[13] ? 6'd23 :
        sum_abs[12] ? 6'd24 : sum_abs[11] ? 6'd25 : sum_abs[10] ? 6'd26 : sum_abs[9] ? 6'd27 :
        sum_abs[8] ? 6'd28 : sum_abs[7] ? 6'd29 : sum_abs[6] ? 6'd30 : sum_abs[5] ? 6'd31 :
        sum_abs[4] ? 6'd32 : sum_abs[3] ? 6'd33 : sum_abs[2] ? 6'd34 : sum_abs[1] ? 6'd35 :
        sum_abs[0] ? 6'd36 : 6'd37;
    
    // 組合總前導零數
    assign lzc = upper_zero ? (7'd38 + {1'b0, lzc_l}) : {3'b0, lzc_h};
    
    // 左移消除前導零
    wire [74:0] sum_norm;
    assign sum_norm = sum_abs << lzc;
    
    // 調整指數 (減去左移量，+1 是因為格式約定)
    wire signed [10:0] exp_normalized;
    assign exp_normalized = $signed({2'b0, exp_aligned}) - $signed({4'b0, lzc}) + 11'sd1;
    
    // ========================================
    // 階段 6: 舍入 (Rounding)
    // ========================================
    // 使用 Round-to-Nearest-Even (銀行家舍入法)
    
    wire g, r, s;        // Guard, Round, Sticky bits
    wire rnd_up;         // 舍入向上旗標
    
    assign g = sum_norm[51];           // Guard bit (第 51 位)
    assign r = sum_norm[50];           // Round bit (第 50 位)
    assign s = |sum_norm[49:0];        // Sticky bit (第 0-49 位有任一為 1)
    
    // 舍入條件：GRS = 1XX 或 GRS = 011 (且尾數為奇數)
    assign rnd_up = g && (r || s || sum_norm[52]);
    
    wire [24:0] mant_rounded;
    wire rnd_carry;
    assign mant_rounded = {1'b0, sum_norm[74:51]} + {24'b0, rnd_up};
    assign rnd_carry = mant_rounded[24];  // 舍入進位
    
    wire [22:0] mant_final;
    wire signed [10:0] exp_final;
    assign mant_final = rnd_carry ? mant_rounded[23:1] : mant_rounded[22:0];
    assign exp_final = exp_normalized + {10'b0, rnd_carry};
    
    // ========================================
    // 階段 7: 特殊情況處理與封裝
    // ========================================
    wire is_nan, is_inf, is_zero, is_subnorm;
    
    // NaN 情況：輸入有 NaN，或無效運算 (0×∞, ∞-∞)
    assign is_nan = a_nan || b_nan || c_nan ||
                    (a_inf && b_zero) || (a_zero && b_inf) ||
                    ((a_inf || b_inf) && c_inf && (sp != sc));
    
    // 無限大情況：輸入有 ∞，或結果溢位
    assign is_inf = ~is_nan && (a_inf || b_inf || c_inf || (exp_final >= 11'sd255));
    
    // 零情況：A或B為零且C為零，或結果太小
    assign is_zero = ~is_nan && ~is_inf && 
                     (((a_zero || b_zero) && c_zero) || 
                      (sum_abs == 75'd0) || 
                      (exp_final <= -11'sd24));
    
    // 次正規數情況：指數 ≤ 0 但不是零
    assign is_subnorm = ~is_nan && ~is_inf && ~is_zero && 
                        (exp_final <= 11'sd0) && (exp_final > -11'sd24);
    
    // 次正規數處理：右移尾數以補償負指數
    wire [5:0] subnorm_shift;
    wire [23:0] mant_subnorm;
    assign subnorm_shift = is_subnorm ? (6'd1 - exp_final[5:0]) : 6'd0;
    assign mant_subnorm = {1'b1, mant_final} >> subnorm_shift;
    
    // 最終輸出封裝
    wire [7:0] exp_out;
    wire [22:0] mant_out;
    wire sign_out;
    
    assign exp_out = is_nan ? 8'd255 :           // NaN: 指數全 1
                     is_inf ? 8'd255 :           // ∞: 指數全 1
                     is_zero ? 8'd0 :            // 0: 指數全 0
                     is_subnorm ? 8'd0 :         // 次正規數: 指數為 0
                     exp_final[7:0];             // 正常數: 實際指數
    
    assign mant_out = is_nan ? 23'h400000 :      // NaN: 尾數非零 (Quiet NaN)
                      is_inf ? 23'd0 :           // ∞: 尾數為 0
                      is_zero ? 23'd0 :          // 0: 尾數為 0
                      is_subnorm ? mant_subnorm[22:0] : // 次正規: 調整後尾數
                      mant_final;                // 正常: 實際尾數
    
    assign sign_out = is_nan ? 1'b0 :            // NaN: 正號
                      is_zero ? 1'b0 :           // 0: 正號
                      result_sign;               // 其他: 計算的符號
    
    // 組合最終輸出 [符號|指數|尾數]
    assign d = {sign_out, exp_out, mant_out};

endmodule