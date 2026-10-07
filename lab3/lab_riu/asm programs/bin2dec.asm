csrrw x10, 0xf00, x0      #read from switch
addi x11, x0, 0

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
