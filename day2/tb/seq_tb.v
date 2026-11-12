`timescale 1ns/1ps
module seq_tb;
    reg clk=0, reset, serial_in;
    wire moore_detected, mealy_detected;
    integer i;
    reg [31:0] streams [0:2];
    reg [5:0] lengths [0:2];
    seq_moore m(clk,reset,serial_in,moore_detected);
    seq_mealy y(clk,reset,serial_in,mealy_detected);
    always #5 clk=~clk;

    task run_stream(input [31:0] bits, input integer n);
        integer k;
        begin
            reset=1; serial_in=0; @(negedge clk); reset=0;
            for(k=n-1;k>=0;k=k-1) begin
                serial_in=bits[k];
                @(negedge clk);
                $display("input=%b Moore=%b Mealy=%b",serial_in,moore_detected,mealy_detected);
            end
            repeat(2) @(negedge clk);
        end
    endtask

    initial begin
        reset=1; serial_in=0;
        streams[0]=32'b10110000; lengths[0]=8;
        streams[1]=32'b1011011;   lengths[1]=7;
        streams[2]=32'b11101011011; lengths[2]=11;
        @(negedge clk); reset=0;
        for(i=0;i<3;i=i+1) run_stream(streams[i],lengths[i]);
        $finish;
    end
endmodule
