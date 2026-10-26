`timescale 1ns / 1ps

module gates(
    input [1:0] sw,
    output [5:0] led
    );

    assign led[0] = sw[0] & sw[1]; // AND gate
    assign led[1] = sw[0] | sw[1]; // OR gate
    assign led[2] = ~(sw[0] & sw[1]); // NAND gate
    assign led[3] = ~(sw[0] | sw[1]); // NOR gate
    assign led[4] = sw[0] ^ sw[1]; // XOR gate
    assign led[5] = ~sw[0]; // NOT gate
endmodule


// module gates(
//     input wire a,
//     input  b, // wier를 생략해도 기본적으로 wire로 인식됨
//     output [5:0] led
//     );

//     assign led[0] = a & b; // AND gate
//     assign led[1] = a | b; // OR gate
//     assign led[2] = ~(a & b); // NAND gate
//     assign led[3] = ~(a | b); // NOR gate
//     assign led[4] = a ^ b; // XOR gate
//     assign led[5] = ~a; // NOT gate
// endmodule


// module gates(
//     input a,
//     input b,
//     output ld0,
//     output ld1,
//     output ld2,
//     output ld3,
//     output ld4,
//     output ld5
//     );

//     assign ld0 = a & b; // AND gate
//     assign ld1 = a | b; // OR gate
//     assign ld2 = ~(a & b); // NAND gate
//     assign ld3 = ~(a | b); // NOR gate
//     assign ld4 = a ^ b; // XOR gate
//     assign ld5 = ~a; // NOT gate
// endmodule
