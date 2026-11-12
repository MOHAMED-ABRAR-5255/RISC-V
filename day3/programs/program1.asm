# Sum 1..10; final result x2=55
addi x1,x0,10
addi x2,x0,0
addi x3,x0,1
loop: add x2,x2,x3
addi x3,x3,1
blt x1,x3,exit
jal x0,loop
exit: sw x2,0(x0)
