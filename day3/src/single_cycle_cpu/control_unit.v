module control_unit(input [31:0] instr, output reg regwrite,memread,memwrite,memtoreg,
 output reg alusrc, output reg [3:0] aluop, output reg branch,jal,lui,
 output reg [1:0] branch_type);
always @* begin
 regwrite=0;memread=0;memwrite=0;memtoreg=0;alusrc=0;aluop=0;branch=0;jal=0;lui=0;branch_type=0;
 case(instr[6:0])
  7'b0110011: begin regwrite=1; case({instr[30],instr[14:12]})
   4'b0000:aluop=0; 4'b1000:aluop=1; 4'b0111:aluop=2;
   4'b0110:aluop=3; 4'b0100:aluop=4; 4'b0010:aluop=5;
   4'b0001:aluop=6; 4'b0101:aluop=7; 4'b1101:aluop=8; default:aluop=0; endcase end
  7'b0010011: begin regwrite=1;alusrc=1;case(instr[14:12])
   3'b000:aluop=0;3'b111:aluop=2;3'b110:aluop=3;3'b100:aluop=4;3'b010:aluop=5;
   3'b001:aluop=6;3'b101:aluop=instr[30]?8:7;default:aluop=0;endcase end
  7'b0000011:begin regwrite=1;memread=1;memtoreg=1;alusrc=1;aluop=0;end
  7'b0100011:begin memwrite=1;alusrc=1;aluop=0;end
  7'b1100011:begin branch=1;aluop=1;branch_type=instr[14:12]==3'b000?0:
   instr[14:12]==3'b001?1:instr[14:12]==3'b100?2:instr[14:12]==3'b101?3:instr[14:12]==3'b110?4:5;end
  7'b0110111:begin regwrite=1;lui=1;end
  7'b1101111:begin regwrite=1;jal=1;end
 endcase
end
endmodule
