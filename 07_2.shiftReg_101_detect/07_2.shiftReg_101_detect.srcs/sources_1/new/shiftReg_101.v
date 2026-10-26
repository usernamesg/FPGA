`timescale 1ns / 1ps

module shiftReg_101 (
    input clk,
    input reset,
    input btnU,
    input btnD,
    output [15:0] led
);

    reg din;
    reg [6:0] shift_reg7;

    reg prev_U, prev_D;

    wire pulse_U = ~btnU & prev_U;
    wire pulse_D = ~btnD & prev_D;

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            din <= 0;
            shift_reg7 <= 0;
            prev_U <= 0;
            prev_D <= 0;
        end
        else begin
            prev_U <= btnU;
            prev_D <= btnD;

            if (pulse_U && !pulse_D) begin
                din <= 1'b1;
                shift_reg7 <= {shift_reg7[5:0], 1'b1};
            end
            else if (pulse_D && !pulse_U) begin
                din <= 1'b0;
                shift_reg7 <= {shift_reg7[5:0], 1'b0};
            end
        end
    end

    assign led[6:0] = shift_reg7;
    assign led[14:7] = 8'b0;
    assign led[15] = (shift_reg7 == 7'b1010111);

endmodule
