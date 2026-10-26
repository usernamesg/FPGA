`timescale 1ns / 1ps

module button_debounce(
    input clk,
    input reset,
    input btn,
    output reg clean_btn
    );

    reg [7:0] shift_buf;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            shift_buf <=8'b0;
            clean_btn <= 1'b0;
        end
        else begin
             shift_buf <= {shift_buf[6:0], btn};

            if (shift_buf == 8'hff) begin
                clean_btn <= 1'b1;     
            end else if (shift_buf == 8'h00) begin
                clean_btn <= 1'b0;
            end
        end
    end
endmodule