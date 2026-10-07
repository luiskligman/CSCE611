cssrw x10, 0xf00, x0
addi x11, x0, 0

addi x12, x0, 0x1999999A  #approx for 0.1 for the workaround divide
addi x13, x0, 10	   #divide amount	

mul   x14, x10, x12       # low half: fractional part of value / 10
mulhu x15, x10, x12       # high half: quotient = value / 10
mulhu x16, x14, x13       # high half: digit = value % 10

slli  x11, x11, 4         # make room for one BCD digit
or    x11, x11, x16       # append that digit
addi  x10, x15, 0         # value = quotient