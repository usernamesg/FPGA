`timescale 1ns / 1ps

module fnd_digit_select(
    input clk,
    input reset,
    input tick,
    output reg [1:0] sel
    );
    
    always @(posedge clk or posedge reset) begin
        if (reset)
            sel <= 0;
        else if (tick)
            sel <= sel + 1;
    end
endmodule
