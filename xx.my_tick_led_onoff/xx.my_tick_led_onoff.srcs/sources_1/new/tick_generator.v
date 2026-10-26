`timescale 1ns / 1ps

module tick_generator(
    input clk,
    input reset,
    output reg tick_1ms
    );

    reg[23:00] r_counter;

    always @(posedge clk , posedge reset) begin
        if (reset) begin
            tick_1ms <= 0;
            r_counter <= 0;
        end else begin
            if (r_counter == 100_000 - 1)begin
                r_counter <= 0;
                tick_1ms <= 1'b1;
            end else begin
                r_counter <= r_counter + 1;
                tick_1ms <= 1'b0;
            end
        end
    end
endmodule
