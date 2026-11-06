#!/usr/bin/env python3
"""
測試資料生成腳本
為有號乘法器生成 a.txt, b.txt, ans.txt

生成方法：
1. 使用固定種子的隨機數生成器確保可重現性
2. 對於有號數，使用 Python 的 struct 模組處理 2's complement
3. 包含邊界測試案例（最大正數、最小負數、0、-1 等）
4. 輸出格式為十六進位，每行一筆資料
"""

import random
import struct

def signed_to_hex(value, bits):
    """將有號整數轉換為指定位寬的十六進位字串"""
    # 處理負數：轉換為 2's complement
    if value < 0:
        value = (1 << bits) + value
    # 確保不超過位寬
    value = value & ((1 << bits) - 1)
    # 轉換為十六進位，補零到正確長度
    hex_digits = (bits + 3) // 4
    return format(value, f'0{hex_digits}X')

def hex_to_signed(hex_str, bits):
    """將十六進位字串轉換為有號整數"""
    value = int(hex_str, 16)
    # 檢查是否為負數（MSB = 1）
    if value >= (1 << (bits - 1)):
        value -= (1 << bits)
    return value

def generate_test_data(M, N, num_tests, seed=12345):
    """
    生成測試資料
    
    參數：
    - M: 被乘數位寬
    - N: 乘數位寬
    - num_tests: 測試數量
    - seed: 隨機種子（確保可重現）
    
    返回：
    - a_list: 被乘數列表（十六進位字串）
    - b_list: 乘數列表（十六進位字串）
    - ans_list: 答案列表（十六進位字串）
    """
    random.seed(seed)
    
    a_list = []
    b_list = []
    ans_list = []
    
    # 計算範圍
    a_min = -(1 << (M - 1))      # 最小負數
    a_max = (1 << (M - 1)) - 1   # 最大正數
    b_min = -(1 << (N - 1))
    b_max = (1 << (N - 1)) - 1
    
    # 邊界測試案例
    boundary_cases = [
        (0, 0),                    # 0 * 0
        (1, 1),                    # 1 * 1
        (-1, -1),                  # -1 * -1
        (a_max, b_max),            # 最大正數 * 最大正數
        (a_min, b_min),            # 最小負數 * 最小負數
        (a_max, b_min),            # 最大正數 * 最小負數
        (a_min, b_max),            # 最小負數 * 最大正數
        (a_max, 1),                # 最大正數 * 1
        (a_min, 1),                # 最小負數 * 1
        (1, b_max),                # 1 * 最大正數
        (1, b_min),                # 1 * 最小負數
        (-1, b_max),               # -1 * 最大正數
        (-1, b_min),               # -1 * 最小負數
        (a_max, -1),               # 最大正數 * -1
        (a_min, -1),               # 最小負數 * -1
        (0, b_max),                # 0 * 最大正數
        (a_max, 0),                # 最大正數 * 0
    ]
    
    # 先加入邊界案例
    for a_val, b_val in boundary_cases:
        if len(a_list) >= num_tests:
            break
        ans_val = a_val * b_val
        a_list.append(signed_to_hex(a_val, M))
        b_list.append(signed_to_hex(b_val, N))
        ans_list.append(signed_to_hex(ans_val, M + N))
    
    # 用隨機數填滿剩餘測試
    while len(a_list) < num_tests:
        # 生成隨機有號數
        a_val = random.randint(a_min, a_max)
        b_val = random.randint(b_min, b_max)
        ans_val = a_val * b_val
        
        a_list.append(signed_to_hex(a_val, M))
        b_list.append(signed_to_hex(b_val, N))
        ans_list.append(signed_to_hex(ans_val, M + N))
    
    return a_list, b_list, ans_list

def save_test_files(prefix, M, N, num_tests=100):
    """保存測試檔案"""
    a_list, b_list, ans_list = generate_test_data(M, N, num_tests)
    
    # 保存 a.txt
    with open(f'{prefix}_a.txt', 'w') as f:
        f.write('\n'.join(a_list) + '\n')
    
    # 保存 b.txt
    with open(f'{prefix}_b.txt', 'w') as f:
        f.write('\n'.join(b_list) + '\n')
    
    # 保存 ans.txt
    with open(f'{prefix}_ans.txt', 'w') as f:
        f.write('\n'.join(ans_list) + '\n')
    
    print(f"已生成 {prefix} 測試資料：")
    print(f"  - {prefix}_a.txt   (M={M} bits, {num_tests} 筆)")
    print(f"  - {prefix}_b.txt   (N={N} bits, {num_tests} 筆)")
    print(f"  - {prefix}_ans.txt (M+N={M+N} bits, {num_tests} 筆)")
    print()
    
    # 顯示前幾筆資料作為驗證
    print("前 5 筆測試資料：")
    print(f"{'A (hex)':>10} {'B (hex)':>10} {'ANS (hex)':>12} | {'A (dec)':>10} {'B (dec)':>10} {'ANS (dec)':>12}")
    print("-" * 70)
    for i in range(min(5, num_tests)):
        a_dec = hex_to_signed(a_list[i], M)
        b_dec = hex_to_signed(b_list[i], N)
        ans_dec = hex_to_signed(ans_list[i], M + N)
        print(f"{a_list[i]:>10} {b_list[i]:>10} {ans_list[i]:>12} | {a_dec:>10} {b_dec:>10} {ans_dec:>12}")
    print()

if __name__ == '__main__':
    import os
    os.chdir('/mnt/user-data/outputs/hw4_multipliers')
    
    # 生成三種配置的測試資料
    print("=" * 70)
    print("有號乘法器測試資料生成")
    print("=" * 70)
    print()
    
    save_test_files('8x8', M=8, N=8, num_tests=100)
    save_test_files('16x8', M=16, N=8, num_tests=100)
    save_test_files('16x16', M=16, N=16, num_tests=100)
    
    print("=" * 70)
    print("所有測試資料生成完成！")
    print("=" * 70)
