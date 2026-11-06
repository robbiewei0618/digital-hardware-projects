# HW5: Truncated Multiplier Designs 


設計5種無符號截斷乘法器，支援8x8和16x16兩種精度：
1. **operator** - Verilog * 運算子
2. **row** - 部分積列累加 (無截斷)
3. **trunc_const_row** - 常數校正截斷乘法器
4. **array** - 陣列乘法器
5. **trunc_var_array** - 變數校正截斷陣列乘法器

輸出為n位元MSB部分 [2n-1:n]，最大誤差 < 1 ULP = 2^(n-1)

## k值選擇 (根據講義Fig.4)

| n | 方法 | k | r=n-k | 最大誤差 |
|---|------|---|-------|---------|
| 8 | Constant | 3 | 5 | < 128 |
| 8 | Variable | 2 | 6 | < 128 |
| 16 | Constant | 4 | 12 | < 32768 |
| 16 | Variable | 3 | 13 | < 32768 |

## 檔案結構

```
hw5/
├── rtl/
│   ├── mul_operator.v          # Verilog * 運算子
│   ├── mul_row.v               # 列累加 (無截斷)
│   ├── mul_trunc_const_row.v   # 常數校正
│   ├── mul_array.v             # 陣列乘法器
│   └── mul_trunc_var_array.v   # 變數校正陣列
├── rtl-sim/
│   ├── TB.v                    # Testbench
│   ├── gen_test_data.py        # 測試資料產生器
│   ├── 8x8_a.txt               # 8x8測試資料
│   ├── 8x8_b.txt
│   ├── 8x8_ans.txt
│   ├── 16x16_a.txt             # 16x16測試資料
│   ├── 16x16_b.txt
│   └── 16x16_ans.txt
└── syn/
    ├── dc.tcl                  # Design Compiler腳本
    └── .synopsys_dc.setup      # DC設定檔
```

## 模組介面

所有模組統一介面：
```verilog
module mul_xxx #(parameter N = 8) (
    input  wire [N-1:0] a,      // 被乘數 (unsigned)
    input  wire [N-1:0] b,      // 乘數 (unsigned)
    output wire [N-1:0] p_msb   // 乘積MSB半部 [2N-1:N]
);
```

## 執行測試

### 8x8測試
```bash
cd hw5/rtl-sim
iverilog -o tb_8x8 -DN=8 ../rtl/*.v TB.v
vvp tb_8x8
```

### 16x16測試
修改TB.v中的參數：
```verilog
parameter N = 16;
parameter A_FILE   = "16x16_a.txt";
parameter B_FILE   = "16x16_b.txt";
parameter ANS_FILE = "16x16_ans.txt";
```

然後：
```bash
iverilog -o tb_16x16 ../rtl/*.v TB.v
vvp tb_16x16
```

## 合成

```bash
cd hw5/syn
# 修改dc.tcl中的DESIGN_NAME和OPT_TARGET
dc_shell -f dc.tcl
```

## 實作說明

### 1. mul_operator
直接使用Verilog `*` 運算子，作為golden reference。

### 2. mul_row  
使用for迴圈逐列累加部分積，無截斷。

### 3. mul_trunc_const_row
- 截斷r = n-k個最低位元列
- 加入校正常數 (2^k - 1) << r
- n=8: k=3, r=5
- n=16: k=4, r=12

### 4. mul_array
行為化描述的陣列乘法器結構：
- 使用carry-save加法逐列處理
- 最終轉換為正常二進位

### 5. mul_trunc_var_array
變數校正方法：
- 列(r-1)的PP位元加到列r (變數校正)
- 加入捨入常數 (2^k - 1) << r
- n=8: k=2, r=6
- n=16: k=3, r=13

## 測試資料產生

```bash
cd rtl-sim
python3 gen_test_data.py
```

產生100組測試向量，包含邊界情況：
- 0x00 * 0x00
- 0xFF * 0xFF (8-bit) / 0xFFFF * 0xFFFF (16-bit)
- 其他邊界和隨機值

## 預期結果

- operator, row, array: 精確匹配 (誤差 = 0)
- trunc_const_row: 最大誤差 < 1 ULP
- trunc_var_array: 最大誤差 < 1 ULP

## 注意事項

1. 所有程式碼使用純Verilog-2001語法
2. 無符號運算
3. 輸出為n位元MSB部分
4. 需完成delay、area、mid三種優化目標的合成
