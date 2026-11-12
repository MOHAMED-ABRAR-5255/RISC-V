module regfile (
    input clk,
    input we,
    input [4:0] waddr, raddr1, raddr2,
    input [31:0] wdata,
    output [31:0] rdata1, rdata2
);
    reg [31:0] regs [0:31];
    integer i;

    initial begin
        for (i=0;i<32;i=i+1) regs[i]=0;
    end

    always @(posedge clk) begin
        if (we && (waddr != 0))
            regs[waddr] <= wdata;
        regs[0] <= 32'b0;
    end

    // Write-through bypass for same-cycle read/write.
    assign rdata1 = (raddr1==0) ? 32'b0 :
                    ((we && (waddr==raddr1)) ? wdata : regs[raddr1]);
    assign rdata2 = (raddr2==0) ? 32'b0 :
                    ((we && (waddr==raddr2)) ? wdata : regs[raddr2]);
endmodule
