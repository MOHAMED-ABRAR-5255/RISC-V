`timescale 1ns/1ps
module pipeline_tb;
reg clk=0,reset=1;wire [31:0] pc;pipeline_cpu dut(clk,reset,pc);always #5 clk=~clk;integer n;
initial begin
 // dependency/branch/load-use demo program (machine words can be replaced)
 dut.imem[0]=32'h00500093; // addi x1,x0,5
 dut.imem[1]=32'h00308113; // addi x2,x1,3
 dut.imem[2]=32'h00202023; // sw x2,0(x0)
 dut.imem[3]=32'h00002183; // lw x3,0(x0)
 dut.imem[4]=32'h00118213; // addi x4,x3,1
 #12 reset=0;for(n=0;n<30;n=n+1)@(posedge clk);
 if(dut.regs[1]==5 && dut.regs[2]==8 && dut.regs[3]==8 && dut.regs[4]==9) $display("PIPELINE PASS");
 else $display("PIPELINE FAIL x1=%0d x2=%0d x3=%0d x4=%0d",dut.regs[1],dut.regs[2],dut.regs[3],dut.regs[4]);
 $finish;
end
endmodule
