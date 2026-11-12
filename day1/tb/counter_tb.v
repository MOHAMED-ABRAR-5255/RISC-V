`timescale 1ns/1ps
module counter_tb;
    reg clk=0,reset,enable,up_down,load;
    reg [7:0] load_data;
    wire [7:0] count;
    counter dut(.*);
    always #5 clk=~clk;
    initial begin
        reset=1; enable=0; up_down=1; load=0; load_data=0;
        repeat(2) @(negedge clk);
        reset=0; enable=1; up_down=1;
        repeat(5) @(negedge clk);
        up_down=0; repeat(3) @(negedge clk);
        load=1; load_data=8'hA5; @(negedge clk);
        load=0; enable=1; up_down=1; repeat(2) @(negedge clk);
        reset=1; @(negedge clk); reset=0;
        repeat(2) @(negedge clk);
        $finish;
    end
endmodule
