`timescale 1ns / 1ps

module fnd_controller(
    input clk,
    input reset,
    input tick,
    input [13:0] in_data,
    output [3:0] an,
    output [7:0] seg
    );

    wire [1:0] sel;
    wire [3:0] digit_1;
    wire [3:0] digit_10;
    wire [3:0] digit_100;
    wire [3:0] digit_1000;

    fnd_digit_select u_fnd_digit_select(
        .clk(clk),
        .reset(reset),
        .tick(tick),
        .sel(sel)
    );

    bin2bcd4digit u_bin2bcd4digit(
        .in_data(in_data),
        .digit_1(digit_1),
        .digit_10(digit_10),
        .digit_100(digit_100),
        .digit_1000(digit_1000)
    );

    fnd_digit_display u_fnd_digit_display(
        .sel(sel),
        .digit_1(digit_1),
        .digit_10(digit_10),
        .digit_100(digit_100),
        .digit_1000(digit_1000),
        .an(an),
        .seg(seg)
    );
    
endmodule
