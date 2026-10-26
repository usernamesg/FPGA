
`timescale 1ns / 1ps

module fsm_1010111_detect(
    input clk,
    input reset,
    input btnU,
    input btnD,
    output [15:0] led
);

    // Mealy FSM: 7개 상태
    localparam [2:0] S0 = 3'd0,
                     S1 = 3'd1,
                     S2 = 3'd2,
                     S3 = 3'd3,
                     S4 = 3'd4,
                     S5 = 3'd5,
                     S6 = 3'd6;

    reg [2:0] curr_state, next_state;
    reg prev_U, prev_D;
    reg detected;

    // 버튼을 뗄 때 입력
    wire pulse_U = prev_U & ~btnU;
    wire pulse_D = prev_D & ~btnD;

    wire bit_valid = pulse_U ^ pulse_D;
    wire din = pulse_U;

    // 현재 상태 및 검출 결과 저장
    always @(negedge clk or negedge reset) begin
        if (!reset) begin
            curr_state <= S0;
            prev_U <= 0;
            prev_D <= 0;
            detected <= 0;
        end
        else begin
            prev_U <= btnU;
            prev_D <= btnD;

            if (bit_valid) begin
                curr_state <= next_state;
                detected <= (curr_state == S6 && din);
            end
        end
    end

    // 그림의 State Table과 동일한 상태 전이
    always @(*) begin
        case (curr_state)
            S0: next_state = din ? S1 : S0;
            S1: next_state = din ? S1 : S2;
            S2: next_state = din ? S3 : S0;
            S3: next_state = din ? S1 : S4;
            S4: next_state = din ? S5 : S0;
            S5: next_state = din ? S6 : S4;
            S6: next_state = din ? S1 : S2;
            default: next_state = S0;
        endcase
    end

    // 현재 상태를 LED0~LED6에 표시
    assign led[6:0] = 7'b0000001 << curr_state;

    // 사용하지 않는 LED
    assign led[14:7] = 8'b0;

    // 패턴 검출 결과
    assign led[15] = detected;

endmodule
