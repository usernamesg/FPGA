`timescale 1ns / 1ps

module tb_add_sub();
    reg [3:0] r_a, r_b;
    reg r_sel;
    wire [3:0] w_result;
    wire w_cout;

    add_sub u_sdd_sub (
        .a(r_a),
        .b(r_b),
        .sel(r_sel),
        .result(w_result),
        .cout(w_cout)
    );

    initial begin
        r_a = 4'b0000;
        r_b = 4'b0000;
        r_sel = 1'b0;

        #10 r_a = 4'b0011; r_b = 4'b0001; r_sel = 1'b1; // 3 + 1
        #10 r_a = 4'b0011; r_b = 4'b0001; r_sel = 1'b0; // 3 - 1
        #10 r_a = 4'b0010; r_b = 4'b0100; r_sel = 1'b1; // 2 + 4
        #10 r_a = 4'b0010; r_b = 4'b0100; r_sel = 1'b0; // 2 - 4

        #10 r_a = 4'b1111; r_b = 4'b0001; r_sel = 1'b1; // 15 + 1
        #10 r_a = 4'b0001; r_b = 4'b1111; r_sel = 1'b0; // 1 - 15

        #10 $finish;
    end

endmodule
