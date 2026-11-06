// ============================================================================
// 浮點數融合乘加運算器 (Floating-Point Fused Multiply-Add, FMA)
// 功能：R = A × B + C
// 標準：純 Verilog-2001 (IEEE 1364-2001)
// 作者：M133040086
// 日期：2025
// 
// 設計目標：
// 1. 實現 IEEE-754 單精度浮點數的 FMA 運算
// 2. 一次性對齊與歸一化，減少延遲
// 3. 正確處理所有特殊值（NaN、Infinity、Zero、Subnormal）
// 4. 符合 Verilog-2001 標準，確保可綜合性
// ============================================================================

`timescale 1ns/1ps

module FLP_FMA (
    input  [31:0] A,    // 被乘數 (IEEE-754 單精度格式)
    input  [31:0] B,    // 乘數 (IEEE-754 單精度格式)
    input  [31:0] C,    // 加數 (IEEE-754 單精度格式)
    output [31:0] R     // 結果 R = A×B + C
);

  // ========================================================================
  // 參數定義
  // ========================================================================
  parameter W = 80;     // 內部計算寬度
                        // 需求分析：Q28.48 格式
                        //   - 28 個整數位：1(符號) + 24(Mc) + 2(乘積<4) + 1(加法溢位)
                        //   - 48 個小數位：46(精度) + 2(GRS 捨入位)
                        //   - 實際需要 76 位，取 80 方便計算

  // ========================================================================
  // 步驟 1：輸入拆解
  // 目的：將 IEEE-754 格式拆解為符號、指數、尾數三部分
  // ========================================================================
  wire        sa, sb, sc;      // 符號位 (Sign bit)
  wire [7:0]  ea, eb, ec;      // 指數位 (Exponent)：8 位，偏移值 127
  wire [22:0] ma, mb, mc;      // 尾數位 (Mantissa/Fraction)：23 位，隱藏位為 1

  // IEEE-754 單精度格式：[符號(1) | 指數(8) | 尾數(23)]
  assign sa = A[31];            // A 的符號位
  assign ea = A[30:23];         // A 的指數
  assign ma = A[22:0];          // A 的尾數
  
  assign sb = B[31];
  assign eb = B[30:23];
  assign mb = B[22:0];
  
  assign sc = C[31];
  assign ec = C[30:23];
  assign mc = C[22:0];

  // ========================================================================
  // 步驟 2：特殊值檢測
  // 目的：提前識別特殊數值，避免錯誤計算
  // 
  // IEEE-754 特殊值定義：
  //   - Zero：指數 = 0，尾數 = 0
  //   - Infinity：指數 = 255，尾數 = 0
  //   - NaN：指數 = 255，尾數 ≠ 0
  //   - Subnormal：指數 = 0，尾數 ≠ 0
  // ========================================================================
  wire a_zero, b_zero, c_zero;  // 零值檢測
  wire a_inf,  b_inf,  c_inf;   // 無限大檢測
  wire a_nan,  b_nan,  c_nan;   // NaN 檢測

  assign a_zero = (ea == 8'd0)   && (ma == 23'd0);
  assign b_zero = (eb == 8'd0)   && (mb == 23'd0);
  assign c_zero = (ec == 8'd0)   && (mc == 23'd0);
  
  assign a_inf  = (ea == 8'd255) && (ma == 23'd0);
  assign b_inf  = (eb == 8'd255) && (mb == 23'd0);
  assign c_inf  = (ec == 8'd255) && (mc == 23'd0);
  
  assign a_nan  = (ea == 8'd255) && (ma != 23'd0);
  assign b_nan  = (eb == 8'd255) && (mb != 23'd0);
  assign c_nan  = (ec == 8'd255) && (mc != 23'd0);

  // ========================================================================
  // 步驟 3：尾數還原（加上隱藏位）
  // 目的：將 IEEE-754 的隱藏位顯式表示 轉乘我們所看到的浮點數
  // 
  // 設計考量：
  //   - 正規數：隱藏位 = 1，實際值為 1.xxx（範圍 [1, 2)）
  //   - 次正規數：隱藏位 = 0，實際值為 0.xxx（範圍 (0, 1)）
  //   - 格式：Q1.23（1 個整數位 + 23 個小數位 = 24 位）
  // ========================================================================
  wire [23:0] Ma, Mb, Mc;       // 帶隱藏位的尾數（24 位）

  assign Ma = (ea == 8'd0) ? {1'b0, ma} : {1'b1, ma};//ea = 0 指數為全0 要加上隱藏位 = 0 實際值為 0.xxx
  assign Mb = (eb == 8'd0) ? {1'b0, mb} : {1'b1, mb};
  assign Mc = (ec == 8'd0) ? {1'b0, mc} : {1'b1, mc};

  // ========================================================================
  // 步驟 4：指數計算（未偏移值）
  // 目的：統一處理正規數和次正規數的指數
  // 
  // IEEE-754 指數表示：
  //   - 儲存值 = 實際指數 + 127（偏移值）
  //   - 正規數：ea ∈ [1, 254] → 實際指數 ∈ [-126, 127]
  //   - 次正規數：ea = 0 → 實際指數固定為 -126（等效於 ea=1） 
  // 
  // 設計考量：
  //   - 使用 9 位表示有效指數（1~255）原始IEEE-754的指數 因為非正規化數真實指數固定為2^-126 故其原始IEEE-754的指數就是1
  //   - 使用 11 位有符號數表示未偏移指數（-126~127）
  // ========================================================================
  wire [8:0] ea_eff, eb_eff, ec_eff;        // 有效指數（9 位無符號）
  wire signed [10:0] ea_unb, eb_unb, ec_unb;  // 未偏移指數（11 位有符號） 減去bias後的指數為實際指數 

  // 次正規數的IEEE-754 指數視為 1（而非 0）
  assign ea_eff = (ea == 8'd0) ? 9'd1 : {1'b0, ea};
  assign eb_eff = (eb == 8'd0) ? 9'd1 : {1'b0, eb};
  assign ec_eff = (ec == 8'd0) ? 9'd1 : {1'b0, ec};

  // 計算尚未偏移時的指數：實際指數 = 指數 IEEE-754 - 127 
  assign ea_unb = $signed({2'b00, ea_eff}) - 11'sd127;
  assign eb_unb = $signed({2'b00, eb_eff}) - 11'sd127;
  assign ec_unb = $signed({2'b00, ec_eff}) - 11'sd127;

  // ========================================================================
  // 步驟 5：乘法運算
  // 目的：計算 A × B 的乘積
  // 
  // 數學原理：
  //   - 符號：sa ⊕ sb（XOR）
  //   - 指數：ea_unb + eb_unb
  //   - 尾數：Ma × Mb
  // 
  // 格式轉換：
  //   - Ma, Mb：Q1.23（24 位）
  //   - Mp = Ma × Mb：Q2.46（48 位）
  //   - 範圍：[1, 4) 或 (-4, -1]
  // ========================================================================
  wire sp;                      // 乘積符號
  wire [47:0] Mp;               // 乘積尾數（48 位）
  wire signed [10:0] ep_unb;    // 乘積指數（未偏移）

  assign sp = sa ^ sb;          // 符號位 XOR
  assign Mp = Ma * Mb;          // 24×24 = 48 位乘法
  assign ep_unb = ea_unb + eb_unb;  // 實際的指數相加

  // ========================================================================
  // 步驟 6：對齊邏輯
  // 目的：將乘積 P 和加數 C 對齊到相同的小數點位置 C去配合P
  // 
  // 關鍵創新：在計算 A×B 的同時對齊 C，減少延遲
  // 
  // 對齊策略：
  //   1. 比較 ep_unb 和 ec_unb，決定基準指數
  //   2. 將較小指數的數值右移對齊
  //   3. 使用 sticky bit 保留精度
  // 
  // 格式設計：
  //   - Pq_raw：將 Mp(48位) 放在低位 [47:0] 
  //   - Cq_raw：將 Mc(24位) 左移 23 位到 [46:23]，對齊小數點
  //   - 最終統一為 Q28.48 格式（80 位）
  // ========================================================================
  wire [W-1:0] Pq_raw, Cq_raw;  // 擴展到工作寬度的原始值

  assign Pq_raw = {{(W-48){1'b0}}, Mp};           // Mp 放在 [47:0] 80-48=32 
  assign Cq_raw = {{(W-47){1'b0}}, Mc, 23'b0};    // Mc 左移 23 位到 [46:23]
                                                   // 為什麼左移 23？
                                                   //   Mp 有 46 位小數
                                                   //   Mc 有 23 位小數
                                                   //   差距 = 46-23 = 23 位

  // 計算指數差異
  wire signed [10:0] diff_signed;   // 指數差（有符號）
  wire use_ep;                      // 是否使用 ep 作為基準
  wire [10:0] diff_abs;             // 指數差的絕對值
  wire [6:0] diff_clamped;          // 裁剪後的移位量（最大 80）
  wire signed [10:0] eq_unb;        // 基準指數

  assign diff_signed = ep_unb - ec_unb; //ep-ec
  assign use_ep = (diff_signed >= 11'sd0);  // ep ≥ ec 時使用 ep
  assign diff_abs = (diff_signed[10]) ? (-diff_signed) : diff_signed; // 插植要做絕對值
  assign diff_clamped = (diff_abs > W) ? W[6:0] : diff_abs[6:0];
  assign eq_unb = use_ep ? ep_unb : ec_unb;

  // ========================================================================
  // Sticky Bit 右移函數
  // 目的：在右移時保留所有被移出位的資訊，確保捨入精度
  // 
  // Sticky Bit 原理：
  //   - 將所有被移出的位元 OR 在一起
  //   - 如果任何一位是 1，則 sticky = 1
  //   - 將 sticky 保留在結果的 LSB
  // 
  // 設計考量：
  //   - 移位量 = 0：直接返回原值
  //   - 移位量 ≥ W：所有位元都被移出，只保留 sticky
  //   - 其他情況：右移並在 LSB 保留 sticky
  // ========================================================================
  function [W-1:0] shr_sticky;
    input [W-1:0] val;      // 輸入值
    input [6:0]   shamt;    // 移位量
    reg [W-1:0]   shifted;  // 移位後的值
    reg           sticky;   // 黏性位元
    integer i;
    begin
      if (shamt == 0) begin
        // 不移位
        shr_sticky = val;
      end else if (shamt >= W) begin
        // 全部移出，只保留 sticky
        sticky = 1'b0;
        for (i = 0; i < W; i = i + 1) begin
          sticky = sticky | val[i];  // OR 所有位元
        end
        shr_sticky = {{(W-1){1'b0}}, sticky};
      end else begin
        // 正常右移 + sticky
        sticky = 1'b0;
        // 收集被移出的位元
        for (i = 0; i < shamt; i = i + 1) begin
          sticky = sticky | val[i];
        end
        shifted = (val >> shamt);     // 執行右移 邏輯右移
        shr_sticky = shifted | {{(W-1){1'b0}}, sticky};  // 在 LSB 加入 sticky
      end
    end
  endfunction

  // 執行對齊
  wire [W-1:0] Pq_aln, Cq_aln;  // 對齊後的值

  // 根據指數大小決定誰要右移 Pq_raw 乘完的小數部分(經擴充過)
  assign Pq_aln = use_ep ? Pq_raw : shr_sticky(Pq_raw, diff_clamped);//use_ep = 1 ep > ec 指數小的去右移配合指數大的
  assign Cq_aln = use_ep ? shr_sticky(Cq_raw, diff_clamped) : Cq_raw;
  // Pq_aln Cq_aln = > 經位移後的小數部分 對齊後的值
  // ========================================================================
  // 步驟 7：二補數加法（統一路徑設計） 這時候才要做小數部分的加減法(要先對齊好)
  // 目的：將加法和減法統一為一個加法器
  // 
  // 設計亮點：
  //   - 傳統方法：分別處理加法路徑和減法路徑
  //   - 本設計：使用二補數統一處理，簡化硬體
  // 
  // 數學原理：
  //   - 正數：直接表示
  //   - 負數：取二補數（取反 + 1）
  //   - 加法器自動處理符號
  // 
  // 優點：
  //   1. 硬體結構簡單（只需一個加法器）
  //   2. 不需要比較大小
  //   3. 符號自動由加法結果決定
  // ========================================================================
  wire signed [W:0] p_2c, c_2c;     // 二補數表示（81 位有符號）
  wire signed [W:0] sum_2c;         // 加法結果（有符號）

  // 轉換為二補數：負數時取負值
  assign p_2c = sp ? (-$signed({1'b0, Pq_aln})) : $signed({1'b0, Pq_aln});
  assign c_2c = sc ? (-$signed({1'b0, Cq_aln})) : $signed({1'b0, Cq_aln});
  
  // 執行加法（加法器自動處理符號）
  assign sum_2c = p_2c + c_2c;//1.0101001 + 0.1011111 但正負數是要看 sign bits

  // 提取結果的符號和絕對值
  wire res_sign_raw;                // 原始符號
  wire [W:0] sum_abs_wide;          // 絕對值（81 位）

  assign res_sign_raw = sum_2c[W];  // MSB 是符號位
  assign sum_abs_wide = res_sign_raw ? (-sum_2c) : sum_2c;  
  // 取絕對值 因為在真實小數中沒有真的"-" 所以經過有號的加減法後小數只能是正數再配上sign bit表示正負
  // ========================================================================
  // 步驟 8：溢位處理
  // 目的：處理同號相加時可能發生的溢位
  // 
  // 溢位情況：
  //   - 發生條件：同號相加（add_path = 1）且結果 MSB = 1
  //   - 處理方式：右移 1 位，指數 +1
  //   - Sticky 保留：將被移出的兩位 OR 後保存
  // 
  // 設計考量：
  //   - 使用 reg 而非 wire，避免組合迴圈
  //   - 使用 always @* 而非 generate，符合 Verilog-2001
  // ========================================================================
  wire add_path;                    // 是否為加法路徑（同號）
  wire add_overflow;                // 是否溢位
  reg [W-1:0] sum_abs;              // 處理後的絕對值（80 位）
  reg signed [10:0] eq_adj;         // 調整後的基準指數

  assign add_path = (sp == sc);     // 同號為加法，異號為減法
  assign add_overflow = add_path && sum_abs_wide[W];  // 加法且 MSB=1 表示溢位
  // ex Pq_aln ≈ 1.0110₂ × 2^5 + Cq_aln ≈ 1.1001₂ × 2^5 = sum_abs_wide ≈ 10.1111₂ × 2^5 => sum_abs = 1.01111₂ × 2^6
  always @* begin
    if (add_overflow) begin
      // 溢位處理：右移 1 位，保留 sticky 右移指數增加
      sum_abs = {sum_abs_wide[W:2], (sum_abs_wide[1] | sum_abs_wide[0])};//右移且將sum_abs_wide[1]G bit 與 被shift出去的sticky bit做or
      eq_adj = eq_unb + 11'sd1;     // 指數 +1
    end else begin
      // 正常情況
      sum_abs = sum_abs_wide[W-1:0];
      eq_adj = eq_unb;
    end
  end
  // eq_adj 溢位處理後的指數
  // 零值檢測與符號處理
  wire mag_zero;                    // 結果是否為零
  wire res_sign;                    // 最終符號

  assign mag_zero = (sum_abs == {W{1'b0}});
  assign res_sign = mag_zero ? 1'b0 : res_sign_raw;  // 零的符號為正

  // ========================================================================
  // 步驟 9：歸一化 (Normalization)
  // 目的：將結果調整為標準浮點格式 1.xxx
  // 
  // 歸一化步驟：
  //   1. 找到最高有效位 (Leading One Detection)
  //   2. 計算需要移位的量
  //   3. 執行移位，調整指數
  // 
  // 目標位置：bit 46（隱藏位位置）
  //   [79:47] | [46] | [45:23] | [22:0]
  //    整數    隱藏位   尾數23位   GRS位
  // 
  // 設計考量：
  //   - 左移：msb_pos < 46（數值太小）
  //   - 右移：msb_pos > 46（數值太大）
  //   - 右移時保留 sticky bit
  // ========================================================================
  
  // 找到最高有效位 (MSB) 的函數
  function [6:0] find_msb;
    input [W-1:0] val;      // 輸入值
    integer i;
    reg found;              // 是否找到
    begin
      find_msb = 7'd0;
      found = 1'b0;
      // 從高位向低位搜尋第一個 1
      for (i = W-1; i >= 0; i = i - 1) begin
        if (val[i] && !found) begin
          find_msb = i[6:0];
          found = 1'b1;       // 找到後停止
        end
      end
    end
  endfunction

  wire [6:0] msb_pos;               // 最高有效位位置
  wire signed [7:0] shift_amt;      // 移位量（有符號）

  assign msb_pos = find_msb(sum_abs);
  assign shift_amt = $signed({1'b0, msb_pos}) - $signed(8'd46);  // 距離目標位置的距離

  // 執行歸一化移位
  reg [W-1:0] sum_norm;             // 歸一化後的值
  
  always @* begin
    if (shift_amt > 0) begin
      // 右移（數值太大）
      sum_norm = shr_sticky(sum_abs, shift_amt[6:0]);
    end else if (shift_amt < 0) begin
      // 左移（數值太小）
      sum_norm = sum_abs << (-shift_amt);
    end else begin
      // 不需要移位
      sum_norm = sum_abs;
    end
  end

  // 調整指數
  wire signed [10:0] exp_norm_unb;  // 歸一化後的指數

  assign exp_norm_unb = eq_adj + $signed({{4{shift_amt[7]}}, shift_amt[6:0]});
  // 符號擴展：將 8 位有符號數擴展為 11 位

  // ========================================================================
  // 步驟 10：捨入 (Rounding)
  // 目的：將結果捨入到 24 位精度
  // 
  // IEEE-754 捨入模式：Round-to-Nearest-Even (RNE)
  //   - G (Guard)：第 23 位（捨入位）
  //   - R (Round)：第 24 位
  //   - S (Sticky)：第 25 位及以下的 OR
  // 
  // 捨入規則：
  //   - round_up = G & (R | S | LSB)
  //   - 當 G=1 且（R=1 或 S=1 或結果為奇數）時進位
  //   - 這確保了「偶數優先」的捨入
  // 
  // 捨入進位處理：
  //   - 可能導致尾數溢位（24位 → 25位）
  //   - 需要右移 1 位，指數 +1
  // ========================================================================
  wire [23:0] mant_raw;             // 原始尾數（24 位）
  wire g, r, s;                     // GRS 捨入位
  wire round_up;                    // 是否進位
  wire [24:0] mant_rounded;         // 捨入後的尾數（可能 25 位）
  wire round_carry;                 // 捨入進位
  wire [22:0] frac_final;           // 最終尾數（23 位）
  wire signed [10:0] exp_final_unb; // 最終指數

  // 提取尾數和 GRS 位
  //   sum_norm: [...][46][45:23][22][21][20:0]
  //                   隱藏  尾數   G  R    S
  assign mant_raw = sum_norm[46:23];  // 包含隱藏位的 24 位尾數
  assign g = sum_norm[22];            // Guard bit
  assign r = sum_norm[21];            // Round bit
  assign s = |sum_norm[20:0];         // Sticky bit（OR 所有低位）

  // 決定是否進位
  assign round_up = g && (r || s || mant_raw[0]);
  // 解釋：
  //   - g=1：捨入位為 1（接近進位邊界）
  //   - r|s：有更低的非零位（超過中點）
  //   - mant_raw[0]：結果為奇數（偶數優先規則）

  // 執行捨入
  assign mant_rounded = {1'b0, mant_raw} + {24'd0, round_up};
  assign round_carry = mant_rounded[24];  // 檢查是否溢位到第 25 位

  // 處理捨入進位
  assign frac_final = round_carry ? mant_rounded[23:1] : mant_rounded[22:0];
  assign exp_final_unb = exp_norm_unb + {10'd0, round_carry};

  // ========================================================================
  // 步驟 11：特殊情況處理
  // 目的：根據 IEEE-754 標準處理所有特殊值
  // 
  // 優先級（由高到低）：
  //   1. NaN（任何運算涉及 NaN 都產生 NaN）
  //   2. 不定式（Inf×0、Inf-Inf）產生 NaN
  //   3. Infinity（Inf 的運算規則）
  //   4. Overflow（結果太大）→ Infinity
  //   5. Underflow（結果太小）→ Zero
  //   6. Subnormal（次正規數）
  //   7. Normal（正規數）
  // ========================================================================
  wire indet_mul;                   // 不定式：Inf×0
  wire inf_cancel;                  // 不定式：Inf-Inf
  wire any_nan;                     // 是否產生 NaN
  wire p_inf;                       // 乘積是否為 Inf
  wire any_inf;                     // 是否涉及 Inf
  wire overflow;                    // 是否溢位
  wire underflow;                   // 是否下溢
  wire subnormal;                   // 是否為次正規數

  // NaN 產生條件
  assign indet_mul = (a_inf && b_zero) || (a_zero && b_inf);  // Inf × 0
  assign inf_cancel = ((a_inf || b_inf) && c_inf && (sp != sc));  // Inf - Inf
  assign any_nan = a_nan || b_nan || c_nan || indet_mul || inf_cancel;

  // Infinity 檢測
  assign p_inf = a_inf || b_inf;    // 乘積是否為 Inf
  assign any_inf = p_inf || c_inf;  // 是否涉及 Inf

  // 溢位與下溢檢測
  assign overflow  = (exp_final_unb > 11'sd127);    // 指數 > 127
  assign underflow = (exp_final_unb < -11'sd149);   // 指數 < -149
  
  // 次正規數範圍：-149 ≤ exp < -126
  assign subnormal = (!overflow && !underflow && (exp_final_unb < -11'sd126));

  // 次正規數處理
  wire signed [11:0] sub_shift_calc;  // 次正規數移位量計算
  wire [7:0] sub_shift;               // 實際移位量
  wire [24:0] sub_mant;               // 次正規數尾數

  // 計算需要右移的量：從 -126 到實際指數的距離
  assign sub_shift_calc = -11'sd126 - exp_final_unb;
  assign sub_shift = subnormal ? sub_shift_calc[7:0] : 8'd0;
  
  // 執行右移（隱藏位變為尾數的一部分）
  assign sub_mant = ({1'b1, frac_final} >> sub_shift);

  // ========================================================================
  // 步驟 12：輸出封裝
  // 目的：根據不同情況組裝 IEEE-754 格式的輸出
  // 
  // 輸出格式：[符號(1) | 指數(8) | 尾數(23)]
  // 
  // 決策樹：
  //   if (NaN)           → 0 11111111 10000000000000000000000 (Quiet NaN)
  //   else if (Zero)     → 0 00000000 00000000000000000000000
  //   else if (Inf)      → s 11111111 00000000000000000000000
  //   else if (Overflow) → s 11111111 00000000000000000000000
  //   else if (Underflow)→ s 00000000 00000000000000000000000
  //   else if (Subnormal)→ s 00000000 xxxxxxxxxxxxxxxxxxxxxxx
  //   else (Normal)      → s eeeeeeee xxxxxxxxxxxxxxxxxxxxxxx
  // ========================================================================
  reg        sign_out;              // 輸出符號
  reg [7:0]  exp_out;               // 輸出指數
  reg [22:0] frac_out;              // 輸出尾數

  always @* begin
    // 優先級 1：NaN
    if (any_nan) begin
      sign_out = 1'b0;              // NaN 符號通常為 0
      exp_out  = 8'd255;            // 指數全 1
      frac_out = 23'h400000;        // 尾數最高位為 1（Quiet NaN）
    
    // 優先級 2：Zero
    end else if (mag_zero || (a_zero && b_zero)) begin
      sign_out = 1'b0;              // +0（IEEE-754 中 +0 = -0）
      exp_out  = 8'd0;
      frac_out = 23'd0;
    
    // 優先級 3：Infinity
    end else if (any_inf) begin
      // 特殊處理：如果只有 C 是 Inf，使用 C 的符號
      if (c_inf && !p_inf) begin
        sign_out = sc;
      end else begin
        sign_out = sp;              // 否則使用乘積的符號
      end
      exp_out  = 8'd255;            // 指數全 1
      frac_out = 23'd0;             // 尾數全 0
    
    // 優先級 4：Overflow → Infinity
    end else if (overflow) begin
      sign_out = res_sign;          // 保留符號
      exp_out  = 8'd255;
      frac_out = 23'd0;
    
    // 優先級 5：Underflow → Zero
    end else if (underflow) begin
      sign_out = res_sign;          // 保留符號
      exp_out  = 8'd0;
      frac_out = 23'd0;
    
    // 優先級 6：Subnormal
    end else if (subnormal) begin
      sign_out = res_sign;
      exp_out  = 8'd0;              // 次正規數指數為 0
      frac_out = sub_mant[22:0];    // 使用移位後的尾數
    
    // 優先級 7：Normal（正規數）
    end else begin
      sign_out = res_sign;
      exp_out  = exp_final_unb[7:0] + 8'd127;  // 加回偏移值 127
      frac_out = frac_final;        // 正常的 23 位尾數
    end
  end

  // 組裝最終輸出
  assign R = {sign_out, exp_out, frac_out};

endmodule
```

---

# 📊 設計思路總結

## **整體架構**
```
輸入 A,B,C (IEEE-754)
    ↓
【1. 拆解】→ 符號、指數、尾數
    ↓
【2. 特殊值檢測】→ Zero, Inf, NaN
    ↓
【3. 加隱藏位】→ Ma, Mb, Mc (24-bit)
    ↓
【4. 指數計算】→ 未偏移值
    ↓
【5. 乘法】→ Mp = Ma × Mb (48-bit)
    ↓
【6. 對齊】→ 統一為 Q28.48 (80-bit)
    ↓         ↑
    └─(同時進行)
    ↓
【7. 二補數加法】→ 統一加減路徑
    ↓
【8. 溢位處理】→ 右移 + 指數調整
    ↓
【9. 歸一化】→ 對齊到 bit 46
    ↓
【10. 捨入】→ Round-to-Nearest-Even
    ↓
【11. 特殊情況】→ NaN, Inf, Over/Underflow
    ↓
【12. 輸出封裝】→ IEEE-754 格式
    ↓
輸出 R