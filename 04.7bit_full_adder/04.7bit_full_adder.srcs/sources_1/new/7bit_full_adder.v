`timescale 1ns / 1ps

module full_adder_7bit(
    input [6:0] a,
    input [6:0] b,
    input cin,
    output [6:0] sum,
    output cout
    );

    wire cout0, cout1, cout2, cout3, cout4, cout5, cout6;
    full_adder u_full_adder0(
        .a(a[0]),
        .b(b[0]),
        .cin(cin),
        .sum(sum[0]),
        .cout(cout0)
    );
    full_adder u_full_adder1(
        .a(a[1]),
        .b(b[1]),
        .cin(cout0),
        .sum(sum[1]),
        .cout(cout1)
    );
    full_adder u_full_adder2(
        .a(a[2]),
        .b(b[2]),
        .cin(cout1),
        .sum(sum[2]),
        .cout(cout2)
    );
    full_adder u_full_adder3(
        .a(a[3]),
        .b(b[3]),
        .cin(cout2),
        .sum(sum[3]),
        .cout(cout3)
    );
    full_adder u_full_adder4(
        .a(a[4]),
        .b(b[4]),
        .cin(cout3),
        .sum(sum[4]),
        .cout(cout4)
    );
    full_adder u_full_adder5(
        .a(a[5]),
        .b(b[5]),
        .cin(cout4),
        .sum(sum[5]),
        .cout(cout5)
    );
    full_adder u_full_adder6(
        .a(a[6]),
        .b(b[6]),
        .cin(cout5),
        .sum(sum[6]),
        .cout(cout)
    );

endmodule
