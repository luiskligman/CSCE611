li a7, 5  
ecall
mv x1, a0  # x1 = raw input with 14 fractional bits (input * 2^14)
           # if ever needed, we can take regular input and srli x1, x1, 14
li x2, 0  # current guess for sqrt(input) - default 0 to start
li x3, 4194304  # set step to 256 (2^8) with 14 fractional bits (2^14)
                # 2^22 = 4194304 raw step

loop:
mul x4, x2, x2  # store lower 32 bits in x4
mulhu x5, x2, x2  # store upper 32 bits in x5
srli x4, x4, 14  # get lower 18 bits 
slli x5, x5, 18  # get upper 14 bits
or x4, x4, x5  # combine lower 18 and upper 14 bits 
beq x4, x1, output  # if guess^2 == raw input, exit
bltu x4, x1, less_than  # guess^2 < raw input
jal x0, greater_than  # guess^2 > raw input

# add step if guess^2 < raw input
less_than:
add x2, x2, x3  # add step to current guess
jal x0, half

# subtract step if guess^2 > raw input
greater_than:
sub x2, x2, x3  # subtract step from current guess

# divide step by half
half:  
srli x3, x3, 1  # divide step by 2
beq x3, x0, output  # step == 0, exit
jal x0, loop

output:
mv a0, x2
li a7, 1
ecall
