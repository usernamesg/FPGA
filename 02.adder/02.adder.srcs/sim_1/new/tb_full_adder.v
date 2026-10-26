`timescale 1ns / 1ps

module tb_full_adder;
    reg i_cin;
    reg [4:0] i_a, i_b;
    wire [4:0] o_sum, isum;
    wire o_cout;

    full_adder u_full_adder(
        .cin(i_cin),
        .a(i_a),
        .b(i_b),
        .sum(o_sum),
        .cout(o_cout)
    );

    //a b cin
    //0 0 0
    //0 0 1
    //0 1 0
    //0 1 1
    //1 0 0
    //1 0 1
    //1 1 0
    //1 1 1
    initial begin
        #00 i_a = 1'b0; i_b = 1'b0; i_cin = 1'b0;
        #10 i_a = 1'b0; i_b = 1'b0; i_cin = 1'b0;
        #10 i_a = 1'b0; i_b = 1'b1; i_cin = 1'b0;
        #10 i_a = 1'b0; i_b = 1'b1; i_cin = 1'b1;
        #10 i_a = 1'b1; i_b = 1'b0; i_cin = 1'b0;
        #10 i_a = 1'b1; i_b = 1'b0; i_cin = 1'b1;
        #10 i_a = 1'b1; i_b = 1'b1; i_cin = 1'b0;
        #10 i_a = 1'b1; i_b = 1'b1; i_cin = 1'b1;
        #10 $finish;
    end

endmodule
