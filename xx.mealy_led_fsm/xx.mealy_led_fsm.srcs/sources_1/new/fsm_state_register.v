`timescale 1ns / 1ps

module fsm_state_register (
    input clk,
    input reset,
    input btn_pulse,
    input [1:0] next_state,

    output reg [1:0] curr_state,
    output reg dir
);

    localparam S00 = 2'd0,
               S03 = 2'd3;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            curr_state <= S00;
            dir <= 1'b0;
        end
        else begin
            curr_state <= next_state;

            if (btn_pulse) begin
                if (curr_state == S03)
                    dir <= 1'b1;
                else if (curr_state == S00)
                    dir <= 1'b0;
            end
        end
    end

endmodule