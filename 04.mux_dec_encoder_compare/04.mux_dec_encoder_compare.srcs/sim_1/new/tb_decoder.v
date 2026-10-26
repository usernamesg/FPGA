`timescale 1ns / 1ps

module tb_decoder();

    reg [1:0] r_a;
    wire [3:0] W_led;

    decoder u_decoder (
        .a(r_a),
        .led(W_led)
    );

    initial begin
        r_a = 2'b00;
        #10 r_a = 2'b01;
        #10 r_a = 2'b10;
        #10 r_a = 2'b11;
        #10;
        $finish;

    end
endmodule
