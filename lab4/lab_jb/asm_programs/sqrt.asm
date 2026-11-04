start:
csrrw x1, 0xf00, x0  # read from switch


li x2, 0            # current guess
li x3, 16777216     # set step


loop: 
add x6, x2, x3      # try = guess + step
mul x4, x6, x6      # squaring try to see if it fits within input
mulhu x5, x6, x6    # upper part of square
bltu x5, x1, keep   # upper part less than input, it fits. Keep
bne x5, x1, half    # upper part larger, but not equal, half.
bne x4, x0, half    # if equal, check lower half = 0. If not 0, half. 

keep: 
addi x2, x6, 0      # try smaller than input

half:
srli x3, x3, 1      # multipy step by 0.5
bne x3, x0, loop    # if not 0, keep going

output:
li x7, 100000       #   scale
mul x4, x2, x7      #   lower part = guess * scale
mulhu x5, x2, x7    #   also higher part
srli x4, x4, 16     #   
slli x5, x5, 16     #
or x10, x5, x4      #  putting the guess into x10
addi x11, x0, 0     #  set x11 to 0

li  x12, 0x1999999a         #approx for 0.1 for the workaround divide
addi x13, x0, 10	   #divide amount	

#digit 0
mul   x14, x10, x12       # low half: fractional part of value / 10
mulhu x15, x10, x12       # high half: quotient = value / 10
mulhu x16, x14, x13       # high half: digit = value % 10
or    x11, x11, x16       # append that digit
addi  x10, x15, 0         # value = quotient

#digit 1
mul   x14, x10, x12       # low half: fractional part of value / 10
mulhu x15, x10, x12       # high half: quotient = value / 10
mulhu x16, x14, x13       # high half: digit = value % 10
slli  x16, x16, 4         # make room for one BCD digit
or    x11, x11, x16       # append that digit
addi  x10, x15, 0         # value = quotient

#digit 2
mul   x14, x10, x12       # low half: fractional part of value / 10
mulhu x15, x10, x12       # high half: quotient = value / 10
mulhu x16, x14, x13       # high half: digit = value % 10
slli  x16, x16, 8         # make room for one BCD digit
or    x11, x11, x16       # append that digit
addi  x10, x15, 0         # value = quotient

#digit 3
mul   x14, x10, x12       # low half: fractional part of value / 10
mulhu x15, x10, x12       # high half: quotient = value / 10
mulhu x16, x14, x13       # high half: digit = value % 10
slli  x16, x16, 12         # make room for one BCD digit
or    x11, x11, x16       # append that digit
addi  x10, x15, 0         # value = quotient

#digit 4
mul   x14, x10, x12       # low half: fractional part of value / 10
mulhu x15, x10, x12       # high half: quotient = value / 10
mulhu x16, x14, x13       # high half: digit = value % 10
slli  x16, x16, 16        # make room for one BCD digit
or    x11, x11, x16       # append that digit
addi  x10, x15, 0         # value = quotient

#digit 5
mul   x14, x10, x12       # low half: fractional part of value / 10
mulhu x15, x10, x12       # high half: quotient = value / 10
mulhu x16, x14, x13       # high half: digit = value % 10
slli  x16, x16, 20         # make room for one BCD digit
or    x11, x11, x16       # append that digit
addi  x10, x15, 0         # value = quotient

#digit 6
mul   x14, x10, x12       # low half: fractional part of value / 10
mulhu x15, x10, x12       # high half: quotient = value / 10
mulhu x16, x14, x13       # high half: digit = value % 10
slli  x16, x16, 24         # make room for one BCD digit
or    x11, x11, x16       # append that digit
addi  x10, x15, 0         # value = quotient

#digit 7
mul   x14, x10, x12       # low half: fractional part of value / 10
mulhu x15, x10, x12       # high half: quotient = value / 10
mulhu x16, x14, x13       # high half: digit = value % 10
slli  x16, x16, 28         # make room for one BCD digit
or    x11, x11, x16       # append that digit
addi  x10, x15, 0         # value = quotient

csrrw x0, 0xf02, x11     #output to hex
jal x0, start