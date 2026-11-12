module seq_mealy(input clk, reset, serial_in, output reg detected);
    localparam S0=2'd0, S1=2'd1, S2=2'd2, S3=2'd3;
    reg [1:0] state, next_state;

    always @(posedge clk) begin
        if (reset) state <= S0;
        else       state <= next_state;
    end

    always @* begin
        next_state = state;
        detected = 1'b0;
        case (state)
            S0: next_state = serial_in ? S1 : S0;
            S1: next_state = serial_in ? S1 : S2;
            S2: next_state = serial_in ? S3 : S0;
            S3: begin
                if (serial_in) begin
                    detected = 1'b1; // pattern 1011 completes on this input
                    next_state = S1; // suffix "1" allows overlap
                end else next_state = S2;
            end
            default: next_state = S0;
        endcase
    end
endmodule
