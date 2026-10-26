`timescale 1ns / 1ps

module tb_7bit_full_adder();
    reg  i_cin;
    reg  [6:0] i_a;
    reg  [6:0] i_b;
    wire [6:0] o_sum;
    wire o_cout;

    full_adder_7bit u_full_adder_7bit(
        .cin(i_cin),
        .a(i_a),
        .b(i_b),
        .sum(o_sum),
        .cout(o_cout)
    );


    initial begin
        #00 i_a = 7'b0000000; i_b = 7'b0000000; i_cin = 1'b0;
        #10 i_a = 7'b0000001; i_b = 7'b0000000; i_cin = 1'b0;
        #10 i_a = 7'b0000010; i_b = 7'b0000000; i_cin = 1'b0;
        #10 i_a = 7'b0000100; i_b = 7'b0000000; i_cin = 1'b0;
        #10 i_a = 7'b0001000; i_b = 7'b0000111; i_cin = 1'b0;
        #10 i_a = 7'b0010000; i_b = 7'b0000000; i_cin = 1'b0;
        #10 i_a = 7'b0100000; i_b = 7'b0000000; i_cin = 1'b0;
        #10 i_a = 7'b1000000; i_b = 7'b0000000; i_cin = 1'b0;
        #10 i_a = 7'b1111111; i_b = 7'b0000000; i_cin = 1'b1;
        #10 i_a = 7'b0000000; i_b = 7'b0000001; i_cin = 1'b0;
        #10 i_a = 7'b0000000; i_b = 7'b0000010; i_cin = 1'b0;
        #10 i_a = 7'b0000000; i_b = 7'b0000100; i_cin = 1'b0;
        #10 i_a = 7'b0000000; i_b = 7'b0001000; i_cin = 1'b0;
        #10 i_a = 7'b0000000; i_b = 7'b0010000; i_cin = 1'b0;
        #10 i_a = 7'b0000000; i_b = 7'b0100000; i_cin = 1'b0;
        #10 i_a = 7'b0000000; i_b = 7'b1000000; i_cin = 1'b0;
        #10 i_a = 7'b0000000; i_b = 7'b1111111; i_cin = 1'b1;
        #10 i_a = 7'b1111111; i_b = 7'b1111111; i_cin = 1'b0;
        #10 $finish;
    end

endmodule