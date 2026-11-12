`timescale 1ns/1ps
module control_unit_tb;
reg [31:0] instr;
wire regwrite,memread,memwrite,memtoreg,alusrc,branch,jal,lui;
wire [3:0] aluop;wire [1:0] branch_type;
control_unit dut(instr,regwrite,memread,memwrite,memtoreg,alusrc,aluop,branch,jal,lui,branch_type);
initial begin
 instr=32'h003100b3;#10;if(!regwrite||alusrc)$display("R-type control FAIL");else $display("R-type PASS");
 instr=32'h00500093;#10;if(!regwrite||!alusrc)$display("ADDI control FAIL");else $display("ADDI PASS");
 instr=32'h00002083;#10;if(!memread||!memtoreg)$display("LW control FAIL");else $display("LW PASS");
 instr=32'h00102023;#10;if(!memwrite)$display("SW control FAIL");else $display("SW PASS");
 instr=32'h00208463;#10;if(!branch)$display("BEQ control FAIL");else $display("BEQ PASS");
 instr=32'h008000ef;#10;if(!jal||!regwrite)$display("JAL control FAIL");else $display("JAL PASS");
 $finish;
end
endmodule
