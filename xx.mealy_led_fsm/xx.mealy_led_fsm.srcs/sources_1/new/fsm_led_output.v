`timescale 1ns / 1ps

module fsm_led_output (
    input [1:0] curr_state,
    input dir,

    output reg [4:0] led
);

    localparam S00 = 2'd0,
               S01 = 2'd1,
               S02 = 2'd2,
               S03 = 2'd3;

    always @(*) begin
        case (curr_state)
            S00: led = {dir, 4'b0001};
            S01: led = {dir, 4'b0010};
            S02: led = {dir, 4'b0100};
            S03: led = {dir, 4'b1000};

            default: led = 5'b00001;
        endcase
    end

endmodule
