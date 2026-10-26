`timescale 1ns / 1ps

module top_btn(
    input clk,
    input reset,
    input btnU,
    input btnD,
    input sel,   //sw15
    output clean_btn,
    output [1:0] led
    );

    wire tick;
    wire btn;

    tick_generator u_tick_generator(
        .clk(clk),
        .reset(reset),
        .tick_1ms(tick)
    );

    button_debounce u_button_debounce(
    .clk(tick),
    .reset(reset),
    .btn(btn),
    .clean_btn(clean_btn)
    );

    mux2_1 u_mux2_1(
        .a(btnU),
        .b(btnD),
        .sel(sel),
        .out(btn)
    );

    led_toggle u_led_toggle(
    .btn(clean_btn),
    .reset(reset),
    .led(led[1])
    );

    assign led[0] = clean_btn;

    
endmodule
