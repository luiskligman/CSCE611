# CSCE 611: Advanced Digital Design

Coursework for **CSCE 611** at the University of South Carolina (Fall 2025). The labs start with RISC-V assembly and build up to a **3-stage pipelined RV32I processor** in SystemVerilog that runs on a Terasic **DE2-115** FPGA board.

## Labs

| Lab | Folder | What it is | Status |
|---|---|---|---|
| 1. Fixed-Point Square Root | [`sqrt_lab/`](sqrt_lab) | Square root in RISC-V assembly, using only integer instructions | Done |
| 2. Seven-Segment Decoder | [`lab2/lab_hex/`](lab2/lab_hex) | Shows the switch values as hex digits on the 7-segment displays | Done |
| 3. R/I/U-Type CPU | [`lab3/lab_riu/`](lab3/lab_riu) | 3-stage pipelined CPU, self-checking testbench, `bin2dec` program | Done |
| 4. Jumps & Branches | [`lab4/lab_jb/`](lab4/lab_jb) | Adds `jal`, `jalr`, and B-type branches to the lab 3 CPU | In progress |

Each lab folder has the assignment handout as a PDF. The hardware labs also have it as `README.md` inside the project folder.

Other files:

- `rars.jar`: the course's copy of the [RARS](https://github.com/TheThirdOne/rars) RISC-V assembler and simulator
- `lecture_slides/`, `midterm_review/`, `syllabus.pdf`: course materials

---

## Lab 1: Fixed-Point Square Root

[`sqrt_lab/sqrt.asm`](sqrt_lab/sqrt.asm) finds a square root using binary search.

- Input and output are fixed-point numbers with **14 fractional bits** (the value × 2¹⁴).
- The guess starts at 0 and the step at 256.0. Each pass squares the guess, adds the step if the square is too small or subtracts it if too large, then halves the step. The loop stops when the square matches exactly or the step reaches 0.
- To square the guess, `mul` and `mulhu` produce the full 64-bit product, and shifts rescale it back to 14 fractional bits.

```bash
java -jar rars.jar sqrt_lab/sqrt.asm
```

Enter the input as a raw fixed-point value. For example, `65536` (4.0) prints `32768` (2.0).

## Lab 2: Seven-Segment Decoder

- [`hexdriver.sv`](lab2/lab_hex/hexdriver.sv): turns a 4-bit value (`0`–`F`) into the pattern for one active-low 7-segment digit.
- [`top.sv`](lab2/lab_hex/top.sv): shows `SW[17:0]` in hex on `HEX0`–`HEX4`. It keeps the course's "bouncing comet" LED demo.

## Lab 3: R/I/U-Type CPU

A 3-stage pipeline: **Fetch → Execute → Writeback**. Decoding, register reads, and the ALU all happen in Execute.

| File | Role |
|---|---|
| `cpu.sv` | Pipeline registers, PC, instruction memory, writeback mux |
| `instruction_decoder.sv` | Splits an instruction into opcode, registers, funct fields, and immediates |
| `controlunit.sv` | Sets the ALU op and the mux and write-enable signals for each instruction |
| `regfile.sv` | 32 × 32-bit registers. `x0` is always 0, and a register written in the same cycle is read with its new value (write-first bypass) |
| `alu.sv` | 32-bit ALU (supplied with the course) |
| `top.sv` | Connects the CPU to the switches and 8 hex displays |
| `simtop.sv` | Self-checking testbench |

**Instructions:**

- R-type: `add` `sub` `and` `or` `xor` `sll` `srl` `sra` `slt` `sltu` `mul` `mulh` `mulhu` `csrrw`
- I-type: `addi` `andi` `ori` `xori` `slli` `srli` `srai`
- U-type: `lui`

**I/O through CSRs:** `csrrw rd, io0, x0` reads the switches, and `csrrw x0, io2, rs1` writes a value to the hex displays.

**Program:** [`bin2dec.asm`](<lab3/lab_riu/asm programs/bin2dec.asm>) reads the switches and shows the value in decimal on the hex displays. It divides by 10 by multiplying with `0x1999999a` (about 2³²/10), because the CPU has no divide instruction. Its machine code is in `instmem.dat`, which the CPU loads at startup.

**Testing:** see [`lab3/lab_riu/TESTING.md`](lab3/lab_riu/TESTING.md) for what the test program covers and how the expected values were found.

## Lab 4: Jumps & Branches (in progress)

Extends the lab 3 CPU with:

- J-type: `jal`
- I-type: `jalr`
- B-type: `beq` `bne` `blt` `bge` `bltu` `bgeu`

**How it works** (in [`lab4/lab_jb/`](lab4/lab_jb)):

- The PC is a 12-bit **word** address into a 4096-word instruction memory. Branch and jump offsets are byte offsets, so the CPU drops their low 2 bits. Return addresses written to `rd` are byte addresses.
- `pcsrc_EX` chooses the next PC: `00` = PC + 1, `01` = branch target, `10` = `jal` target, `11` = `jalr` target (`rs1` + offset).
- Branch comparisons use the ALU: subtract for `beq`/`bne`, `slt` for `blt`/`bge`, and `sltu` for `bltu`/`bgeu`.
- Branches and jumps are resolved in Execute. When one is taken, `stall_FETCH` replaces the instruction fetched after it with a no-op, and `stall_EX` makes sure that no-op cannot write a register or redirect the PC.

**Testing:** `simtop.sv` runs two programs in a row and checks the registers after each:

1. `cpu_test.dat` ([`test1.asm`](lab4/lab_jb/asm_programs/test1.asm)): the lab 3 R/I/U tests, run for 45 cycles.
2. `cpu_test2.dat` ([`test2.asm`](lab4/lab_jb/asm_programs/test2.asm)): branch and jump tests, run for 300 cycles. Every branch is tested both taken and not taken. A taken branch leaves 11 in its result register and a not-taken branch leaves 21, so any other value shows which path ran. The program also tests a backward-branch loop, forward and backward `jal`, a call and return with `jal` + `jalr`, a `jalr` whose address register was written by the previous instruction, and a branch in the cancelled slot after a jump.

**Still to do:**

- [ ] Run the full testbench
- [ ] Write `sqrt.asm`: read the switches and show the square root in (8,5) decimal fixed point (for example, 3.75 shows as `00375000`)
- [ ] Assemble `sqrt.asm` into `instmem.dat` (it currently holds `bin2dec`) and test it on the board

---

## Tools

| | |
|---|---|
| Board | Terasic DE2-115 (Intel Cyclone IV E) |
| Synthesis | Intel Quartus |
| Simulation | ModelSim / Questa |
| Assembler | RARS (`rars.jar`) |

Each hardware lab includes the course's `csce611.sh` script. Run it from the project folder:

```bash
cd lab4/lab_jb
./csce611.sh compile     # synthesize with Quartus
./csce611.sh program     # program the DE2-115 over JTAG
./csce611.sh testbench   # run simtop.sv in ModelSim
./csce611.sh pack        # build the .7z to submit
./csce611.sh help        # list every command
```

If you see `QUARTUS_ROOTDIR: unbound variable`, load the Quartus environment first. On the lab machines:

```bash
source /usr/local/3rdparty/cad_setup_files/altera.bash
```

To assemble a test program into the hex file the testbench loads (from `lab4/lab_jb`):

```bash
java -jar ../../rars.jar nc a dump .text HexText cpu_test2.dat asm_programs/test2.asm
```
