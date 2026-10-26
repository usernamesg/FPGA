`timescale 1ns / 1ps

module rom(
    input [3:0] addr,
    input oe,
    output reg [7:0] dataout
);

    always @(*) begin
        if (oe) begin
            dataout = addr * 8'd17;
        end
        else begin
            dataout = 8'hZZ;
        end
    end

endmodule