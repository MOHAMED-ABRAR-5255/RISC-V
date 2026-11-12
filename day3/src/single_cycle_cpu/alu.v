module alu(input [31:0] a,b, input [3:0] op, output reg [31:0] y, output zero);
always @* begin
 case(op)
  4'b0000: y=a+b;
  4'b0001: y=a-b;
  4'b0010: y=a&b;
  4'b0011: y=a|b;
  4'b0100: y=a^b;
  4'b0101: y=($signed(a)<$signed(b))?32'd1:32'd0;
  4'b0110: y=a<<b[4:0];
  4'b0111: y=a>>b[4:0];
  4'b1000: y=$signed(a)>>>b[4:0];
  default: y=0;
 endcase
end
assign zero=(y==0);
endmodule
