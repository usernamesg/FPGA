`timescale 1ns / 1ps

module multi_bit_mux(a[0:3], b[0:3], sel, out[0:3]);
    input [0:3] a, b;
    input sel;
    output [0:3] out;

    reg [0:3] out;

    always @(sel or a or b) begin
        case(sel)
            1'b1: out = a;
            1'b0: out = b;
        endcase
    end
    
endmodule
