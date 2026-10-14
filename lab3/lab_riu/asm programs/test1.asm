.text
# ===== Professor-provided instruction tests =====
addi x1, x0, 12
addi x2, x0, 17   
add x3, x1, x2   
sub x3, x3, x1   
slli x3, x3, 27   
mul x4, x2, x3   
mulh x5, x2, x3   
mulhu x6, x2, x3   
slt x7, x5, x1   
sltu x8, x5, x1   
and x9, x5, x1   
or x10, x5, x1   
xor x11, x1, x2   
andi x12, x3, -2048   
ori x13, x2, -2048   
xori x14, x2, 14   
sll x15, x2, x1   
srl x16,x3,x2   
sra x17, x3, x2   
slli x18 ,x1, 1   
srli x19, x2, 1   
srai x20, x3, 1   
lui x21, 0xDBEEF   
csrrw x22, 0xf02, x3   
csrrw x23, 0xf00, x3

# ===== Extra edge-case tests (added beyond the professor-provided tests) =====
addi x0, x0, 5        # writing x0 must be ignored
add x24, x0, x0        # x24 = 0 (also checks the bypass doesn't forward a write to x0)
lui x25, 0x80000       # x25 = 0x80000000
addi x25, x25, -1      # x25 = 0x7fffffff, the largest positive number
addi x26, x25, 1       # overflow wraps around: x26 = 0x80000000
addi x27, x0, 33
sll x28, x2, x27       # shift by 33 uses only the low 5 bits (1): 17 << 1 = 0x22
mulh x29, x3, x3       # mulh with both operands negative
addi x30, x0, 2047     # largest 12-bit immediate
addi x31, x0, -2048    # smallest 12-bit immediate
