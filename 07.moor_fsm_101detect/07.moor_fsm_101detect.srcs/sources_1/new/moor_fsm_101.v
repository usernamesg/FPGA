`timescale 1ns / 1ps

module moor_fsm_101(
    input clk,
    input reset,
    input btn_press,
    input x,
    output y
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
        next_state = curr_state;   // !btn_press면 현재 상태 유지 
        if(btn_press) begin    // btnU나 btnD 둘중 1개를 누른 시점에만 상태 천이 
            case (curr_state)
            S0: next_state = x ? S1 : S0;
            S1: next_state = x ? S1 : S2;
            S2: next_state = x ? S3 : S0;
            S3: next_state = x ? S1 : S2;    // 중첩 허용
            default:  next_state = S0;   // 레치 방지 
            endcase
        end 
    end

    assign y = (curr_state == S3);
endmodule
