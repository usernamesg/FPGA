`timescale 1ns / 1ps

module tb_led_fsm();

    reg clk;
    reg reset;
    reg [2:0] btn;
    reg [7:0] sw;

    wire [7:0] seg;
    wire [3:0] an;
    wire [15:0] led;

    reg [15:0] prev_led;

    integer i;
    // DUT
    top uut (
        .clk(clk),
        .reset(reset),
        .btn(btn),
        .sw(sw),
        .seg(seg),
        .an(an),
        .led(led)
    );



    // 100MHz clock
    initial clk = 0;
    always #5 clk = ~clk;

    // btn[0] 한 번 누르기
    task press_btn0;
        begin
            // 버튼 누름
            btn[0] = 1'b1;
            #30_000_000;   // 30ms 유지 (debounce 통과용)

            // 버튼 뗌
            btn[0] = 1'b0;
            #30_000_000;   // 30ms 유지
        end
    endtask

    // 상태를 보기 좋게 출력
    task show_status;
        begin
            $display(
                "TIME=%0t | btn=%b | LED=%016b | LED[4:0]=%05b",
                $time,
                btn,
                led,
                led[4:0]
            );
        end
    endtask

    initial begin
        // 초기값
        reset = 1'b1;
        btn   = 3'b000;
        sw    = 8'h00;

        #100;
        reset = 1'b0;
        #100;

        $display("==============================================");
        $display(" FSM LED TEST START (btn[0] only, 7 presses) ");
        $display("==============================================");

        show_status;   // 초기 상태 출력

        // btn[0] 7번 반복
        for (i = 0; i < 7; i = i + 1) begin
            $display("----------------------------------------------");
            $display("PRESS %0d", i+1);
            press_btn0;
            show_status;
        end

        $display("==============================================");
        $display(" TEST END ");
        $display("==============================================");

        $finish;
    end

endmodule