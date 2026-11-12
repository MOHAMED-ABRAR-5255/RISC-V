`timescale 1ns/1ps
module cpu_tb;
reg clk=0,reset=1;wire [31:0] pc,instr,alu,wb;
cpu dut(clk,reset,pc,instr,alu,wb);
always #5 clk=~clk;
integer k;
initial begin
 // Program: sum 1..10, result x2=55 and memory[0]=55
 dut.imem[0]=32'h00a00093; // addi x1,x0,10
 dut.imem[1]=32'h00000113; // addi x2,x0,0
 dut.imem[2]=32'h00100193; // addi x3,x0,1
 dut.imem[3]=32'h00310133; // add x2,x2,x3
 dut.imem[4]=32'h00118193; // addi x3,x3,1
 dut.imem[5]=32'h0030c463; // blt x1,x3,exit (offset 8)
 dut.imem[6]=32'hff9ff06f; // jal x0,loop (-8)
 dut.imem[7]=32'h00202023; // sw x2,0(x0)
 #12 reset=0;
 for(k=0;k<100;k=k+1) @(posedge clk);
 if(dut.rf.regs[2]==55 && dut.dmem[0]==55) $display("PROGRAM 1 PASS");
 else $display("PROGRAM 1 FAIL x2=%0d mem=%0d",dut.rf.regs[2],dut.dmem[0]);
 $finish;
end
endmodule
