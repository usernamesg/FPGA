`timescale 1ns / 1ps

module top_moor_fsm(
    input clk,
    input reset,
    input btnC,
    output led
    );

    wire w_clean_btn;

    debouncer u_btn_debouncer(
        .clk(clk),
        .reset(reset),
        .noisy_btn(btnC),
        .clean_btn(w_clean_btn)
    );

    moor_fsm_101 u_moor_fsm_101(
        .clk(),
        .reset(),
        .btnC(w_clean_btn),
        .led(led)
    );
endmodule
