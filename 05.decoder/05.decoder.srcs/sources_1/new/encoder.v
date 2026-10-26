`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/14 15:39:59
// Design Name: 
// Module Name: encoder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module encoder(
    input [3:0] a,
    output [1:0] led
    );

    reg [1:0] r_led;

    always @(*) begin
        if(a == 4'b1000) r_led = 2'b11;
        else if(a == 4'b0100) r_led = 2'b10;
        else if(a == 4'b0010) r_led = 2'b01;
        else if(a == 4'b0001) r_led = 2'b00;
        else r_led = 2'b00; // Default case when no input is active
    end

    assign led = r_led;
endmodule
