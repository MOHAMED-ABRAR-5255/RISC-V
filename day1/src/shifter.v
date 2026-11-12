module shifter #(parameter WIDTH=32) (
    input [WIDTH-1:0] data_in,
    input [$clog2(WIDTH)-1:0] shamt,
    input [1:0] mode, // 00 SLL, 01 SRL, 10 SRA
    output reg [WIDTH-1:0] data_out
);
    always @* begin
        case (mode)
            2'b00: data_out = data_in << shamt;
            2'b01: data_out = data_in >> shamt;
            2'b10: data_out = $signed(data_in) >>> shamt;
            default: data_out = {WIDTH{1'b0}};
        endcase
    end
endmodule
