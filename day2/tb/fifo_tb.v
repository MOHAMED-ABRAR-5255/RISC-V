`timescale 1ns/1ps
module fifo_tb;
    reg clk=0,reset,wr_en,rd_en;
    reg [7:0] data_in;
    wire [7:0] data_out;
    wire full,empty;
    integer i;
    fifo dut(.*);
    always #5 clk=~clk;
    task cycle; begin @(negedge clk); end endtask
    initial begin
        reset=1; wr_en=0; rd_en=0; data_in=0; cycle(); reset=0;
        // Fill to full.
        for(i=0;i<16;i=i+1) begin wr_en=1; data_in=i; cycle(); end
        wr_en=0; #1; if(!full) $display("ERROR: FIFO did not become full");
        // Attempt write when full; must be ignored.
        wr_en=1; data_in=8'hEE; cycle(); wr_en=0;
        // Drain to empty.
        for(i=0;i<16;i=i+1) begin rd_en=1; cycle(); end
        rd_en=0; #1; if(!empty) $display("ERROR: FIFO did not become empty");
        // Attempt read when empty; must be ignored.
        rd_en=1; cycle(); rd_en=0;
        // Simultaneous read/write with one existing word.
        wr_en=1; data_in=8'hA5; cycle();
        wr_en=1; rd_en=1; data_in=8'h5A; cycle();
        wr_en=0; rd_en=1; cycle(); rd_en=0;
        $display("FIFO directed test completed.");
        $finish;
    end
endmodule
