`timescale 1ns / 1ps

module fnd_digit_display(
    input [1:0] sel,
    input [3:0] digit_1,
    input [3:0] digit_10,
    input [3:0] digit_100,
    input [3:0] digit_1000,
    output reg [3:0] an,
    output reg [7:0] seg
    );

    reg [3:0] digit;

    always @(*) begin
        case (sel)
            2'b00: begin
                an = 4'b1110;
                digit = digit_1;
            end
            2'b01: begin
                an = 4'b1101;
                digit = digit_10;
            end
            2'b10: begin
                an = 4'b1011;
                digit = digit_100;
            end
            2'b11: begin
                an = 4'b0111;
                digit = digit_1000;
            end
            default: begin
                an = 4'b1111;
                digit = 0;
            end
        endcase

        case (digit)
            4'd0: seg = 8'hC0;
            4'd1: seg = 8'hF9;
            4'd2: seg = 8'hA4;
            4'd3: seg = 8'hB0;
            4'd4: seg = 8'h99;
            4'd5: seg = 8'h92;
            4'd6: seg = 8'h82;
            4'd7: seg = 8'hF8;
            4'd8: seg = 8'h80;
            4'd9: seg = 8'h90;
            default: seg = 8'hFF;
        endcase
    end

endmodule
