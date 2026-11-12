`timescale 1ns/1ps
module regfile_tb;
    reg clk=0,we;
    reg [4:0] waddr,raddr1,raddr2;
    reg [31:0] wdata;
    wire [31:0] rdata1,rdata2;
    integer k,idx;
    reg [31:0] model [0:31];
    reg [31:0] expected1,expected2;
    reg [31:0] rand_data;
    reg [4:0] rand_addr1,rand_addr2;
    reg rand_we;
    reg [4:0] rand_waddr;
    reg [31:0] rand_wdata;

    regfile dut(.*);
    always #5 clk=~clk;

    task write_reg(input [4:0] addr,input [31:0] data);
        begin
            @(negedge clk); we=1; waddr=addr; wdata=data;
            @(posedge clk); #1;
            if(addr!=0) model[addr]=data;
        end
    endtask

    initial begin
        for(idx=0;idx<32;idx=idx+1) model[idx]=0;
        we=0; waddr=0; wdata=0; raddr1=0; raddr2=0;

        // x0 write must be ignored
        write_reg(0,32'hdeadbeef);
        #1;
        if(dut.regs[0] !== 0) $display("ERROR: x0 changed");

        // Bypass check before the active write edge.
        @(negedge clk); we=1; waddr=5; wdata=32'h1234abcd;
        raddr1=5; raddr2=0; #1;
        if(rdata1 !== 32'h1234abcd) $display("ERROR: bypass failed");
        @(posedge clk); #1; model[5]=32'h1234abcd;

        // Back-to-back writes
        write_reg(6,32'h11111111);
        write_reg(7,32'h22222222);
        we=0;

        // Random 200 operations, including writes and reads.
        for(k=0;k<200;k=k+1) begin
            @(negedge clk);
            rand_we=$random;
            rand_waddr=$random;
            rand_addr1=$random;
            rand_addr2=$random;
            rand_wdata=$random;
            we=rand_we; waddr=rand_waddr; wdata=rand_wdata;
            raddr1=rand_addr1; raddr2=rand_addr2;
            #1;
            expected1=(raddr1==0)?0:((we && waddr==raddr1)?wdata:model[raddr1]);
            expected2=(raddr2==0)?0:((we && waddr==raddr2)?wdata:model[raddr2]);
            if(rdata1 !== expected1 || rdata2 !== expected2)
                $display("ERROR op=%0d r1=%0d r2=%0d",k,raddr1,raddr2);
            @(posedge clk); #1;
            if(we && waddr!=0) model[waddr]=wdata;
        end
        $display("Register file test completed.");
        $finish;
    end
endmodule
