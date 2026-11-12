module alu #(parameter WIDTH = 32) (
    input  [WIDTH-1:0] a, b,
    input  [2:0]       op,
    output reg [WIDTH-1:0] result,
    output zero, negative, carry, overflow
);
    localparam ADD=3'b000, SUB=3'b001, AND_OP=3'b010,
               OR_OP=3'b011, XOR_OP=3'b100, SLT=3'b101,
               SLL=3'b110, SRL_SRA=3'b111;

    reg [WIDTH:0] ext_result;
    reg signed [WIDTH-1:0] signed_a, signed_b;
    reg signed [WIDTH-1:0] signed_result;
    reg carry_flag, overflow_flag;

    always @* begin
        result = {WIDTH{1'b0}};
        ext_result = {(WIDTH+1){1'b0}};
        carry_flag = 1'b0;
        overflow_flag = 1'b0;
        signed_a = a;
        signed_b = b;
        signed_result = {WIDTH{1'b0}};

        case (op)
            ADD: begin
                ext_result = {1'b0,a} + {1'b0,b};
                result = ext_result[WIDTH-1:0];
                carry_flag = ext_result[WIDTH];
                overflow_flag = (~(a[WIDTH-1] ^ b[WIDTH-1])) &
                                (result[WIDTH-1] ^ a[WIDTH-1]);
            end
            SUB: begin
                ext_result = {1'b0,a} - {1'b0,b};
                result = ext_result[WIDTH-1:0];
                // For subtraction, carry means "no borrow".
                carry_flag = (a >= b);
                overflow_flag = (a[WIDTH-1] ^ b[WIDTH-1]) &
                                (result[WIDTH-1] ^ a[WIDTH-1]);
            end
            AND_OP: result = a & b;
            OR_OP : result = a | b;
            XOR_OP: result = a ^ b;
            SLT   : result = (signed_a < signed_b) ? {{(WIDTH-1){1'b0}},1'b1} : {WIDTH{1'b0}};
            SLL   : result = a << b[$clog2(WIDTH)-1:0];
            SRL_SRA: result = a >> b[$clog2(WIDTH)-1:0]; // logical right shift
            default: result = {WIDTH{1'b0}};
        endcase
    end

    assign zero = (result == {WIDTH{1'b0}});
    assign negative = result[WIDTH-1];
    assign carry = carry_flag;
    assign overflow = overflow_flag;
endmodule
