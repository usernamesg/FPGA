`timescale 1ns / 1ps


module encoder(
    input [3:0] a,
    output [1:0] led
    );

    reg [1:0] r_led;

    always @(*) begin
        if(a >= 4'b1000) r_led = 2'b11;
        else if(a >= 4'b0100) r_led = 2'b10;
        else if(a >= 4'b0010) r_led = 2'b01;
        else if(a == 4'b0001) r_led = 2'b00;
        else if(a < 4'b0001) r_led = 2'bxx; // Default case when no input is active
        else r_led = 2'b00; // Default case when no input is active
    end

    assign led = r_led;
endmodule
