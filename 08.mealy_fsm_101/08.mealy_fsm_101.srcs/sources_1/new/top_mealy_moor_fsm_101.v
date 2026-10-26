`timescale 1ns / 1ps

module top_mealy_moor_fsm_101(
    input clk,
    input reset,
    input btnU,
    input btnD,
    output [1:0] led
);

    wire pulseU, pulseD;
    wire x, valid;

    wire moore_detect;
    wire mealy_detect;

    reg mealy_led;
    reg [25:0] hold_counter;

    // 버튼 디바운싱
    debouncer u_debounceU(
        .clk(clk),
        .reset(reset),
        .btn(btnU),
        .pulse(pulseU)
    );

    debouncer u_debounceD(
        .clk(clk),
        .reset(reset),
        .btn(btnD),
        .pulse(pulseD)
    );

    // 공통 입력
    assign x = pulseU;
    assign valid = pulseU ^ pulseD;

    // Moore FSM
    moor_fsm_101 u_moore(
        .clk(clk),
        .reset(reset),
        .x(x),
        .valid(valid),
        .led(moore_detect)
    );

    // Mealy FSM
    mealy_fsm_101 u_mealy(
        .clk(clk),
        .reset(reset),
        .x(x),
        .valid(valid),
        .y(mealy_detect)
    );

    // LED 출력
    assign led[0] = moore_detect;
    assign led[1] = mealy_led;

    // Mealy 검출을 0.5초 동안 LED에 표시
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            mealy_led <= 1'b0;
            hold_counter <= 0;
        end
        else if (mealy_detect) begin
            mealy_led <= 1'b1;
            hold_counter <= 50_000_000 - 1;
        end
        else if (hold_counter != 0) begin
            hold_counter <= hold_counter - 1'b1;
        end
        else begin
            mealy_led <= 1'b0;
        end
    end

endmodule