`timescale 1ns / 1ps

module D_FF(
    input oclk,
    input reset,
    input D,
    output reg Q
    );

    always @(posedge oclk , posedge reset) begin
        if (reset) begin
            Q <= 0;
        end else begin
            Q <= D;
        end
    end
endmodule
