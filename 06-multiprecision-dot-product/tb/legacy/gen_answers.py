# -*- coding: utf-8 -*-
"""
Windows版本 - FLP DP4答案生成器
直接把FP32.txt和FP16.txt放在同一個資料夾就能跑
"""

import struct
import sys
import os

def hex_to_float32(hex_str):
    """Convert 32-bit hex string to float"""
    int_val = int(hex_str, 16)
    bytes_val = struct.pack('>I', int_val)
    return struct.unpack('>f', bytes_val)[0]

def hex_to_float16(hex_str):
    """Convert 16-bit hex string to float"""
    import numpy as np
    int_val = int(hex_str, 16)
    bytes_val = struct.pack('>H', int_val)
    return np.frombuffer(bytes_val, dtype='>f2')[0]

def float32_to_hex(f):
    """Convert float to 32-bit hex string"""
    bytes_val = struct.pack('>f', f)
    int_val = struct.unpack('>I', bytes_val)[0]
    return "{:08x}".format(int_val)

def float16_to_hex(f):
    """Convert float to 16-bit hex string"""
    import numpy as np
    f16 = np.float16(f)
    bytes_val = f16.tobytes()
    int_val = struct.unpack('<H', bytes_val)[0]
    return "{:04x}".format(int_val)

def compute_dp4_fp32(x1, x2, x3, x4, y1, y2, y3, y4):
    """Compute dot product using 32-bit float"""
    result = float(x1) * float(y1) + float(x2) * float(y2) + \
             float(x3) * float(y3) + float(x4) * float(y4)
    return struct.unpack('f', struct.pack('f', result))[0]

def compute_dp4_fp16(x1, x2, x3, x4, y1, y2, y3, y4):
    """Compute dot product using 16-bit float"""
    import numpy as np
    x1, x2, x3, x4 = np.float16(x1), np.float16(x2), np.float16(x3), np.float16(x4)
    y1, y2, y3, y4 = np.float16(y1), np.float16(y2), np.float16(y3), np.float16(y4)
    
    p1 = np.float16(x1 * y1)
    p2 = np.float16(x2 * y2)
    p3 = np.float16(x3 * y3)
    p4 = np.float16(x4 * y4)
    
    s1 = np.float16(p1 + p2)
    s2 = np.float16(p3 + p4)
    result = np.float16(s1 + s2)
    
    return result

def process_file(input_file, output_file, is_fp16=False):
    """處理檔案"""
    print("處理中: {}".format(input_file))
    
    line_count = 0
    with open(input_file, 'r') as fin:
        with open(output_file, 'w') as fout:
            for line in fin:
                line = line.strip()
                if not line:
                    continue
                
                hex_vals = line.split()
                if len(hex_vals) != 8:
                    continue
                
                line_count += 1
                
                if is_fp16:
                    # FP16處理
                    x1 = hex_to_float16(hex_vals[0])
                    x2 = hex_to_float16(hex_vals[1])
                    x3 = hex_to_float16(hex_vals[2])
                    x4 = hex_to_float16(hex_vals[3])
                    y1 = hex_to_float16(hex_vals[4])
                    y2 = hex_to_float16(hex_vals[5])
                    y3 = hex_to_float16(hex_vals[6])
                    y4 = hex_to_float16(hex_vals[7])
                    
                    result = compute_dp4_fp16(x1, x2, x3, x4, y1, y2, y3, y4)
                    result_hex = float16_to_hex(result)
                    fout.write("dec {:15.7e}  float16 {}\n".format(float(result), result_hex))
                else:
                    # FP32處理
                    x1 = hex_to_float32(hex_vals[0])
                    x2 = hex_to_float32(hex_vals[1])
                    x3 = hex_to_float32(hex_vals[2])
                    x4 = hex_to_float32(hex_vals[3])
                    y1 = hex_to_float32(hex_vals[4])
                    y2 = hex_to_float32(hex_vals[5])
                    y3 = hex_to_float32(hex_vals[6])
                    y4 = hex_to_float32(hex_vals[7])
                    
                    result = compute_dp4_fp32(x1, x2, x3, x4, y1, y2, y3, y4)
                    result_hex = float32_to_hex(result)
                    fout.write("dec {:15.7e}  float32 {}\n".format(result, result_hex))
                
                if line_count % 100 == 0:
                    print("  處理了 {} 行...".format(line_count))
    
    print("完成! 共處理 {} 行，輸出到 {}".format(line_count, output_file))

def main():
    # 檢查numpy
    try:
        import numpy as np
    except ImportError:
        print("錯誤: 需要安裝numpy")
        print("請執行: pip install numpy")
        raw_input("按Enter退出...") if sys.version_info[0] < 3 else input("按Enter退出...")
        sys.exit(1)
    
    print("=" * 60)
    print("FP32/FP16 點積運算答案生成器 (Windows版)")
    print("=" * 60)
    print()
    
    # 檢查檔案是否存在
    if not os.path.exists("FP32.txt"):
        print("錯誤: 找不到 FP32.txt")
        print("請把 FP32.txt 和這個程式放在同一個資料夾!")
        print()
        print("當前資料夾: {}".format(os.getcwd()))
        raw_input("按Enter退出...") if sys.version_info[0] < 3 else input("按Enter退出...")
        sys.exit(1)
    
    if not os.path.exists("FP16.txt"):
        print("錯誤: 找不到 FP16.txt")
        print("請把 FP16.txt 和這個程式放在同一個資料夾!")
        print()
        print("當前資料夾: {}".format(os.getcwd()))
        raw_input("按Enter退出...") if sys.version_info[0] < 3 else input("按Enter退出...")
        sys.exit(1)
    
    print("找到輸入檔案:")
    print("  - FP32.txt")
    print("  - FP16.txt")
    print()
    
    # 處理FP32
    try:
        process_file("FP32.txt", "ans32.txt", is_fp16=False)
        print()
    except Exception as e:
        print("錯誤: {}".format(e))
        raw_input("按Enter退出...") if sys.version_info[0] < 3 else input("按Enter退出...")
        sys.exit(1)
    
    # 處理FP16
    try:
        process_file("FP16.txt", "ans16.txt", is_fp16=True)
        print()
    except Exception as e:
        print("錯誤: {}".format(e))
        raw_input("按Enter退出...") if sys.version_info[0] < 3 else input("按Enter退出...")
        sys.exit(1)
    
    print("=" * 60)
    print("全部完成! 生成的檔案:")
    print("  - ans32.txt (FP32答案)")
    print("  - ans16.txt (FP16答案)")
    print("=" * 60)
    print()
    
    # Windows暫停
    raw_input("按Enter退出...") if sys.version_info[0] < 3 else input("按Enter退出...")

if __name__ == "__main__":
    main()