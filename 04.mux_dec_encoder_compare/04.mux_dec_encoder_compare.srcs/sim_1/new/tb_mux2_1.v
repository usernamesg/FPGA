`timescale 1ns / 1ps

module tb_mux2_1();
    reg a, b, sel;
    wire out;

    mux2_1 uut(
        .a(a),
        .b(b), 
        .sel(sel), 
        .out(out)
        );

    initial begin
        a=0; b=0; sel=0;

        $monitor("TIme=%0t | sel=%b | a=%b | b=%b | out=%b", $time, sel, a, b, out);

        #10; sel=0; a=1; b=0;
        #10; sel=0; a=0; b=1;
        
        #10; sel=1; a=1; b=0;
        #10; sel=1; a=0; b=1;

        #10; sel=0; a=1; b=1;
        #10; sel=1; a=1; b=1;
        #10; $finish;
    end

endmodule
