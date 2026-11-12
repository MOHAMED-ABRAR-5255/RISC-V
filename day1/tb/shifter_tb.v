`timescale 1ns/1ps
module shifter_tb;
    reg [31:0] data_in;
    reg [4:0] shamt;
    reg [1:0] mode;
    wire [31:0] data_out;
    reg [31:0] expected;
    integer s,m;
    shifter dut(.*);
    initial begin
        data_in=32'h8A35C2F1;
        for (m=0;m<3;m=m+1) begin
            mode=m;
            for (s=0;s<32;s=s+1) begin
                shamt=s; #1;
                case (mode)
                    0: expected=data_in << s;
                    1: expected=data_in >> s;
                    2: expected=$signed(data_in) >>> s;
                endcase
                if (data_out !== expected)
                    $display("ERROR mode=%0d shift=%0d got=%h expected=%h",m,s,data_out,expected);
            end
        end
        $display("Shifter reference-model test completed.");
        $finish;
    end
endmodule
