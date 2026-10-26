`timescale 1ns / 1ps

module up_counter (
    input clk,
    input reset,
    input [1:0] clean_btn,
    output reg [15:0] led
    );

    reg state = 1'b0;
    reg [1:0] prev_btn;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            led <= 16'h0000;
            state <= 1'b0;
            prev_btn = 2'b00;
        end else begin            
            prev_btn <= clean_btn;

            if(state == 1'b0) begin
                if (clean_btn[0] && !prev_btn[0]) begin
                    state <= ~state;
                end else begin
                    led <= led + 1;
                end
            end else begin
                if(clean_btn[1] && !prev_btn[1]) begin
                    led <= 16'h0000;
                end else if(clean_btn[0] && !prev_btn[0]) begin
                    state <= ~state;
                end
            end
        end
    end
endmodule