`timescale 1ns / 1ps

module tb_adder4();
    reg i_cin;
    reg [3:0] i_a, i_b;
    wire [3:0] o_sum;
    wire o_cout;


    adder4 u_adder4_0(
        .a(i_a),
        .b(i_b),
        .cin(i_cin),
        .sum(o_sum),
        .cout(o_cout)
    );

    initial begin
        #00 i_a = 4'b0000; i_b = 4'b0000; i_cin = 1'b0;
        #10 i_a = 4'b0001; i_b = 4'b0000; i_cin = 1'b0;
        #10 i_a = 4'b0001; i_b = 4'b0000; i_cin = 1'b0;
        #10 i_a = 4'b0010; i_b = 4'b0000; i_cin = 1'b0;
        #10 i_a = 4'b0100; i_b = 4'b0000; i_cin = 1'b0;
        #10 i_a = 4'b1000; i_b = 4'b0000; i_cin = 1'b0;
        #10 i_a = 4'b1111; i_b = 4'b0000; i_cin = 1'b1;
        #10 i_a = 4'b0000; i_b = 4'b0001; i_cin = 1'b0;
        #10 i_a = 4'b0000; i_b = 4'b0010; i_cin = 1'b0;
        #10 i_a = 4'b0000; i_b = 4'b0100; i_cin = 1'b0;
        #10 i_a = 4'b0000; i_b = 4'b1000; i_cin = 1'b0;
        #10 i_a = 4'b0000; i_b = 4'b1111; i_cin = 1'b1;
        #10 i_a = 4'b1111; i_b = 4'b1111; i_cin = 1'b0;
        #10 $finish;
    end
endmodule
