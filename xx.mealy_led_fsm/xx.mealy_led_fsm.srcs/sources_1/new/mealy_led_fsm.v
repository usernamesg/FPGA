`timescale 1ns / 1ps

module mealy_led_fsm (
    input clk,
    input reset,
    input btnC,
    output [4:0] led
);

    wire clean_btn;
    wire btn_pulse;

    wire [1:0] curr_state;
    wire [1:0] next_state;
    wire dir;

    // 1. 버튼 디바운싱
    button_debounce u_button_debounce (
        .clk(clk),
        .reset(reset),
        .btn(btnC),
        .clean_btn(clean_btn)
    );

    // 2. 버튼 에지 검출
    button_edge_detector u_edge_detector (
        .clk(clk),
        .reset(reset),
        .clean_btn(clean_btn),
        .btn_pulse(btn_pulse)
    );

    // 3. 현재 상태 레지스터
    fsm_state_register u_state_register (
        .clk(clk),
        .reset(reset),
        .btn_pulse(btn_pulse),
        .next_state(next_state),
        .curr_state(curr_state),
        .dir(dir)
    );

    // 4. 다음 상태 로직
    fsm_next_state u_next_state (
        .curr_state(curr_state),
        .dir(dir),
        .btn_pulse(btn_pulse),
        .next_state(next_state)
    );

    // 5. LED 출력 로직
    fsm_led_output u_led_output (
        .curr_state(curr_state),
        .dir(dir),
        .led(led)
    );

endmodule