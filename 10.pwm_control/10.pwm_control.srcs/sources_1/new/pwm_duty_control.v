`timescale 1ns / 1ps

module pwm_duty_control(
    input clk,
    input reset,
    input [2:0] clean_btn,
    output [3:0] duty_cycle,
    output pwm_out,
    output pwm_out_led
    );

    reg [3:0] r_pwm_counter = 4;
    reg [3:0] r_duty_cycle = 4'd5;  //default 50%
    reg r_prev_duty_inc = 1'b0; 
    reg r_prev_duty_dec = 1'b0;

    wire w_duty_inc = (clean_btn[0] && !r_prev_duty_inc);
    wire w_duty_dec = (clean_btn[1] && !r_prev_duty_dec);

    //duty cycle 제어 (btnU btnD)
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            r_duty_cycle <= 4'd5;
            r_prev_duty_inc <= 0;
            r_prev_duty_dec <=0;
        end else begin
            r_prev_duty_inc <= clean_btn[0];
            r_prev_duty_dec <= clean_btn[1];
            if(w_duty_inc && r_duty_cycle <= 4'd9)
                r_duty_cycle <= r_duty_cycle + 1;
            if(w_duty_dec && r_duty_cycle >= 4'd1)
                r_duty_cycle <= r_duty_cycle - 1;
        end 
    end

    //
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            r_pwm_counter <= 0;
        end else begin
            if (r_pwm_counter >= 4'd9)
                r_pwm_counter <= 0;
            else r_pwm_counter <= r_pwm_counter +1;
        end
    end

    assign pwm_out = (r_pwm_counter < r_duty_cycle )? 1'b1 : 1'b0;
    assign pwm_out_led = pwm_out;
    assign duty_cycle = r_duty_cycle;
endmodule
