# Digital Hardware Design Projects

This repository contains a collection of digital hardware design projects implemented in Verilog RTL, with a focus on arithmetic units, floating-point datapaths, multiplier architectures, pipelined design, and digital VLSI-oriented optimization.

The projects cover fixed-point and IEEE 754 floating-point arithmetic, fused multiply-add (FMA), reconfigurable multi-precision computation, and truncated multiplier design. In addition to RTL implementation, the workflow also involves simulation, synthesis, timing-oriented design considerations, and architecture-level trade-off analysis.

## Project Overview

### 1. Fixed-Point and Floating-Point Adder / Multiplier
This project includes:
- 32-bit signed fixed-point adder
- 32-bit floating-point adder
- 32x32 fixed-point multiplier
- 32-bit floating-point multiplier
- Pipelined floating-point adder and multiplier variants

Key design topics:
- IEEE 754 single-precision datapath
- unpack / align / add-sub / normalize / round / pack flow
- non-pipelined and pipelined implementations
- synthesis under area-, delay-, and balanced-optimization constraints

### 2. Floating-Point Fused Multiply-Add (FMA)
This project implements:
- fixed-point fused multiply-add (FXP_FMA)
- floating-point fused multiply-add (FLP_FMA)
- 4-stage pipelined floating-point FMA (FLP_FMA_4)

Key design topics:
- fused datapath for `D = A * B + C`
- simultaneous alignment of the addend during product generation
- signed / magnitude conversion
- normalization and rounding
- pipelined stage partitioning
- special-case handling for zero, NaN, overflow, and underflow

### 3. Reconfigurable Multi-Precision Floating-Point Dot Product Unit
This project focuses on a reconfigurable computation unit for the dot product of 4D vectors.

Key design topics:
- support for both single-precision and half-precision floating-point modes
- multi-precision datapath reuse
- sub-word multiplier construction
- clock-gating for low-power half-precision mode
- non-pipelined and pipelined implementations
- design-space trade-offs in area, delay, and power

### 4. Multiplier Architecture Exploration
This part studies multiple multiplication architectures and optimization methods.

Topics include:
- hierarchical multipliers
- partial product generation
- Radix-4 Booth recoding
- canonical recoding
- sign-extension reduction
- array multipliers
- Wallace, Dadda, and reduced-area reduction trees
- final adder design

### 5. Truncated Multiplier Designs
This project compares several truncated multiplier implementations for fixed-width multiplication.

Compared architectures include:
- direct Verilog `*` operator
- row-based partial product accumulation
- constant-correction truncated multiplier
- array multiplier
- variable-correction truncated array multiplier

Key design topics:
- approximation-aware arithmetic
- constant vs. variable correction
- error, area, delay, and power trade-offs
- fixed-width multiplier design

## Repository Structure

Each subdirectory corresponds to one project or design topic. Typical contents include:
- RTL source code
- testbenches
- simulation scripts
- reports
- supporting documents

## Technical Skills Demonstrated

- Verilog RTL design
- floating-point datapath design
- pipelined architecture design
- arithmetic unit implementation
- multiplier architecture optimization
- synthesis-oriented design
- timing / area / power trade-off analysis
- digital hardware verification

## Tools and Workflow

The projects are developed with a standard digital design workflow that may include:
- Verilog HDL
- simulation and waveform debugging
- synthesis and report analysis
- timing-aware architectural refinement
- power-oriented techniques such as clock gating

## Notes

This repository is intended to serve as an engineering portfolio of digital hardware design work completed through advanced coursework and project-based implementation. The focus is on architecture understanding, RTL realization, and design trade-off analysis rather than only final code delivery.

## Author

**Fan-Sheng Wei**  
M.S. Student, Department of Computer Science and Engineering  
National Sun Yat-sen University
