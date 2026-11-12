# Architectural Performance & CPI Comparison: Single-Cycle vs. 5-Stage Pipelined RISC-V CPU

**Activity Reference:** Day 4 — Activity 4.3  
**Architectures Evaluated:**
1. Single-Cycle RV32I CPU (`day3/src/single_cycle_cpu/cpu.v`)
2. 5-Stage Pipelined RV32I CPU (`day4/src/pipelined_cpu/pipeline_cpu.v`)

---

## 1. Architectural Overview & Fundamentals

| Metric / Feature | Single-Cycle RISC-V CPU | 5-Stage Pipelined RISC-V CPU |
|:---|:---|:---|
| **Pipeline Stages** | 1 (All operations in 1 clock cycle) | 5 stages: IF (Fetch), ID (Decode), EX (Execute), MEM (Memory), WB (Write-Back) |
| **Pipeline Registers** | None | IF/ID, ID/EX, EX/MEM, MEM/WB |
| **Ideal CPI** | Exactly 1.0 | 1.0 (in steady state with no hazards) |
| **Clock Period ($T_{\text{clk}}$)** | $T_{\text{clk}} \ge T_{\text{IF}} + T_{\text{ID}} + T_{\text{EX}} + T_{\text{MEM}} + T_{\text{WB}}$ (Long clock period, low frequency) | $T_{\text{clk}} \approx \max(T_{\text{IF}}, T_{\text{ID}}, T_{\text{EX}}, T_{\text{MEM}}, T_{\text{WB}}) + T_{\text{reg\_overhead}}$ (Short clock period, high frequency) |
| **Data Hazard Resolution** | Not applicable (all state updates complete by clock edge) | Forwarding paths (EX/MEM -> EX, MEM/WB -> EX) + Hardware Load-Use Stall Interlock (1-cycle bubble) |
| **Control Hazard Resolution** | Not applicable (PC updated directly each cycle) | Branch/Jump resolution in EX stage with 2-cycle pipeline flush |
| **Throughput** | 1 instruction per long cycle | Up to 1 instruction per short cycle |

---

## 2. Theoretical Performance Model

The total execution time for a program is governed by the Iron Law of Processor Performance:

$$\text{Execution Time} = I \times \text{CPI} \times T_{\text{clk}}$$

Where:
- $I$ = Dynamic Instruction Count
- $\text{CPI}$ = Cycles Per Instruction = $\frac{\text{Total Clock Cycles}}{I}$
- $T_{\text{clk}} = \frac{1}{f_{\text{clk}}}$ = Clock Period

### Single-Cycle CPU
$$\text{CPI}_{\text{single}} = 1.0$$
$$\text{Total Cycles}_{\text{single}} = I$$

### Pipelined CPU
In an ideal pipeline of depth $k = 5$ with no hazard stalls:
$$\text{Total Cycles}_{\text{ideal}} = I + (k - 1) = I + 4$$

In the presence of hazards:
$$\text{Total Cycles}_{\text{pipe}} = I + (k - 1) + N_{\text{load\_stalls}} + N_{\text{branch\_flushes}}$$
$$\text{CPI}_{\text{pipe}} = \frac{I + 4 + N_{\text{load\_stalls}} + N_{\text{branch\_flushes}}}{I} = 1.0 + \frac{4 + \text{Hazard Penalties}}{I}$$

As $I \to \infty$, $\text{CPI}_{\text{pipe}} \to 1.0 + \text{Hazard Penalty Rate}$. Because $T_{\text{clk, pipelined}} \ll T_{\text{clk, single}}$, the pipelined processor achieves substantially higher throughput and lower execution time despite a slightly higher CPI than 1.0.

---

## 3. Benchmark Program Analysis

### Benchmark 1: Hazard Demo Program (`day4/tb/pipeline_tb.v`)

Instruction sequence:
1. `addi x1, x0, 5`  (No dependency)
2. `addi x2, x1, 3`  (RAW data hazard on `x1` -> Solved by EX-to-EX forwarding in 0 stall cycles)
3. `sw   x2, 0(x0)`  (RAW data hazard on `x2` -> Solved by EX-to-MEM forwarding in 0 stall cycles)
4. `lw   x3, 0(x0)`  (Memory load)
5. `addi x4, x3, 1`  (Load-use data hazard on `x3` -> Requires 1 stall cycle; forwarded from MEM/WB to EX)

#### Cycle Breakdown:

| Metric | Single-Cycle CPU | 5-Stage Pipelined CPU |
|:---|:---:|:---:|
| **Instruction Count ($I$)** | 5 | 5 |
| **Pipeline Latency (Fill Cycles)** | 0 | 4 |
| **Data Hazard Stalls (Load-Use)** | 0 | 1 |
| **Control Hazard Flushes (Branch/Jump)** | 0 | 0 |
| **Total Clock Cycles** | **5** | **10** |
| **Calculated CPI** | **1.00** | **2.00** |

*Note: For very short sequences ($I=5$), pipeline fill and single-stall overhead dominate CPI. As instruction count scales into thousands, CPI approaches ~1.1 to 1.3.*

---

## 4. Empirical Simulation Comparison (ModelSim Verification)

> [!NOTE]
> **Empirical Simulation Log Status: [PLACEHOLDER FOR MANUAL SIMULATION RUN]**
>
> In accordance with project constraints, simulated run logs are not fabricated. Once you execute the simulation in ModelSim outside Antigravity, record the exact cycle counts below:

| Benchmark Program | Architecture | Measured Clock Cycles | Dynamic Instruction Count ($I$) | Empirical CPI ($\frac{\text{Cycles}}{I}$) | Simulation Status |
|:---|:---|:---:|:---:|:---:|:---:|
| **Program 1 (Sum 1..10)** | Single-Cycle | *[Pending ModelSim run]* | ~43 | 1.00 | Pending verification |
| **Program 1 (Sum 1..10)** | 5-Stage Pipeline | *[Pending ModelSim run]* | ~43 | *[Pending]* | Pending verification |
| **Hazard Demo (`pipeline_tb`)** | Single-Cycle | 5 | 5 | 1.00 | Verified by inspection |
| **Hazard Demo (`pipeline_tb`)** | 5-Stage Pipeline | 10 (theoretical) | 5 | 2.00 (theoretical) | Pending ModelSim waveform capture |

---

## 5. Summary of Key Findings

1. **Forwarding Effectiveness:** The EX-to-EX forwarding unit eliminates stalls for back-to-back ALU operations (`addi x1 -> addi x2`), preventing a 2-cycle penalty.
2. **Load-Use Penalty:** The load instruction `lw x3, 0(x0)` followed immediately by dependent instruction `addi x4, x3, 1` correctly triggers the hardware interlock `load_stall`, inserting exactly 1 bubble cycle.
3. **Cycle Time Trade-Off:** While the single-cycle architecture maintains an ideal CPI of 1.0, its maximum operating frequency is bottlenecked by the combined propagation delay of instruction memory, register file, ALU, data memory, and writeback multiplexers. Pipelining partitions this critical path across 5 balanced stages, enabling significantly higher clock frequencies that yield superior net performance.

