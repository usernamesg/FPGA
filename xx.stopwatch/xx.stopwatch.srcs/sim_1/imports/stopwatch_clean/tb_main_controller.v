`timescale 1ns / 1ps
// Add as Simulation Source only (NOT Design Source).
// Reduced CLK_FREQ so 1 simulated second = 1000 clocks.
module tb_main_controller;
    reg clk = 0;
    reg reset = 1;
    reg [2:0] btn = 0;
    wire [15:0] digits;
    wire animation, dot_on;
    wire [3:0] led;
    wire [2:0] anim_step;

    always #5 clk = ~clk;

    main_controller #(.CLK_FREQ(1000)) dut(
        .clk(clk), .reset(reset), .btn(btn),
        .digits(digits), .animation(animation),
        .anim_step(anim_step), .dot_on(dot_on), .led(led)
    );

    task run_cycles;
        input integer n;
        integer i;
        begin
            for (i = 0; i < n; i = i + 1) @(negedge clk);
        end
    endtask

    task press_button;
        input integer bit_index;
        begin
            @(negedge clk); btn[bit_index] = 1'b1;
            run_cycles(2);
            btn[bit_index] = 1'b0;
            run_cycles(2);
        end
    endtask

    task expect_digits;
        input [15:0] expected;
        begin
            if (digits !== expected) begin
                $display("FAIL: expected digits %h, got %h", expected, digits);
                $fatal(1);
            end
        end
    endtask

    task expect_led;
        input [3:0] expected;
        begin
            if (led !== expected) begin
                $display("FAIL: expected LEDs %b, got %b", expected, led);
                $fatal(1);
            end
        end
    endtask

    initial begin
        run_cycles(2);
        reset = 0;
        run_cycles(2);
        expect_digits(16'h0000);
        expect_led(4'b0100); // IDLE/RESET
        if (animation) $fatal(1, "Animation should be OFF initially");

        press_button(0);  // L: start
        if (dut.state !== 2'd1) $fatal(1, "Start did not enter RUNNING");
        expect_led(4'b0001); // RUNNING
        run_cycles(10);
        expect_digits(16'h0001); // 10ms
        run_cycles(90);
        expect_digits(16'h0000); // 100ms; last digit wraps to 0
        run_cycles(900);
        expect_digits(16'h0010); // 1 second, 0 subdigit

        press_button(1); // C: pause
        if (dut.state !== 2'd2) $fatal(1, "Pause did not enter PAUSED");
        expect_led(4'b0010); // PAUSED
        run_cycles(200);
        expect_digits(16'h0010);
        if (animation) $fatal(1, "Animation started before 5 seconds");
        run_cycles(4800);
        if (!animation) $fatal(1, "Animation did not begin after 5 seconds");
        expect_led(4'b1000); // ANIMATION
        if (anim_step !== 3'd0) $fatal(1, "Animation should start at top");
        run_cycles(150);
        if (anim_step !== 3'd1) $fatal(1, "Animation step 1 (right) missing");
        run_cycles(150);
        if (anim_step !== 3'd2) $fatal(1, "Animation step 2 (bottom) missing");
        run_cycles(150);
        if (anim_step !== 3'd3) $fatal(1, "Animation step 3 (left) missing");
        run_cycles(150);
        if (anim_step !== 3'd0) $fatal(1, "Animation failed to loop to top");

        press_button(0); // L: exit animation and resume
        if (animation || dut.state !== 2'd1)
            $fatal(1, "Start did not exit ANIMATION");
        expect_led(4'b0001);
        run_cycles(10);
        expect_digits(16'h0011);

        // Check 0:59:99 -> 1:00:00 rollover.
        @(negedge clk);
        dut.minutes = 0; dut.seconds = 59;
        dut.centisec = 99; dut.ten_ms_digit = 9;
        dut.tick10_count = 0;
        run_cycles(10);
        expect_digits(16'h1000);

        // Check maximum 9:59:99 stays on the display and pauses.
        @(negedge clk);
        dut.minutes = 9; dut.seconds = 59;
        dut.centisec = 99; dut.ten_ms_digit = 9;
        dut.tick10_count = 0;
        run_cycles(10);
        expect_digits(16'h9599);
        if (dut.state !== 2'd2) $fatal(1, "Maximum time did not pause");
        expect_led(4'b0010);

        press_button(2); // R: reset
        expect_digits(16'h0000);
        if (dut.state !== 2'd0) $fatal(1, "Reset did not enter IDLE");
        expect_led(4'b0100);
        $display("PASS: stopwatch FSM/time counter smoke tests");
        $finish;
    end
endmodule
