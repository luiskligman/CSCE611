# CSCE 611: Advanced Digital Design

Lab work for **CSCE 611 (Advanced Digital Design)** at the University of South Carolina. The labs start with RISC-V assembly and build toward a **pipelined RV32I processor** written in SystemVerilog and run on an Intel/Altera **DE2-115 FPGA** board.

## Repository Layout

| Directory | Lab | Language | Summary |
|---|---|---|---|
| [`sqrt_lab/`](sqrt_lab) | Fixed-Point Square Root | RISC-V assembly | Computes a square root with binary search in fixed-point arithmetic |
| [`lab2/lab_hex/`](lab2/lab_hex) | Seven-Segment Decoder | SystemVerilog | Shows the board's switch values as hex digits on the 7-segment displays |
| [`lab3/lab_riu/`](lab3/lab_riu) | RISC-V R/I/U-Type CPU | SystemVerilog | 3-stage pipelined CPU for a subset of RV32I *(in progress)* |
| `rars.jar` | — | — | [RARS](https://github.com/TheThirdOne/rars) RISC-V assembler and simulator |

Each lab folder includes the original assignment handout as a PDF.

---

## Lab 1: Fixed-Point Square Root (`sqrt_lab/sqrt.asm`)

Finds the square root of a number using only integer instructions.

- **Format:** the input and output are fixed-point numbers with **14 fractional bits** (value × 2¹⁴).
- **Algorithm:** binary search. The guess starts at 0 and the step starts at 256.0 (`2^22` in raw form). On each pass the program squares the guess, adds the step if the square is too small or subtracts it if it is too large, then halves the step. It stops when the square matches the input exactly or the step reaches 0.
- **Squaring the guess:** `mul` and `mulhu` give the full 64-bit product. The program then shifts and ORs the two halves to rescale the result back to the 14-fractional-bit format.
- **I/O:** reads an integer with RARS syscall `5` and prints the result with syscall `1`.

**To run it:**
```bash
java -jar rars.jar sqrt_lab/sqrt.asm
```
Type the input as a raw fixed-point value. For example, `65536` is 4.0, and the program prints `32768`, which is 2.0.

---

## Lab 2: Seven-Segment Decoder (`lab2/lab_hex/`)

A first design on the DE2-115 board.

- **`hexdriver.sv`**: combinational module that turns a 4-bit value (`0`–`F`) into the pattern for one active-low 7-segment digit.
- **`top.sv`**: creates five `hexdriver`s that show switches `SW[17:0]` in hex on `HEX0`–`HEX4`. `HEX5`–`HEX7` are held at `0`. It also keeps the "bouncing comet" LED demo, which is driven by a clock divider on the 50 MHz clock.

---

## Lab 3: RISC-V R/I/U-Type Processor (`lab3/lab_riu/`) — *in progress*

A **3-stage pipelined RISC-V CPU** that runs a subset of RV32I, plus a self-checking testbench.

- **Instructions to support:**
  - R-type: `add`, `sub`, `and`, `or`, `xor`, `sll`, `sra`, `srl`, `slt`, `sltu`, `mul`, `mulh`, `mulhu`, `csrrw`
  - I-type: `addi`, `andi`, `ori`, and others
  - U-type: `lui`
- **`regfile.sv`**: 32 × 32-bit register file with two read ports and one write port. `x0` always reads as zero, and a read of a register that is being written in the same cycle returns the new value (write-first bypass).
- **`alu.sv`**: 32-bit ALU for logic, add/subtract, signed and unsigned multiply (low and high halves), shifts, and set-less-than comparisons. It was supplied with the course.
- **`simtop.sv`**: simulation top level that drives the clock, reset, and switch inputs for testing.

---

## Toolchain & Build

- **Hardware:** Terasic DE2-115 (Intel Cyclone IV E)
- **Synthesis:** Intel Quartus
- **Simulation:** ModelSim / Questa
- **Assembly:** RARS

Each hardware lab ships with the course's `csce611.sh` helper script:

```bash
cd lab2/lab_hex            # or lab3/lab_riu
./csce611.sh compile       # synthesize with Quartus
./csce611.sh program       # program the DE2-115 over JTAG
./csce611.sh testbench     # run the simulation testbench
./csce611.sh help          # list all commands
```

> If you see `QUARTUS_ROOTDIR: unbound variable`, source the Quartus environment first. On the course machines that is `source /usr/local/3rdparty/cad_setup_files/altera.bash`.
