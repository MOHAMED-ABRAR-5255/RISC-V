`timescale 1ns/1ps
module alu_tb;
    reg [31:0] a,b;
    reg [2:0] op;
    wire [31:0] result;
    wire zero,negative,carry,overflow;
    integer i;
    alu dut(.a(a),.b(b),.op(op),.result(result),
            .zero(zero),.negative(negative),.carry(carry),.overflow(overflow));

    task check;
        input [31:0] x,y;
        input [2:0] operation;
        begin
            a=x; b=y; op=operation; #10;
            $display("op=%b a=%h b=%h result=%h Z=%b N=%b C=%b V=%b",
                     op,a,b,result,zero,negative,carry,overflow);
        end
    endtask

    initial begin
        check(0,0,3'b000);
        check(32'hffffffff,1,3'b000);
        check(32'h7fffffff,1,3'b000);
        check(32'h80000000,32'hffffffff,3'b000);
        check(10,10,3'b001);
        check(0,1,3'b001);
        check(32'h80000000,1,3'b001);
        check(32'h7fffffff,32'hffffffff,3'b001);
        check(32'hf0f0f0f0,32'h0ff00ff0,3'b010);
        check(32'hf0f0f0f0,32'h0ff00ff0,3'b011);
        check(32'hf0f0f0f0,32'h0ff00ff0,3'b100);
        check(32'hffffffff,1,3'b101);
        check(1,32'hffffffff,3'b101);
        check(32'h80000000,32'h7fffffff,3'b101);
        check(32'h7fffffff,32'h80000000,3'b101);
        check(32'h1,0,3'b110);
        check(32'h1,31,3'b110);
        check(32'h80000000,1,3'b110);
        check(32'h80000000,1,3'b111);
        check(32'hffffffff,4,3'b111);
        check(32'h12345678,0,3'b111);
        check(32'h0,31,3'b110);
        check(32'hffffffff,31,3'b110);
        check(32'h55555555,32'haaaaaaaa,3'b100);
        check(32'hffffffff,32'hffffffff,3'b010);
        $finish;
    end
endmodule
