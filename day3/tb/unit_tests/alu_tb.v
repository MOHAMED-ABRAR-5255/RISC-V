`timescale 1ns/1ps
module alu_tb;
reg [31:0] a,b; reg [3:0] op; wire [31:0] y; wire zero;
alu dut(a,b,op,y,zero);
initial begin
 a=10;b=3;op=0;#10;if(y!==13)$display("ADD FAIL");else $display("ADD PASS");
 op=1;#10;if(y!==7)$display("SUB FAIL");else $display("SUB PASS");
 op=2;#10;if(y!==(a&b))$display("AND FAIL");else $display("AND PASS");
 op=3;#10;if(y!==(a|b))$display("OR FAIL");else $display("OR PASS");
 op=4;#10;if(y!==(a^b))$display("XOR FAIL");else $display("XOR PASS");
 op=5;#10;if(y!==1)$display("SLT FAIL");else $display("SLT PASS");
 op=6;b=2;#10;if(y!==(a<<2))$display("SLL FAIL");else $display("SLL PASS");
 op=7;#10;if(y!==(a>>2))$display("SRL FAIL");else $display("SRL PASS");
 $finish;
end
endmodule
