
`timescale 1ns / 1ps

module main_controller(
    input clk,
    input reset,
    input [2:0] btn,
    input [7:0] sw,
    output [13:0] seg_data,
    output [15:0] led
    );

    parameter IDLE = 2'b00;
    parameter UP_COUNTER = 2'b01;
    parameter DOWN_COUNTER = 2'b10;
    parameter SLIDE_SW_READ = 2'b11;

    parameter CLK_FREQ = 100_000_000;
    parameter MS10_COUNT = CLK_FREQ / 100;

    reg [1:0] state;
    reg [13:0] r_ms10_counter;
    reg [19:0] r_clk_count;

    reg r_prev_btn;
    wire btn_pulse;

    assign btn_pulse = btn[0] & ~r_prev_btn;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            r_ms10_counter <= 0;
            r_clk_count <= 0;
            r_prev_btn <= 0;
        end
        else begin
            r_prev_btn <= btn[0];

            // FSM 상태 변경
            if (btn_pulse) begin
                case (state)
                    IDLE:
                        state <= UP_COUNTER;

                    UP_COUNTER:
                        state <= DOWN_COUNTER;

                    DOWN_COUNTER:
                        state <= SLIDE_SW_READ;

                    SLIDE_SW_READ:
                        state <= UP_COUNTER;

                    default:
                        state <= IDLE;
                endcase
            end

            // 10ms 카운터
            if (r_clk_count == MS10_COUNT - 1) begin
                r_clk_count <= 0;

                case (state)
                    IDLE:
                        r_ms10_counter <= r_ms10_counter;

                    UP_COUNTER:
                        r_ms10_counter <=
                            (r_ms10_counter == 9999) ?
                            0 : r_ms10_counter + 1;

                    DOWN_COUNTER:
                        r_ms10_counter <=
                            (r_ms10_counter == 0) ?
                            9999 : r_ms10_counter - 1;

                    SLIDE_SW_READ:
                        r_ms10_counter <= r_ms10_counter;

                    default:
                        r_ms10_counter <= r_ms10_counter;
                endcase
            end
            else begin
                r_clk_count <= r_clk_count + 1;
            end
        end
    end

    // FND 출력
    assign seg_data =
        (state == SLIDE_SW_READ) ?
        {6'b0, sw} : r_ms10_counter;

    // LED[15:14] : FSM 상태
    // LED[13:0]  : 카운터 또는 스위치 값
    assign led = {state, seg_data};

endmodule
