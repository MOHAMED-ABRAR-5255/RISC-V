module cpu(input clk,reset,output reg [31:0] pc,output [31:0] instr_out,alu_out,wb_out);
reg [31:0] imem[0:255],dmem[0:255]; integer i;
wire [31:0] instr=imem[pc[9:2]],imm,rd1,rd2,srcb,alu_y,memdata,pc4,jtarget;
wire regwrite,memread,memwrite,memtoreg,alusrc,branch,jal,lui,zero;
wire [3:0] aluop;wire [1:0] branch_type;wire [31:0] wb;
wire takebranch;
initial begin for(i=0;i<256;i=i+1) begin imem[i]=0;dmem[i]=0;end end
immediate_generator ig(instr,imm);
control_unit cu(instr,regwrite,memread,memwrite,memtoreg,alusrc,aluop,branch,jal,lui,branch_type);
register_file rf(clk,regwrite,instr[19:15],instr[24:20],instr[11:7],wb,rd1,rd2);
assign srcb=alusrc?imm:rd2;
alu a1(rd1,srcb,aluop,alu_y,zero);
assign memdata=dmem[alu_y[9:2]];
assign wb=lui?imm:jal?pc+4:memtoreg?memdata:alu_y;
assign pc4=pc+4;assign jtarget=pc+imm;
assign takebranch=branch && ((branch_type==0 && rd1==rd2)||(branch_type==1 && rd1!=rd2)||
(branch_type==2 && $signed(rd1)<$signed(rd2))||(branch_type==3 && $signed(rd1)>=$signed(rd2))||
(branch_type==4 && rd1<rd2)||(branch_type==5 && rd1>=rd2));
always @(posedge clk) begin
 if(reset) pc<=0;
 else if(jal) pc<=jtarget;
 else if(takebranch) pc<=jtarget;
 else pc<=pc4;
 if(memwrite) dmem[alu_y[9:2]]<=rd2;
end
assign instr_out=instr;assign alu_out=alu_y;assign wb_out=wb;
endmodule
