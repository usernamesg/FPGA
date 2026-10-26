`timescale 1ns / 1ps

module adder4(
    input [3:0] a,
    input [3:0] b,
    input cin,
    output [3:0] sum,
    output cout
    );

    wire w_cout1, w_cout2, w_cout3;
    full_adder u_full_adder1(
        .a(a[0]),
        .b(b[0]),
        .cin(cin),
        .sum(sum[0]),
        .cout(w_cout1)
    );

    full_adder u_full_adder2(
        .a(a[1]),
        .b(b[1]),
        .cin(w_cout1),
        .sum(sum[1]),
        .cout(w_cout2)
    );

    full_adder u_full_adder3(
        .a(a[2]),
        .b(b[2]),
        .cin(w_cout2),
        .sum(sum[2]),
        .cout(w_cout3)
    );

    full_adder u_full_adder4(
        .a(a[3]),
        .b(b[3]),
        .cin(w_cout3),
        .sum(sum[3]),
        .cout(cout)
    );

endmodule
