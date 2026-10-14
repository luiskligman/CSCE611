.text
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