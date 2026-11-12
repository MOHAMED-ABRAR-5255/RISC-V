module vending(input clk, reset, coin5, coin10, cancel,
               output reg dispense, output reg [4:0] change);
    reg [4:0] credit;
    reg [5:0] next_credit;

    // Coin inputs are one-cycle pulses. If both are high, coin10 is accepted.
    always @* begin
        next_credit = credit;
        if (coin10) next_credit = credit + 10;
        else if (coin5) next_credit = credit + 5;
    end

    always @(posedge clk) begin
        if (reset) begin
            credit <= 0; dispense <= 0; change <= 0;
        end else begin
            dispense <= 0;
            change <= 0;
            if (cancel) begin
                change <= credit;
                credit <= 0;
            end else if (coin5 || coin10) begin
                if (next_credit >= 15) begin
                    dispense <= 1;
                    change <= next_credit - 15;
                    credit <= 0;
                end else credit <= next_credit[4:0];
            end
        end
    end
endmodule
