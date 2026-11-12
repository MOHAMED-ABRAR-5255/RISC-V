// Compact RV32I five-stage pipeline: IF, ID, EX, MEM, WB.
// Supports R/I arithmetic, loads/stores, branches, LUI and JAL.
// Forwarding and load-use interlock are implemented; branch resolves in EX.
module pipeline_cpu(input clk,reset,output [31:0] pc_out);
reg [31:0] imem[0:255],dmem[0:255],regs[0:31];integer i;
reg [31:0] pc;
assign pc_out=pc;
// IF/ID
reg [31:0] ifid_pc,ifid_instr;
// ID/EX
reg [31:0] idex_pc,idex_imm,idex_r1,idex_r2;
reg [4:0] idex_rs1,idex_rs2,idex_rd;
reg [3:0] idex_aluop;
reg idex_regwrite,idex_memread,idex_memwrite,idex_memtoreg,idex_alusrc,idex_branch,idex_jal,idex_lui;
reg [2:0] idex_funct3;
// EX/MEM
reg [31:0] exmem_alu,exmem_store,exmem_pc4;
reg [4:0] exmem_rd;reg exmem_regwrite,exmem_memread,exmem_memwrite,exmem_memtoreg,exmem_lui;
reg [31:0] exmem_imm;
// MEM/WB
reg [31:0] memwb_data,memwb_alu,memwb_pc4,memwb_imm;
reg [4:0] memwb_rd;reg memwb_regwrite,memwb_memtoreg,memwb_jal,memwb_lui;
wire [6:0] op=ifid_instr[6:0];
wire [31:0] id_imm;
reg [3:0] id_aluop;reg id_regwrite,id_memread,id_memwrite,id_memtoreg,id_alusrc,id_branch,id_jal,id_lui;
reg [2:0] id_funct3;
always @* begin
 id_aluop=0;id_regwrite=0;id_memread=0;id_memwrite=0;id_memtoreg=0;id_alusrc=0;id_branch=0;id_jal=0;id_lui=0;id_funct3=ifid_instr[14:12];
 case(op)
  7'b0110011:begin id_regwrite=1;case({ifid_instr[30],ifid_instr[14:12]})
  4'b0000:id_aluop=0;4'b1000:id_aluop=1;4'b0111:id_aluop=2;4'b0110:id_aluop=3;4'b0100:id_aluop=4;4'b0010:id_aluop=5;4'b0001:id_aluop=6;4'b0101:id_aluop=7;4'b1101:id_aluop=8;endcase end
  7'b0010011:begin id_regwrite=1;id_alusrc=1;case(ifid_instr[14:12])
  3'b000:id_aluop=0;3'b111:id_aluop=2;3'b110:id_aluop=3;3'b100:id_aluop=4;3'b010:id_aluop=5;3'b001:id_aluop=6;3'b101:id_aluop=ifid_instr[30]?8:7;endcase end
  7'b0000011:begin id_regwrite=1;id_memread=1;id_memtoreg=1;id_alusrc=1;end
  7'b0100011:begin id_memwrite=1;id_alusrc=1;end
  7'b1100011:id_branch=1;
  7'b0110111:begin id_regwrite=1;id_lui=1;end
  7'b1101111:begin id_regwrite=1;id_jal=1;end
 endcase
end
assign id_imm=(op==7'b0110111)?{ifid_instr[31:12],12'b0}:
(op==7'b1101111)?{{11{ifid_instr[31]}},ifid_instr[31],ifid_instr[19:12],ifid_instr[20],ifid_instr[30:21],1'b0}:
(op==7'b1100011)?{{19{ifid_instr[31]}},ifid_instr[31],ifid_instr[7],ifid_instr[30:25],ifid_instr[11:8],1'b0}:
(op==7'b0100011)?{{20{ifid_instr[31]}},ifid_instr[31:25],ifid_instr[11:7]}:
{{20{ifid_instr[31]}},ifid_instr[31:20]};
wire load_stall=idex_memread && (idex_rd==ifid_instr[19:15] || idex_rd==ifid_instr[24:20]) && idex_rd!=0;
wire [31:0] wb_value=memwb_lui?memwb_imm:memwb_jal?memwb_pc4:memwb_memtoreg?memwb_data:memwb_alu;
wire [31:0] ex_a=(exmem_regwrite && exmem_rd!=0 && exmem_rd==idex_rs1)?(exmem_memtoreg?exmem_alu:exmem_alu):
(memwb_regwrite && memwb_rd!=0 && memwb_rd==idex_rs1)?wb_value:idex_r1;
wire [31:0] ex_rawb=(exmem_regwrite && exmem_rd!=0 && exmem_rd==idex_rs2)?exmem_alu:
(memwb_regwrite && memwb_rd!=0 && memwb_rd==idex_rs2)?wb_value:idex_r2;
wire [31:0] ex_b=idex_alusrc?idex_imm:ex_rawb;
reg [31:0] ex_result;
always @* begin case(idex_aluop)
0:ex_result=ex_a+ex_b;1:ex_result=ex_a-ex_b;2:ex_result=ex_a&ex_b;3:ex_result=ex_a|ex_b;4:ex_result=ex_a^ex_b;5:ex_result=($signed(ex_a)<$signed(ex_b));6:ex_result=ex_a<<ex_b[4:0];7:ex_result=ex_a>>ex_b[4:0];8:ex_result=$signed(ex_a)>>>ex_b[4:0];default:ex_result=0;endcase end
wire branch_taken=idex_branch && ((idex_funct3==0 && ex_a==ex_rawb)||(idex_funct3==1 && ex_a!=ex_rawb)||(idex_funct3==4 && $signed(ex_a)<$signed(ex_rawb))||(idex_funct3==5 && $signed(ex_a)>=$signed(ex_rawb))||(idex_funct3==6 && ex_a<ex_rawb)||(idex_funct3==7 && ex_a>=ex_rawb));
wire [31:0] redirect=idex_jal?idex_pc+idex_imm:idex_pc+idex_imm;
wire flush=branch_taken || idex_jal;
initial begin pc=0;for(i=0;i<256;i=i+1)begin imem[i]=0;dmem[i]=0;end for(i=0;i<32;i=i+1)regs[i]=0;end
always @(posedge clk) begin
 if(reset) begin pc<=0;ifid_pc<=0;ifid_instr<=0;idex_regwrite<=0;idex_memread<=0;idex_memwrite<=0;idex_memtoreg<=0;idex_branch<=0;idex_jal<=0;idex_lui<=0;exmem_regwrite<=0;exmem_memread<=0;exmem_memwrite<=0;exmem_memtoreg<=0;memwb_regwrite<=0;end
 else begin
 // WB
 if(memwb_regwrite && memwb_rd!=0) regs[memwb_rd]<=wb_value;
 // MEM
 memwb_data<=dmem[exmem_alu[9:2]];memwb_alu<=exmem_alu;memwb_pc4<=exmem_pc4;memwb_imm<=exmem_imm;memwb_rd<=exmem_rd;memwb_regwrite<=exmem_regwrite;memwb_memtoreg<=exmem_memtoreg;memwb_jal<=0;memwb_lui<=exmem_lui;
 if(exmem_memwrite) dmem[exmem_alu[9:2]]<=exmem_store;
 // EX -> MEM
 exmem_alu<=ex_result;exmem_store<=ex_rawb;exmem_pc4<=idex_pc+4;exmem_rd<=idex_rd;exmem_regwrite<=idex_regwrite;exmem_memread<=idex_memread;exmem_memwrite<=idex_memwrite;exmem_memtoreg<=idex_memtoreg;exmem_lui<=idex_lui;exmem_imm<=idex_imm;
 // ID -> EX (bubble on load-use)
 if(load_stall || flush) begin idex_regwrite<=0;idex_memread<=0;idex_memwrite<=0;idex_memtoreg<=0;idex_branch<=0;idex_jal<=0;idex_lui<=0;end
 else begin idex_pc<=ifid_pc;idex_imm<=id_imm;idex_r1<=regs[ifid_instr[19:15]];idex_r2<=regs[ifid_instr[24:20]];idex_rs1<=ifid_instr[19:15];idex_rs2<=ifid_instr[24:20];idex_rd<=ifid_instr[11:7];idex_aluop<=id_aluop;idex_regwrite<=id_regwrite;idex_memread<=id_memread;idex_memwrite<=id_memwrite;idex_memtoreg<=id_memtoreg;idex_alusrc<=id_alusrc;idex_branch<=id_branch;idex_jal<=id_jal;idex_lui<=id_lui;idex_funct3<=id_funct3;end
 // IF
 if(flush) begin pc<=redirect;ifid_instr<=0;ifid_pc<=0;end
 else if(load_stall) begin pc<=pc;ifid_instr<=ifid_instr;ifid_pc<=ifid_pc;end
 else begin ifid_instr<=imem[pc[9:2]];ifid_pc<=pc;pc<=pc+4;end
 end
end
endmodule
