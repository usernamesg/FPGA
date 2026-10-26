`timescale 1ns / 1ps

module moor_fsm_101(
    input clk,
    input reset,
    input x,
    input valid,
    output led
);

    localparam [1:0] S0 = 2'b00,
                     S1 = 2'b01,
                     S2 = 2'b10,
                     S3 = 2'b11;

    reg [1:0] curr_state, next_state;

    // 1. 현재 상태 저장
    always @(posedge clk or posedge reset) begin
        if (reset)
            curr_state <= S0;
        else if (valid)
            curr_state <= next_state;
    end

    // 2. 다음 상태 결정
    always @(*) begin
        case (curr_state)
            S0: next_state = x ? S1 : S0;
            S1: next_state = x ? S1 : S2;
            S2: next_state = x ? S3 : S0;
            S3: next_state = x ? S1 : S2;
            default: next_state = S0;
        endcase
    end

    // 3. Moore 출력
    assign led = (curr_state == S3);

endmodule