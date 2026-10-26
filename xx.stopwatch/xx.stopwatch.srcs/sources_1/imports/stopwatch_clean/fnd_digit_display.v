`timescale 1ns / 1ps

module fnd_digit_display(
    input [1:0] sel,
    input [3:0] digit_1,
    input [3:0] digit_10,
    input [3:0] digit_100,
    input [3:0] digit_1000,
    input animation,
    input [2:0] anim_step,
    input dot_on,
    output reg [3:0] an,
    output reg [7:0] seg
);
    reg [3:0] digit;
    always @(*) begin
        case (sel)
            2'b00: begin an = 4'b1110; digit = digit_1;    end
            2'b01: begin an = 4'b1101; digit = digit_10;   end
            2'b10: begin an = 4'b1011; digit = digit_100;  end
            2'b11: begin an = 4'b0111; digit = digit_1000; end
            default: begin an = 4'b1111; digit = 0; end
        endcase

        // seg[7] = DP, seg[6:0] = gfedcba; active low on Basys3.
        if (animation) begin
            // 4-digit perimeter rotation, 150ms per step (active-low):
            //   Step 0: top    = a on all four digits       "----"
            //   Step 1: right  = b+c on AN0 (rightmost)     "   |"
            //   Step 2: bottom = d on all four digits      "____"
            //   Step 3: left   = e+f on AN3 (leftmost)      "|   "
            // DP remains OFF for all animation steps.
            case (anim_step)
                3'd0: seg = 8'b1111_1110; // a, all four digits
                3'd1: seg = (sel == 2'b00)
                               ? 8'b1111_1001 // b+c, rightmost digit
                               : 8'b1111_1111; // others OFF
                3'd2: seg = 8'b1111_0111; // d, all four digits
                3'd3: seg = (sel == 2'b11)
                               ? 8'b1100_1111 // e+f, leftmost digit
                               : 8'b1111_1111; // others OFF
                default: seg = 8'b1111_1111;
            endcase
        end else begin
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
            // M.SS.T: both separators blink together (AN3 and AN1).
            // T = 100ms display digit.
            // On Basys3 DP is active-low, seg[7]=0 lights it.
            if ((sel == 2'b11 || sel == 2'b01) && dot_on)
                seg[7] = 1'b0;
        end
    end
endmodule
