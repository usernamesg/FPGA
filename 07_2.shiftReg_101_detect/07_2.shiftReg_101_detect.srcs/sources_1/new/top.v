`timescale 1ns / 1ps

module top (
    input clk,
    input reset,
    input btnU,
    input btnD,
    output [15:0] led
);

    wire clean_U, clean_D;

    debouncer db_U (
        .clk(clk),
        .reset(reset),
        .noisy_btn(btnU),
        .clean_btn(clean_U)
    );

    debouncer db_D (
        .clk(clk),
        .reset(reset),
        .noisy_btn(btnD),
        .clean_btn(clean_D)
    );

    shiftReg_101 u_shift (
        .clk(clk),
        .reset(reset),
        .btnU(clean_U),
        .btnD(clean_D),
        .led(led)
    );

endmodule
