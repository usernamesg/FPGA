module mealy_fsm_101(
    input clk,
    input reset,
    input x,
    input valid,
    output reg y
);

    localparam [1:0]
        S0 = 2'b00,
        S1 = 2'b01,
        S2 = 2'b10;

    reg [1:0] curr_state, next_state;

    // 현재 상태
    always @(posedge clk or posedge reset) begin
        if (reset)
            curr_state <= S0;
        else if (valid)
            curr_state <= next_state;
    end

    // 다음 상태 + Mealy 출력
    always @(*) begin
        next_state = curr_state;
        y = 1'b0;

        if (valid) begin
            case (curr_state)
                S0: next_state = x ? S1 : S0;

                S1: next_state = x ? S1 : S2;

                S2: begin
                    if (x) begin
                        next_state = S1;
                        y = 1'b1;
                    end
                    else
                        next_state = S0;
                end

                default: next_state = S0;
            endcase
        end
    end

endmodule