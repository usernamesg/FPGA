`timescale 1ns / 1ps

module tb_moor_fsm_101();
    reg clk=0;
    reg reset=0;
    reg x=0;     // 입력
    wire y;      // 출력 

    reg r_error=1'b0;

    moor_fsm_101 u_moor_fsm_101(
        .clk(clk),
        .reset(reset),
        .x(x),
        .y(y)
    );

    always #5 clk = ~clk;   // 100MHz clk 생성 

    // 상승에지 전에 출력 y가 변하는지를 검사 하는것 (moore상태)
    //         후에 출력 y가 기대하는 값인지 검사 (1clock지연)
    task send_data(input a, input expect_val);
     begin
        x=a; #1;  // gate 동작 
        @(posedge clk); #1;
        if (y !== expect_val) begin   // y 가 기대값이 아닌 다른 값이면 DUT에 logic error가 발생 되었다.
            r_error=1'b1;   // error detect flag
            $display("FAIL t=%0t x=%b y=%b expect_val=%b", $time, a, y, expect_val);
        end 
     end
    endtask
    
    // 10101101
    initial begin
        #100 reset=1;
        #100 reset=0;
        send_data(1, 0);
        send_data(0, 0);
        send_data(1, 1);    // 101 -- 다음 에지후 y=1(S3)
        send_data(0, 0);  send_data(1, 1);   // 10101 : 중첩 검증
        // 101
        send_data(1, 0); send_data(0, 0); send_data(1, 1);   // 1101 -- 검출 
        if (r_error == 0)  $display("PASS moor fsm_101");
        else  $display("FAIL moor fsm_101");
        $finish;
    end 

endmodule
