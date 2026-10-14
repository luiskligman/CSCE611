# Lab 3 Test Suite: How to Run and What It Covers

## Running the tests

On a Swearingen Linux lab machine, from the `lab_riu` directory:

```sh
./csce611.sh testbench
```

A passing run ends with:

```
# PASS: CPU test completed with 0 errors.
```

If a check fails, the testbench prints one line per failing register,
followed by a fatal error, for example:

```
# FAIL x7 got = 00000000, expected = 00000001
# ** Fatal: FAIL: CPU test completed with 1 errors.
```

`testbench_output.txt` contains the output of a full passing run.

## Files

| File | Purpose |
|---|---|
| `simtop.sv` | Self-checking testbench |
| `asm programs/test1.asm` | Test program source |
| `cpu_test.dat` | `test1.asm` assembled to hex, loaded by the testbench |
| `instmem.dat` | bin2dec program, used on the board (not changed by the testbench) |
| `testbench_output.txt` | Sample passing run |

## How the testbench works

1. `cpu.sv` loads `instmem.dat` (bin2dec) as usual.
2. At 1 ns, while the CPU is still held in reset, `simtop.sv` clears the CPU's
   instruction memory and loads `cpu_test.dat` in its place.
3. Reset is released at 10 ns, and the CPU runs the test program for 45 clock
   cycles.
4. The testbench reads every result register directly from the register file
   (`dut.cpu.registers.mem[i]`) and the GPIO output (`dut.io2_out`), and
   compares each one with its expected value.
5. The switches are fixed at `SW = 12345` during simulation.

## What the tests cover

### Professor-provided instruction tests (registers x1–x23, plus `io2_out`)

- **Every required instruction:**
  - R-type: `add`, `sub`, `and`, `or`, `xor`, `sll`, `srl`, `sra`, `slt`, `sltu`,
    `mul`, `mulh`, `mulhu`, `csrrw`
  - I-type: `addi`, `andi`, `ori`, `xori`, `slli`, `srli`, `srai`
  - U-type: `lui`

  Almost every instruction writes its own register, so its result is checked
  directly. `add`, `sub` and `slli` build `x3` in sequence, so their combined
  result is checked.
- **Register bypass:** many instructions use the result of the instruction
  directly before them, which only works if the register file forwards the
  value being written back.
- **Sign extension:** `andi` and `ori` use the immediate -2048.
- **Signed vs. unsigned:** inputs are chosen so each pair gives different
  answers: `slt`/`sltu`, `mulh`/`mulhu` and `sra`/`srl` 
- **CSR I/O:**
  - `csrrw` from `io0` reads the switches (12345).
  - `csrrw` to `io2` writes to `io2_out`, and reading the write-only `io2`
    returns 0.

### Extra edge-case tests (registers x24–x31)

Added beyond the professor-provided tests:

| Register | Test |
|---|---|
| x24 | Writing `x0` is ignored, even when the next instruction reads it |
| x25 | `lui` + `addi` builds `0x7fffffff`, the largest positive value |
| x26 | Adding 1 to it overflows and wraps to `0x80000000` |
| x27, x28 | A shift amount of 33 uses only the low 5 bits (a shift of 1) |
| x29 | `mulh` with both operands negative |
| x30, x31 | The 12-bit immediate limits, 2047 and -2048 |

## Where the expected values come from

The expected values come from running `test1.asm` in RARS (the modified
version provided with the course), except for the `csrrw` results. RARS has no switches, so those come from the lab spec:

  - `x22` = 0 (reading `io2` returns 0)
  - `x23` = 12345 (the simulated switch value)
  - `io2_out` = the value of `x3`

## Changing the test program

1. Edit `asm programs/test1.asm`.
2. Regenerate the hex from `lab_riu`:

   ```sh
   java -jar ../../rars.jar nc a dump .text HexText cpu_test.dat "asm programs/test1.asm"
   ```

   Adjust the path to `rars.jar` for your setup.
3. Get the new expected values by running the program in RARS, for example:

   ```sh
   java -jar ../../rars.jar nc b x1 x2 x3 "asm programs/test1.asm"
   ```

4. Update the `check32(...)` lines in `simtop.sv`.
   - If the program grows, raise `repeat (45)` so every instruction finishes
     before the checks run.

## bin2dec

`bin2dec.asm` was checked two ways:

- in RARS, with inputs 0, 9, 10, 12345, 99999 and 262143 (all produced the
  correct decimal output);
- on the DE2-115 board, where it was demonstrated to the TA.
