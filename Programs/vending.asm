addi x8 x0 $50
addi x9 x0 $5
addi x10 x0 $10
addi x11 x0 $25
lw x6 x0 $4
addi x7 x0 $0
andi x2 x6 $0x7ff
add x4 x4 x2
bne x6 x2 68
bne x5 x0 68
nop
nop
nop
bge x4 x8 32
nop
nop
nop
addi x5 x0 $0
sw x7 x0 $8
lw x6 x0 $4
jal x0 -60
addi x7 x0 $0x800
sub x4 x4 x8
addi x5 x0 $1
jal x0 -24
addi x5 x0 $1
bge x4 x11 32
bge x4 x10 40
bge x4 x9 48
nop
nop
nop
beq x4 x0 -60
ecall
or x7 x7 x11
sub x4 x4 x11
jal x0 24
or x7 x7 x10
sub x4 x4 x10
jal x0 12
or x7 x7 x9
sub x4 x4 x9
nop
nop
beq x4 x0 -108
jal x0 -108
