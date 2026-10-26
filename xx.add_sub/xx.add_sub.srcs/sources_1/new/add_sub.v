`timescale 1ns / 1ps

module add_sub(a, b, sel, result, cout);
    input [3:0] a, b;
    input sel;

    output [3:0] result;
    output cout;

    assign {cout, result} = sel ? a[3:0] + b[3:0] : a[3:0] + ~b[3:0] + 4'b1;
endmodule

