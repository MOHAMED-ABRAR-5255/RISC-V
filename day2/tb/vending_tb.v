`timescale 1ns/1ps
module vending_tb;
    reg clk=0,reset,coin5,coin10,cancel;
    wire dispense;
    wire [4:0] change;
    vending dut(.*);
    always #5 clk=~clk;
    task tick; begin @(negedge clk); end endtask
    initial begin
        reset=1; coin5=0; coin10=0; cancel=0; tick(); reset=0;
        // Exact payment: 10 + 5
        coin10=1; tick(); coin10=0; coin5=1; tick(); coin5=0;
        // Overpayment: 10 + 10 -> dispense and return 5
        coin10=1; tick(); coin10=0; coin10=1; tick(); coin10=0;
        // Cancel after inserting 5 + 5; refund 10
        coin5=1; tick(); coin5=0; coin5=1; tick(); coin5=0;
        cancel=1; tick(); cancel=0;
        // Coin 5 then coin 10 exact payment
        coin5=1; tick(); coin5=0; coin10=1; tick(); coin10=0;
        repeat(2) tick();
        $finish;
    end
endmodule
