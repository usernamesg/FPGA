`timescale 1ns / 1ps

module tb_mux4bit();
    reg [0:3] a, b;
    reg sel;
    wire [0:3] out;

    multi_bit_mux uut(
        .a(a),
        .b(b), 
        .sel(sel), 
        .out(out)
        );

    initial begin
        a=4'b0000; b=4'b0000; sel=0;

        $monitor("TIme=%0t | sel=%b | a=%b | b=%b | out=%b", $time, sel, a, b, out);

        #10; sel=0; a=4'b1111; b=4'b0000;
        #10; sel=0; a=4'b0000; b=4'b1111;
        
        #10; sel=1; a=4'b1111; b=4'b0000;
        #10; sel=1; a=4'b0000; b=4'b1111;

        #10; sel=0; a=4'b1111; b=4'b1111;
        #10; sel=1; a=4'b1111; b=4'b1111;

        #10; $finish;
    end
endmodule
