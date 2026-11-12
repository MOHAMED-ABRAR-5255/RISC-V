# Maximum of 8 words at data memory addresses 0..28
addi x1,x0,0
lw x2,0(x1)
addi x3,x0,8
loop: addi x1,x1,4
lw x4,0(x1)
blt x2,x4,update
jal x0,cont
update: addi x2,x4,0
cont: addi x3,x3,-1
bne x3,x0,loop
sw x2,32(x0)
