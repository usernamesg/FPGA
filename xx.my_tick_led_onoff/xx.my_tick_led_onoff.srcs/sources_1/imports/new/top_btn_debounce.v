`timescale 1ns / 1ps

module top_btn_debounce(
    input clk,
    input reset,
    input btnC,
    output [1:0] led
    );

    wire w_clean_btn;
    wire w_tick_1ms;

    button_debounce u_button_debounce(
        .clk(clk),
        .reset(reset),
        .btn(btnC),
        .clean_btn(w_clean_btn)
    );

    led_toggle u_led_toggle(
        .clean_btn(w_clean_btn),
        .led(led[0])
    );

    tick_generator u_tick_generator(
        .clk(clk),
        .reset(reset),
        .tick_1ms(w_tick_1ms)
    );

    button_debounce_led_onoff_500ms u_button_debounce_led_onoff_500ms(
        .tick_1ms(w_tick_1ms),
        .led(led[1])
    );

endmodule