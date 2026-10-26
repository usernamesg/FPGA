`timescale 1ns / 1ps

module moor_fsm_101(
    input clk,
    input reset,
    input btnC,
    output led
    );

    localparam [1:0] S0 = 2'b00,
                     S1 = 2'b01,
                     S2 = 2'b10,
                     S3 = 2'b11;

    reg [1:0] curr_state, next_state;

    always @(posedge clk, posedge reset) begin
        if(reset) curr_state <= 0;
        else curr_state <= next_state;
    end

    always @(*) begin
        
        case (curr_state)
        S0: next_state = btnC ? S1 : S0;
        S1: next_state = btnC ? S1 : S2;
        S2: next_state = btnC ? S3 : S0;
        S3: next_state = btnC ? S1 : S2;
        default: next_state = S0;
        endcase
    end

    assign led = (curr_state == S3);
endmodule
