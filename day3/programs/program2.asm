# Fibonacci sequence (first 10 values); x10 points to output memory
addi x10,x0,0
addi x1,x0,0
addi x2,x0,1
addi x3,x0,10
loop: sw x1,0(x10)
add x4,x1,x2
addi x1,x2,0
addi x2,x4,0
addi x10,x10,4
addi x3,x3,-1
bne x3,x0,loop
