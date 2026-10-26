`timescale 1ns / 1ps

module button_debounce_led_onoff_500ms(
    input tick_1ms,
    output reg led = 1'b0
    );

    reg [8:0] r_counter;

    always @(posedge tick_1ms) begin
        if (r_counter == 500 - 1) begin
            r_counter <= 0;
            led <= ~led;
        end else begin
            r_counter <= r_counter + 1;
        end
    end

endmodule
