module shifter(
 input [31:0] data_in,
 input [4:0] shamt,
 input [1:0] shift_type, // 00=SLL, 01=SRL, 10=SRA
 output reg [31:0] data_out
);
always @* begin
 case(shift_type)
  2'b00: data_out = data_in << shamt;
  2'b01: data_out = data_in >> shamt;
  2'b10: data_out = $signed(data_in) >>> shamt;
  default: data_out = data_in;
 endcase
end
endmodule
