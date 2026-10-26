`timescale 1ns / 1ps

module tb_mealy_fsm();
reg clk;
    reg reset;
    reg btnC;

    wire [4:0] led;

    integer error_count;

    // DUT
    mealy_led_fsm dut (
        .clk(clk),
        .reset(reset),
        .btnC(btnC),
        .led(led)
    );

    // 100MHz Clock
    initial clk = 1'b0;
    always #5 clk = ~clk;


    // FSM 상태 확인
    task check_state;
        input integer num;
        input [1:0] expected_state;
        input expected_dir;
        input [4:0] expected_led;

        begin
            #1;

            $display("-------------------------------------------");
            $display("STEP  : %0d", num);
            $display("STATE : S%02d", dut.curr_state);
            $display("DIR   : %b", dut.dir);
            $display("LED   : %05b", led);

            if ((dut.curr_state !== expected_state) ||
                (dut.dir !== expected_dir) ||
                (led !== expected_led)) begin

                $display("RESULT: FAIL");
                $display("EXPECTED STATE: %0d", expected_state);
                $display("EXPECTED DIR  : %b", expected_dir);
                $display("EXPECTED LED  : %05b", expected_led);

                error_count = error_count + 1;
            end
            else begin
                $display("RESULT: PASS");
            end
        end
    endtask


    // 버튼 1회 입력: 총 100ms
    task press_btnC;
        input integer num;
        input [1:0] expected_state;
        input expected_dir;
        input [4:0] expected_led;

        begin
            $display("");
            $display(">>> BUTTON PRESS %0d", num);

            // 버튼 누름
            @(negedge clk);
            btnC = 1'b1;

            #50;  

            // 버튼을 누른 후 FSM 검사
            check_state(
                num,
                expected_state,
                expected_dir,
                expected_led
            );

            // 버튼 해제
            @(negedge clk);
            btnC = 1'b0;

            #50;

            // 해제 후 상태가 유지되는지 확인
            check_state(
                num,
                expected_state,
                expected_dir,
                expected_led
            );
        end
    endtask


    // LED가 실제로 변경되는 순간 출력
    always @(led) begin
        if (reset === 1'b0)
            $display(
                "[%0t ns] LED CHANGED = %05b",
                $time, led
            );
    end

    // 버튼 에지 검출 순간 확인
    always @(posedge dut.btn_release) begin
        $display(
            "[%0t ns] BUTTON EVENT DETECTED",
            $time
        );
    end


    // 테스트 시작
    initial begin
        reset = 1'b1;
        btnC = 1'b0;

        #50;
        reset = 1'b0;

        // 1회
        btnC = 1;
        #50;
        btnC = 0;
        #50;

        // 2회
        btnC = 1;
        #50;
        btnC = 0;
        #50;

        // 3회
        btnC = 1;
        #50;
        btnC = 0;
        #50;

        // S03에서 Reset 확인
        reset = 1;
        #50;
        reset = 0;

        // 4회
        btnC = 1;
        #50;
        btnC = 0;
        #50;

        // 5회
        btnC = 1;
        #50;
        btnC = 0;
        #50;

        // 6회
        btnC = 1;
        #50;
        btnC = 0;
        #50;

        // 7회
        btnC = 1;
        #50;
        btnC = 0;
        #50;

        reset = 1'b1;
        #50;
        $finish;
    end
endmodule