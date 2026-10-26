`timescale 1ns / 1ps

module button_debounce(
    input clk,
    input reset,
    input btn,
    output clean_btn
    );

    wire w_oclk;
    wire w_Q1;
    wire w_Q2;

    clock_80Hz u_clock_80Hz(
        .clk(clk),
        .reset(reset),
        .oclk(w_oclk)
    );

    D_FF u1_DFF(
        .oclk(w_oclk),
        .reset(reset),
        .D(btn),
        .Q(w_Q1)
    );

    D_FF u2_DFF(
        .oclk(w_oclk),
        .reset(reset),
        .D(w_Q1),
        .Q(w_Q2)
    );

    assign w_Q2_bar = ~w_Q2;
    assign clean_btn = w_Q1 & w_Q2_bar;
endmodule