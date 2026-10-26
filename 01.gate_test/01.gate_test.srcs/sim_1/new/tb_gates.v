`timescale 1ns / 1ps

module tb_gates();
    reg i_a;    //1bit 저장 메모리
    reg i_b;
    wire [5:0] o_led;

    gates u_gates( //u_gates라는 이름으로 gates 모듈을 인스턴스화
        .sw({i_a, i_b}),
        .led(o_led)
    );


    // a b
    // 0 0
    // 0 1
    // 1 0
    // 1 1
    initial begin
        #00 i_a = 1'b0; i_b = 1'b0;
        #20 i_a = 1'b0; i_b = 1'b1;
        #20 i_a = 1'b1; i_b = 1'b0;
        #20 i_a = 1'b1; i_b = 1'b1;
        #20 $stop;
    end

endmodule

// module tb_gates();
//     reg i_a;    //1bit 저장 메모리
//     reg i_b;
//     wire [5:0] o_led;

//     gates u_gates( //u_gates라는 이름으로 gates 모듈을 인스턴스화
//         .a(i_a),
//         .b(i_b),
//         .led(o_led)
//     );


//     // a b
//     // 0 0
//     // 0 1
//     // 1 0
//     // 1 1
//     initial begin
//         #00 i_a = 1'b0; i_b = 1'b0;
//         #20 i_a = 1'b0; i_b = 1'b1;
//         #20 i_a = 1'b1; i_b = 1'b0;
//         #20 i_a = 1'b1; i_b = 1'b1;
//         #20 $stop;
//     end

// endmodule
