`timescale 1ns / 1ps

module my_up_counter #(
    parameter CLK_FREQ = 100_000_000,
    parameter OUT_FREQ = 100    
)(
    input clk,
    input reset,
    input btnU,
    input btnD,
    output [15:0] led
    );

    localparam DIV_COUNT = CLK_FREQ / (OUT_FREQ * 2);
    localparam COUNT_WIDTH = $clog2(DIV_COUNT);

    reg [COUNT_WIDTH-1:0] r_counter;
    reg clk_100hz;

    wire [1:0] clean_btn;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_counter <= 0;
            clk_100hz <= 0;
        end
        else if (r_counter == DIV_COUNT - 1) begin
            r_counter <= 0;
            clk_100hz <= ~clk_100hz;
        end
        else begin
            r_counter <= r_counter + 1;
        end
    end

    button_debounce u_btn_debounce0(
    .clk(clk_100hz),
    .reset(reset),
    .btn(btnU),
    .clean_btn(clean_btn[0])
    );

    button_debounce u_btn_debounce1(
    .clk(clk_100hz),
    .reset(reset),
    .btn(btnD),
    .clean_btn(clean_btn[1])
    );

    up_counter u_up_counter(
        .clk(clk_100hz),
        .reset(reset),
        .clean_btn(clean_btn),
        .led(led)
    );

endmodule
