`timescale 1ns / 1ps
module top(
    input clk, reset,
    input [2:0] btn, // btn[0]=btnL, btn[1]=btnC, btn[2]=btnR
    output [7:0] seg, // seg[7]=DP (active-low)
    output [3:0] an,
    output [3:0] led // active-high LED0~LED3: START/STOP/RESET/ANIM
);
    wire [2:0] clean_btn;
    wire [15:0] digits;
    wire scan_tick, animation, dot_on;
    wire [2:0] anim_step;

    btn_deboucer u_debounce(
        .clk(clk), .reset(reset), .noisy_btn(btn), .clean_btn(clean_btn)
    );
    main_controller u_main(
        .clk(clk), .reset(reset), .btn(clean_btn),
        .digits(digits), .animation(animation),
        .anim_step(anim_step), .dot_on(dot_on), .led(led)
    );
    tick_generator u_tick(.clk(clk), .reset(reset), .tick(scan_tick));
    fnd_controller u_fnd(
        .clk(clk), .reset(reset), .tick(scan_tick), .digits(digits),
        .animation(animation), .anim_step(anim_step), .dot_on(dot_on),
        .an(an), .seg(seg)
    );
endmodule
