`timescale 1ns / 1ps

// Combinational pattern check for the 4-digit perimeter animation.
module tb_animation_display;
    reg [1:0] sel;
    reg [3:0] digit_1, digit_10, digit_100, digit_1000;
    reg animation;
    reg [2:0] anim_step;
    reg dot_on;
    wire [3:0] an;
    wire [7:0] seg;
    integer s, d;
    reg [7:0] expected;
    reg [3:0] expected_an;

    fnd_digit_display dut(
        .sel(sel),
        .digit_1(digit_1), .digit_10(digit_10),
        .digit_100(digit_100), .digit_1000(digit_1000),
        .animation(animation), .anim_step(anim_step), .dot_on(dot_on),
        .an(an), .seg(seg)
    );

    initial begin
        digit_1 = 4'd4; digit_10 = 4'd3;
        digit_100 = 4'd2; digit_1000 = 4'd1;
        animation = 1'b1;
        anim_step = 0;
        dot_on = 1'b1;
        for (s = 0; s < 4; s = s + 1) begin
            for (d = 0; d < 4; d = d + 1) begin
                anim_step = s;
                sel = d;
                case (d)
                    0: expected_an = 4'b1110;
                    1: expected_an = 4'b1101;
                    2: expected_an = 4'b1011;
                    3: expected_an = 4'b0111;
                endcase
                case (s)
                    0: expected = 8'hFE;                     // top
                    1: expected = d == 0 ? 8'hF9 : 8'hFF;   // right
                    2: expected = 8'hF7;                     // bottom
                    3: expected = d == 3 ? 8'hCF : 8'hFF;   // left
                endcase
                #1;
                if (seg !== expected || an !== expected_an) begin
                    $display("FAIL step=%0d digit=%0d expected=%h/%b actual=%h/%b",
                             s, d, expected, expected_an, seg, an);
                    $fatal(1);
                end
            end
        end
        // Numeric mode and dot placement were not changed.
        animation = 0;
        dot_on = 1;
        sel = 3;
        #1;
        if (seg !== 8'h79) $fatal(1, "Minute dot should be ON");
        sel = 1;
        #1;
        if (seg !== 8'h30) $fatal(1, "Seconds dot should be ON");
        $display("PASS: 4-digit perimeter animation / dot smoke tests");
        $finish;
    end
endmodule
