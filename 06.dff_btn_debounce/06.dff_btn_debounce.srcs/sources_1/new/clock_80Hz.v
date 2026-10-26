`timescale 1ns / 1ps

module clock_80Hz #(
    parameter DIV = 1_250_000
)(
    input clk,
    input reset,
    output reg oclk
    );

    reg[23:00] r_counter;

    always @(posedge clk , posedge reset) begin
        if (reset) begin
            r_counter <= 0;
            oclk <= 0;
        end else begin
            if ((r_counter ==DIV/2)-1)begin
                r_counter <= 0;
                oclk <= ~oclk;
            end else begin
                r_counter <= r_counter + 1;
            end
        end
    end

endmodule