`timescale 1ns / 1ps

module fsm_next_state (
    input [1:0] curr_state,
    input dir,
    input btn_pulse,

    output reg [1:0] next_state
);

    localparam S00 = 2'd0,
               S01 = 2'd1,
               S02 = 2'd2,
               S03 = 2'd3;

    always @(*) begin
        next_state = curr_state;

        if (btn_pulse) begin
            case (curr_state)
                S00: next_state = S01;

                S01: next_state = dir ? S00 : S02;

                S02: next_state = dir ? S01 : S03;

                S03: next_state = S02;

                default: next_state = S00;
            endcase
        end
    end

endmodule

