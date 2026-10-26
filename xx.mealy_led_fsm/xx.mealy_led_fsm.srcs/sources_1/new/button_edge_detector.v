`timescale 1ns / 1ps

module button_edge_detector (
    input clk,
    input reset,
    input clean_btn,
    output btn_pulse
);

    reg prev_clean_btn;

    always @(posedge clk or posedge reset) begin
        if (reset)
            prev_clean_btn <= 1'b0;
        else
            prev_clean_btn <= clean_btn;
    end

    assign btn_pulse = clean_btn && !prev_clean_btn;

endmodule