module seq_moore(input clk, reset, serial_in, output reg detected);
    localparam S0=3'd0, S1=3'd1, S2=3'd2, S3=3'd3, S4=3'd4;
    reg [2:0] state, next_state;

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
            S3: next_state = serial_in ? S4 : S2;
            S4: begin
                detected = 1'b1;
                next_state = serial_in ? S1 : S2; // retain suffix for overlap
            end
            default: next_state = S0;
        endcase
    end
endmodule
