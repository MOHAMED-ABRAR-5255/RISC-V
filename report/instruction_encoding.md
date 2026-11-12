# RV32I Instruction Encoding and Control Signal Specification

**Activity Reference:** Day 3 — Activity 3.1  
**Target Architecture:** RISC-V RV32I Base Integer Instruction Set (Single-Cycle CPU)  
**Implementation Files:** `day3/src/single_cycle_cpu/control_unit.v`, `immediate_generator.v`, `alu.v`, `cpu.v`

---

## 1. Overview

The implemented single-cycle RISC-V CPU supports standard RV32I base instructions spanning R-type, I-type, S-type, B-type, U-type, and J-type instruction formats.

Instruction decoding and datapath steering are managed by:
- **`control_unit.v`**: Generates multiplexer select lines, memory read/write enables, register file write enables, and ALU operation codes based on `opcode` (`instr[6:0]`), `funct3` (`instr[14:12]`), and `funct7` (`instr[31:25]`).
- **`immediate_generator.v`**: Extracts and sign-extends 32-bit immediate constants from various instruction formats.
- **`alu.v`**: Executes arithmetic and logical operations according to a 4-bit ALU control code.

---

## 2. RV32I Instruction Formats

| Format | 31:25 | 24:20 | 19:15 | 14:12 | 11:7 | 6:0 | Description |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---|
| **R-type** | funct7 | rs2 | rs1 | funct3 | rd | opcode | Register-to-register arithmetic/logic |
| **I-type** | imm[11:0] | rs1 | funct3 | rd | opcode | Immediate arithmetic, loads |
| **S-type** | imm[11:5] | rs2 | rs1 | funct3 | imm[4:0] | opcode | Stores to data memory |
| **B-type** | imm[12\|10:5] | rs2 | rs1 | funct3 | imm[4:1\|11] | opcode | Conditional branches |
| **U-type** | imm[31:12] | rd | opcode | Upper immediate (LUI) |
| **J-type** | imm[20\|10:1\|11\|19:12] | rd | opcode | Unconditional jump (JAL) |

---

## 3. Instruction Encoding & Control Signals Table

The table below details all supported instructions, their bit-level fields, and corresponding control signals produced by `control_unit.v`.

| Instruction | Type | Opcode `[6:0]` | `funct3` `[14:12]` | `funct7` `[31:25]` / bit30 | RegWrite | MemRead | MemWrite | MemToReg | ALUSrc | Branch | JAL | LUI | Branch Type | ALUOp `[3:0]` | Operation Performed |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---|
| **ADD** | R | `0110011` | `000` | `0000000` (0) | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | - | `4'b0000` | `R[rd] = R[rs1] + R[rs2]` |
| **SUB** | R | `0110011` | `000` | `0100000` (1) | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | - | `4'b0001` | `R[rd] = R[rs1] - R[rs2]` |
| **SLL** | R | `0110011` | `001` | `0000000` (0) | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | - | `4'b0110` | `R[rd] = R[rs1] << R[rs2][4:0]` |
| **SLT** | R | `0110011` | `010` | `0000000` (0) | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | - | `4'b0101` | `R[rd] = ($signed(R[rs1]) < $signed(R[rs2])) ? 1 : 0` |
| **XOR** | R | `0110011` | `100` | `0000000` (0) | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | - | `4'b0100` | `R[rd] = R[rs1] ^ R[rs2]` |
| **SRL** | R | `0110011` | `101` | `0000000` (0) | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | - | `4'b0111` | `R[rd] = R[rs1] >> R[rs2][4:0]` |
| **SRA** | R | `0110011` | `101` | `0100000` (1) | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | - | `4'b1000` | `R[rd] = $signed(R[rs1]) >>> R[rs2][4:0]` |
| **OR** | R | `0110011` | `110` | `0000000` (0) | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | - | `4'b0011` | `R[rd] = R[rs1] \| R[rs2]` |
| **AND** | R | `0110011` | `111` | `0000000` (0) | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | - | `4'b0010` | `R[rd] = R[rs1] & R[rs2]` |
| **ADDI** | I | `0010011` | `000` | imm | 1 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | - | `4'b0000` | `R[rd] = R[rs1] + imm` |
| **SLTI** | I | `0010011` | `010` | imm | 1 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | - | `4'b0101` | `R[rd] = ($signed(R[rs1]) < $signed(imm)) ? 1 : 0` |
| **XORI** | I | `0010011` | `100` | imm | 1 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | - | `4'b0100` | `R[rd] = R[rs1] ^ imm` |
| **ORI** | I | `0010011` | `110` | imm | 1 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | - | `4'b0011` | `R[rd] = R[rs1] \| imm` |
| **ANDI** | I | `0010011` | `111` | imm | 1 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | - | `4'b0010` | `R[rd] = R[rs1] & imm` |
| **SLLI** | I | `0010011` | `001` | `0000000` | 1 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | - | `4'b0110` | `R[rd] = R[rs1] << shamt` |
| **SRLI** | I | `0010011` | `101` | `0000000` (bit30=0) | 1 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | - | `4'b0111` | `R[rd] = R[rs1] >> shamt` |
| **SRAI** | I | `0010011` | `101` | `0100000` (bit30=1) | 1 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | - | `4'b1000` | `R[rd] = $signed(R[rs1]) >>> shamt` |
| **LW** | I | `0000011` | `010` | imm | 1 | 1 | 0 | 1 | 1 | 0 | 0 | 0 | - | `4'b0000` | `R[rd] = Mem[R[rs1] + imm]` |
| **SW** | S | `0100011` | `010` | imm | 0 | 0 | 1 | 0 | 1 | 0 | 0 | 0 | - | `4'b0000` | `Mem[R[rs1] + imm] = R[rs2]` |
| **BEQ** | B | `1100011` | `000` | imm | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | `0` | `4'b0001` | `if (R[rs1] == R[rs2]) PC += imm` |
| **BNE** | B | `1100011` | `001` | imm | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | `1` | `4'b0001` | `if (R[rs1] != R[rs2]) PC += imm` |
| **BLT** | B | `1100011` | `100` | imm | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | `2` | `4'b0001` | `if ($signed(R[rs1]) < $signed(R[rs2])) PC += imm` |
| **BGE** | B | `1100011` | `101` | imm | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | `3` | `4'b0001` | `if ($signed(R[rs1]) >= $signed(R[rs2])) PC += imm` |
| **BLTU** | B | `1100011` | `110` | imm | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | `4`* | `4'b0001` | `if (R[rs1] < R[rs2]) PC += imm` |
| **BGEU** | B | `1100011` | `111` | imm | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | `5`* | `4'b0001` | `if (R[rs1] >= R[rs2]) PC += imm` |
| **LUI** | U | `0110111` | - | imm | 1 | 0 | 0 | 0 | - | 0 | 0 | 1 | - | - | `R[rd] = {imm[31:12], 12'b0}` |
| **JAL** | J | `1101111` | - | imm | 1 | 0 | 0 | 0 | - | 0 | 1 | 0 | - | - | `R[rd] = PC + 4; PC += imm` |

*\* Note: In the existing `control_unit.v`, `branch_type` is declared as `reg [1:0]`. Values 4 (`3'b100`) and 5 (`3'b101`) require 3 bits (`[2:0]`), causing truncation to `0` and `1` respectively. Refer to Section 5 of this document.*

---

## 4. Immediate Generator Mapping

The module `immediate_generator.v` unpacks immediate values according to the instruction opcode:

```verilog
case (instr[6:0])
    7'b0010011, // I-type arithmetic
    7'b0000011: // I-type load
        imm = {{20{instr[31]}}, instr[31:20]};

    7'b0100011: // S-type store
        imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};

    7'b1100011: // B-type conditional branch
        imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};

    7'b0110111: // U-type LUI
        imm = {instr[31:12], 12'b0};

    7'b1101111: // J-type JAL
        imm = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};

    default: imm = 32'b0;
endcase
```

---

## 5. Architectural Static Analysis Notes

1. **Branch Comparison Handling:**
   - In `cpu.v`, branch condition evaluation is calculated via:
     ```verilog
     assign takebranch = branch && (
         (branch_type == 0 && rd1 == rd2) ||
         (branch_type == 1 && rd1 != rd2) ||
         (branch_type == 2 && $signed(rd1) < $signed(rd2)) ||
         (branch_type == 3 && $signed(rd1) >= $signed(rd2)) ||
         (branch_type == 4 && rd1 < rd2) ||
         (branch_type == 5 && rd1 >= rd2)
     );
     ```
   - **Static Inspection Finding:** In `control_unit.v`, `output reg [1:0] branch_type;` is 2 bits wide, while in `cpu.v`, `wire [1:0] branch_type;` is also 2 bits wide. For BLTU (`branch_type=4`) and BGEU (`branch_type=5`), the values truncate into 0 and 1. To fully support unsigned comparisons without truncation, widen `branch_type` to `[2:0]` across both files.
2. **Write-Back Multiplexing:**
   - In `cpu.v`:
     ```verilog
     assign wb = lui ? imm : jal ? pc + 4 : memtoreg ? memdata : alu_y;
     ```
   - Prioritizes `lui`, then `jal` link return address `pc+4`, then data memory output `memdata`, and finally ALU computation result `alu_y`.

