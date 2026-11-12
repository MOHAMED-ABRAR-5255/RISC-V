`timescale 1ns/1ps
module shifter_tb;
reg [31:0] data_in;reg [4:0] shamt;reg [1:0] shift_type;wire [31:0] data_out;
shifter dut(data_in,shamt,shift_type,data_out);
initial begin
 data_in=32'h0000000f;shamt=2;shift_type=0;#10;
 if(data_out!==32'h3c)$display("SLL FAIL");else $display("SLL PASS");
 shift_type=1;#10;if(data_out!==3)$display("SRL FAIL");else $display("SRL PASS");
 data_in=32'h80000000;shift_type=2;shamt=1;#10;
 if(data_out!==32'hc0000000)$display("SRA FAIL");else $display("SRA PASS");
 $finish;
end
endmodule
