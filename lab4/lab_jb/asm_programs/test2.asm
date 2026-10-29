.text
# ===== Branch and jump tests =====
# Every test sets its result register first, because the registers still hold
# test1's values when this program starts.
#   taken branch:     result = 11 (0x0b)  (1, skip the wrong path, +10)
#   not-taken branch: result = 21 (0x15)  (1, +20 runs)
# A wrong answer gives 1, 2, 12 or 22 instead.

# ----- operands -----
addi x1, x0, -1        # x1 = 0xffffffff (-1 signed, the largest number unsigned)
addi x2, x0, 1         # x2 = 1
addi x3, x0, 5         # x3 = 5

# ----- beq -----
addi x4, x0, 1
beq  x3, x3, beq_t     # 5 == 5: taken
addi x4, x0, 2         # wrong path: must NOT execute
beq_t:
addi x4, x4, 10        # x4 = 11

addi x5, x0, 1
beq  x1, x2, beq_nt    # -1 == 1: not taken
addi x5, x5, 20        # must execute: x5 = 21
beq_nt:

# ----- bne -----
addi x6, x0, 1
bne  x1, x2, bne_t     # -1 != 1: taken
addi x6, x0, 2
bne_t:
addi x6, x6, 10        # x6 = 11

addi x7, x0, 1
bne  x3, x3, bne_nt    # 5 != 5: not taken
addi x7, x7, 20        # x7 = 21
bne_nt:

# ----- blt (signed) -----
addi x8, x0, 1
blt  x1, x2, blt_t     # -1 < 1 signed: taken
addi x8, x0, 2
blt_t:
addi x8, x8, 10        # x8 = 11

addi x9, x0, 1
blt  x3, x3, blt_nt    # 5 < 5: not taken (equal operands)
addi x9, x9, 20        # x9 = 21
blt_nt:

# ----- bltu (unsigned) -----
addi x10, x0, 1
bltu x1, x2, bltu_nt   # 0xffffffff < 1 unsigned: not taken (blt was taken on the same operands)
addi x10, x10, 20      # x10 = 21
bltu_nt:

addi x11, x0, 1
bltu x2, x1, bltu_t    # 1 < 0xffffffff unsigned: taken
addi x11, x0, 2
bltu_t:
addi x11, x11, 10      # x11 = 11

# ----- bge (signed) -----
addi x12, x0, 1
bge  x3, x3, bge_t     # 5 >= 5: taken (equal operands)
addi x12, x0, 2
bge_t:
addi x12, x12, 10      # x12 = 11

addi x13, x0, 1
bge  x1, x2, bge_nt    # -1 >= 1 signed: not taken
addi x13, x13, 20      # x13 = 21
bge_nt:

# ----- bgeu (unsigned) -----
addi x14, x0, 1
bgeu x1, x2, bgeu_t    # 0xffffffff >= 1 unsigned: taken (bge was not taken on the same operands)
addi x14, x0, 2
bgeu_t:
addi x14, x14, 10      # x14 = 11

addi x15, x0, 1
bgeu x2, x1, bgeu_nt   # 1 >= 0xffffffff unsigned: not taken
addi x15, x15, 20      # x15 = 21
bgeu_nt:

# ----- backward branch (loop) -----
# Also checks the register bypass: bne reads x16 right after addi writes it.
addi x16, x0, 0        # loop counter
addi x17, x0, 5        # loop limit
addi x18, x0, 0        # counts how many times the line after the loop runs
loop:
addi x16, x16, 1
bne  x16, x17, loop    # taken 4 times (negative offset), falls through once
addi x18, x18, 1       # runs once; it would run 5 times if the wrong path leaked
                       # x16 = 5, x18 = 1

# ----- jal forward -----
addi x20, x0, 1
jal  x19, jal_f        # x19 = return address (byte address of the next line)
addi x20, x0, 2        # wrong path
jal_f:
addi x20, x20, 10      # x20 = 11

# ----- jal backward -----
jal  x0, jb_start      # skip over the backward target (jal x0 = plain jump)
jb_target:
addi x21, x21, 10      # x21 = 11
jal  x0, jb_done
jb_start:
addi x21, x0, 1
jal  x22, jb_target    # backward jump, x22 = return address
addi x21, x0, 2        # wrong path
jb_done:

# ----- call and return (jal + jalr) -----
addi x24, x0, 1
jal  x25, func         # call: x25 = return address
addi x24, x24, 100     # runs after the return: x24 = 111
jal  x0, func_done     # (if this line also ran as the wrong path after the call, x24 = 211)
func:
addi x24, x24, 10
jalr x0, x25, 0        # return
addi x24, x0, 2        # wrong path
func_done:

# ----- jalr with a nonzero offset -----
addi x26, x0, 1
jal  x27, jro_base     # x27 = byte address of jro_base
jro_base:
jalr x28, x27, 12      # jump to jro_base + 12 (jro_land), x28 = return address
addi x26, x0, 2        # jro_base + 4: wrong path
addi x26, x0, 3        # jro_base + 8: skipped
jro_land:
addi x26, x26, 10      # x26 = 11

# ----- jalr to an address built with addi -----
addi x23, x0, 1
jal  x29, jra_base     # x29 = byte address of jra_base
jra_base:
addi x29, x29, 16      # x29 = jra_base + 16 (jra_land); jalr reads it through the bypass
jalr x0, x29, 0
addi x23, x0, 2        # jra_base + 8: wrong path
addi x23, x0, 3        # jra_base + 12: skipped
jra_land:
addi x23, x23, 10      # x23 = 11

# ----- a branch in the cancelled slot must not run -----
addi x30, x0, 1
beq  x0, x0, bb_t      # taken
beq  x0, x0, bb_bad    # wrong path: this taken branch must be ignored
bb_t:
addi x30, x30, 10      # x30 = 11
jal  x0, bb_done
bb_bad:
addi x30, x0, 2        # only reached if the cancelled branch ran
bb_done:

# ----- reached the end -----
addi x31, x0, 1234     # x31 = 0x4d2
done:
jal  x0, done          # park here
