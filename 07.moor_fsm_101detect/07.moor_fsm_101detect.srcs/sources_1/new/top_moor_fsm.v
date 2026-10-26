`timescale 1ns / 1ps

module top_moor_fsm(
    input clk,
    input reset,
    input btnU,    // 눌렀다 떼면 1 입력
    input btnD,    // 눌렀다 떼면 0 입력
    output led
    );

    wire w_clean_u, w_clean_d;
    wire w_btn_press, w_x; 

    debouncer u1_debouncer(
        .clk(clk),
        .reset(reset),
        .noisy_btn(btnU),
        .clean_btn(w_clean_u)
    );

    debouncer u2_debouncer(
        .clk(clk),
        .reset(reset),
        .noisy_btn(btnD),
        .clean_btn(w_clean_d)
    );

    moor_fsm_101 u_moor_fsm_101(
        .clk(clk),
        .reset(reset),
        .btn_press(w_btn_press),
        .x(w_x),
        .y(led)
    );

    btn_U1D0_check u_btn_U1D0_check(
        .clk(clk),
        .reset(reset),   // 비동기 reset, active-high
        .clean_btnU(w_clean_u),
        .clean_btnD(w_clean_d),
        .btn_press(w_btn_press),
        .x(w_x)
    );

endmodule
