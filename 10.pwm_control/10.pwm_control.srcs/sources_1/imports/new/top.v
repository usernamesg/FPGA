`timescale 1ns / 1ps

module top(
    input clk,
    input reset,
    input [2:0] btn,
    input [1:0] sw,
    output pwm_out,
    output pwm_out_led,
    output [3:0] an,
    output [7:0] seg,
    output [1:0] in1_in2,
    output pwm_out_scope
    );

    wire [2:0] w_clean_btn;
    wire [3:0] w_duty_cycle;
    wire w_tick;

    btn_debouncer u_btn_debouncer(
        .clk(clk),
        .reset(reset),
        .noisy_btn(btn),  // raw noisy button input
        .clean_btn(w_clean_btn)
    );

    pwm_duty_control u_pwm_duty_control(
        .clk(clk),
        .reset(reset),
        .clean_btn(w_clean_btn),
        .duty_cycle(w_duty_cycle),
        .pwm_out(pwm_out),
        .pwm_out_led(pwm_out_led)
    );
    
    tick_generator u_tick_generator(
        .clk(clk),
        .reset(reset),
        .tick(w_tick)
    );

    fnd_controller u_fnd_controller(
        .clk(clk),
        .reset(reset),
        .tick(w_tick),
        .motor_direction(sw),
        .in_data(w_duty_cycle),
        .an(an),
        .seg(seg)
    );

    assign in1_in2 = sw; 
    assign pwm_out_scope = pwm_out;
endmodule

