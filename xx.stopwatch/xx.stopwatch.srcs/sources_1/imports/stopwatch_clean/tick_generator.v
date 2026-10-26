`timescale 1ns / 1ps

module tick_generator(
    input clk,
    input reset,
    output reg tick
    );

    parameter INPUT_FREQ = 100_000_000;
    parameter TICK_Hz = 1000;
    parameter TICK_COUNT = INPUT_FREQ / TICK_Hz;

    reg [$clog2(TICK_COUNT)-1:0] r_tick_coutner = 0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_tick_coutner <= 0;
            tick <= 0;
        end
        else begin
            if (r_tick_coutner == TICK_COUNT - 1) begin
                r_tick_coutner <= 0;
                tick <= 1;
            end
            else begin
                r_tick_coutner <= r_tick_coutner + 1;
                tick <= 0;
            end
        end
    end
endmodule
