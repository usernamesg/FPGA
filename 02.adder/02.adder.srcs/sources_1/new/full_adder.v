`timescale 1ns / 1ps

module full_adder(
    input cin, a, b,
    output sum, cout
    );

    wire w_sum1, w_cout1, w_cout2;
    half_adder u_half_adder1(
        .a(a),
        .b(b),
        .sum(w_sum1),
        .cout(w_cout1)
    );

    half_adder u_half_adder2(
        .a(w_sum1),
        .b(cin),
        .sum(sum),
        .cout(w_cout2)
    );
    
    assign cout = w_cout1 | w_cout2;
endmodule
