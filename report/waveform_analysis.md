# Waveform Analysis — Single-Cycle RISC-V CPU

**Activity Reference:** Day 3 — Activity 3.4  
**Target Architecture:** Single-Cycle RV32I CPU (`day3/src/single_cycle_cpu/cpu.v`)  
**Simulation Source:** `day3/tb/cpu_tb.v` executing Program 1 (Sum 1 to 10)

---

## 1. Overview

This document provides architectural cycle-by-cycle waveform analysis for the single-cycle RISC-V CPU. In this microarchitecture, each instruction is fetched, decoded, executed, accesses memory, and writes back within a single clock cycle.

Key observable datapath signals:
- `clk`: System clock
- `reset`: Active-high synchronous reset
- `pc`: Current Program Counter (`[31:0]`)
- `instr_out`: 32-bit machine instruction fetched from instruction memory (`imem[pc[9:2]]`)
- `alu_out`: 32-bit ALU computation result (`alu_y`)
- `wb_out`: 32-bit write-back value destined for register file destination `rd`
- `rf.regs[1..3]`: Loop index and accumulator registers
- `dmem[0]`: Final result memory location

---

## 2. Program 1 Execution Trace Analysis

The testbench in `day3/tb/cpu_tb.v` initializes instruction memory with Program 1 (Sum of integers 1 to 10):

| Cycle / Address | Instruction Hex | Disassembly | Operation & Datapath Trace | ALU Result (`alu_out`) | Write-Back Value (`wb_out`) | Destination |
|:---:|:---:|:---|:---|:---:|:---:|:---|
| **PC = 0x00** | `0x00a00093` | `addi x1, x0, 10` | Load upper loop bound 10 into register `x1` | `0x0000000A` (10) | `0x0000000A` (10) | `x1 = 10` |
| **PC = 0x04** | `0x00000113` | `addi x2, x0, 0` | Initialize sum accumulator `x2` to 0 | `0x00000000` (0) | `0x00000000` (0) | `x2 = 0` |
| **PC = 0x08** | `0x00100193` | `addi x3, x0, 1` | Initialize loop counter `x3` to 1 | `0x00000001` (1) | `0x00000001` (1) | `x3 = 1` |
| **PC = 0x0C** | `0x00310133` | `add x2, x2, x3` | Accumulate: `sum = sum + i` (Iteration 1: 0 + 1) | `0x00000001` (1) | `0x00000001` (1) | `x2 = 1` |
| **PC = 0x10** | `0x00118193` | `addi x3, x3, 1` | Increment loop counter: `i = i + 1` (1 -> 2) | `0x00000002` (2) | `0x00000002` (2) | `x3 = 2` |
| **PC = 0x14** | `0x0030c463` | `blt x1, x3, exit` | Evaluate termination condition: `x1 < x3` (10 < 2 = False) | `0x00000001` | N/A (`RegWrite=0`) | Branch not taken; PC -> PC + 4 |
| **PC = 0x18** | `0xff9ff06f` | `jal x0, loop` | Unconditional jump back to loop head (`PC - 12`) | N/A | `0x0000001C` (`rd=x0`) | PC -> 0x0C |
| ... | ... | *Iterations 2 to 10* | Accumulation loop repeats until `x3 = 11` | ... | ... | `x2` accumulates to 55 |
| **Exit** | `0x00202023` | `sw x2, 0(x0)` | Store final sum (55) into memory word at address 0 | `0x00000000` (Addr 0) | N/A (`MemWrite=1`) | `dmem[0] = 55` |

---

## 3. Waveform Verification & Pending Simulation

> [!NOTE]
> **Waveform Evidence Status: [PENDING MODELSIM CAPTURE]**
>
> In accordance with project constraints, no synthetic waveforms or falsified simulation logs have been generated.
>
> **Steps to capture waveforms in ModelSim outside Antigravity:**
> 1. Launch ModelSim.
> 2. Set current working directory:
>    ```tcl
>    cd {C:/Users/Kaila/OneDrive/Desktop/RISC-V}
>    ```
> 3. Compile all Day 3 single-cycle CPU design files and testbench:
>    ```tcl
>    vlib work
>    vlog day3/src/single_cycle_cpu/*.v
>    vlog day3/tb/cpu_tb.v
>    ```
> 4. Load simulation:
>    ```tcl
>    vsim -voptargs=+acc work.cpu_tb
>    ```
> 5. Add monitored signals to Wave window:
>    ```tcl
>    add wave -divider "Clock & Reset"
>    add wave /cpu_tb/clk /cpu_tb/reset
>    add wave -divider "Datapath Signals"
>    add wave -radix hex /cpu_tb/pc /cpu_tb/instr /cpu_tb/alu /cpu_tb/wb
>    add wave -divider "Internal Registers"
>    add wave -radix decimal /cpu_tb/dut/rf/regs[1] /cpu_tb/dut/rf/regs[2] /cpu_tb/dut/rf/regs[3]
>    add wave -radix decimal /cpu_tb/dut/dmem[0]
>    ```
> 6. Run simulation:
>    ```tcl
>    run 1200ns
>    ```
> 7. Export screenshot and save to `day3/waves/cpu_program1_waveform.png`.

---

## 4. Key Verification Checks

When inspecting the captured ModelSim waveform, confirm the following transitions:
1. **Reset Phase:** While `reset == 1`, `pc` remains `0x00000000` and `regs[0..31]` remain `0`.
2. **Loop Iterations:** `pc` cycles through addresses `0x0C`, `0x10`, `0x14`, `0x18` for 10 iterations.
3. **Branch Decision:** At iteration 10, when `x3` increments to 11, the `blt` condition (`10 < 11`) evaluates to true, redirecting `pc` to `0x1C` (`exit`).
4. **Memory Write:** On execution of `sw x2, 0(x0)`, `dmem[0]` updates to `0x00000037` (`55` decimal).
5. **Self-Checking Result:** Testbench prints:
   ```
   PROGRAM 1 PASS
   ```

