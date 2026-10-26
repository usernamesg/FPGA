`timescale 1ns / 1ps
module fnd_controller(
    input clk, reset, tick,
    input [15:0] digits,
    input animation,
    input [2:0] anim_step,
    input dot_on,
    output [3:0] an,
    output [7:0] seg
);
    wire [1:0] sel;
    fnd_digit_select u_select(.clk(clk), .reset(reset), .tick(tick), .sel(sel));
    fnd_digit_display u_display(
        .sel(sel), .digit_1(digits[3:0]), .digit_10(digits[7:4]),
        .digit_100(digits[11:8]), .digit_1000(digits[15:12]),
        .animation(animation), .anim_step(anim_step), .dot_on(dot_on),
        .an(an), .seg(seg)
    );
endmodule
