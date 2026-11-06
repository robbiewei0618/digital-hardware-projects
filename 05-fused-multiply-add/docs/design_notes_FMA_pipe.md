---

# 📊 流水線架構圖
```
         Stage 1              Stage 2              Stage 3              Stage 4
    ┌──────────────┐      ┌──────────────┐      ┌──────────────┐      ┌──────────────┐
    │  Unpack      │      │   Add        │      │ Normalize    │      │  Round       │
A ──┤  Multiply    ├─[R1]─┤   Overflow   ├─[R2]─┤   MSB        ├─[R3]─┤   Pack       ├──→ D
B ──┤  Alignment   │      │   Handle     │      │   Shift      │      │   Special    │
C ──┤              │      │              │      │              │      │              │
    └──────────────┘      └──────────────┘      └──────────────┘      └──────────────┘
         1 cycle              1 cycle              1 cycle              1 cycle

總延遲 (Latency): 4 cycles
吞吐量 (Throughput): 1 result/cycle (pipeline 填滿後)

[R1], [R2], [R3] = Pipeline Registers