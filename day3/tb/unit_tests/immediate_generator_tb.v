`timescale 1ns/1ps
module immediate_generator_tb;
reg [31:0] instr;wire [31:0] imm;immediate_generator dut(instr,imm);
initial begin
 instr=32'hfff00093;#10;if(imm!==32'hffffffff)$display("I IMM FAIL");else $display("I IMM PASS");
 instr=32'h00208123;#10;$display("S immediate = %h",imm);
 instr=32'h00208463;#10;$display("B immediate = %h",imm);
 instr=32'h123450b7;#10;if(imm!==32'h12345000)$display("U IMM FAIL");else $display("U IMM PASS");
 instr=32'h008000ef;#10;$display("J immediate = %h",imm);
 $finish;
end
endmodule
