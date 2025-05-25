addi x8 x0 $30
addi x9 x0 $5
addi x10 x0 $10
lw x6 x0 $4
andi x2 x6 $15
add x4 x4 x2
bge x4 x8 56
addi x7 x0 $0
bne x6 x2 56
bne x5 x0 56
nop
nop
nop
nop
nop
nop
addi x5 x0 $0
sw x7 x0 $8
lw x6 x0 $4
jal x0 -60
addi x7 x0 $16
sub x4 x4 x8
addi x5 x0 $1
bge x4 x10 24
bge x4 x9 32
nop
nop
beq x4 x0 -44
ecall
or x7 x7 x10
sub x4 x4 x10
jal x0 12
or x7 x7 x9
sub x4 x4 x9
beq x4 x0 -72
jal x0 -72
