`timescale 1ns/1ps
module register_file_tb;
reg clk=0,we;reg [4:0] ra1,ra2,wa;reg [31:0] wd;wire [31:0] rd1,rd2;
register_file dut(clk,we,ra1,ra2,wa,wd,rd1,rd2);always #5 clk=~clk;
initial begin
 we=1;wa=5;wd=32'h12345678;ra1=5;ra2=0;@(posedge clk);#1;
 if(rd1!==32'h12345678)$display("WRITE/READ FAIL");else $display("WRITE/READ PASS");
 wa=0;wd=99;@(posedge clk);#1;if(rd2!==0)$display("x0 FAIL");else $display("x0 PASS");
 $finish;
end
endmodule
