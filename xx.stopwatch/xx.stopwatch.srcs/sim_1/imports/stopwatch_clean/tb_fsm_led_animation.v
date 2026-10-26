`timescale 1ns / 1ps
// 1000 simulated clk edges = 1 second; 150 edges = 150ms; 5000 = 5s.
module tb_fsm_led_animation;
    reg clk = 0;
    reg reset = 1;
    reg [2:0] btn = 3'b000;
    wire [15:0] digits;
    wire animation, dot_on;
    wire [2:0] anim_step;
    wire [3:0] led;
    always #5 clk = ~clk;
    main_controller #(.CLK_FREQ(1000)) dut (
        .clk(clk), .reset(reset), .btn(btn), .digits(digits),
        .animation(animation), .anim_step(anim_step),
        .dot_on(dot_on), .led(led)
    );
    task cycles(input integer n);
        integer i;
        begin for (i = 0; i < n; i = i + 1) @(negedge clk); end
    endtask
    task press(input integer k);
        begin
            @(negedge clk); btn[k] = 1'b1;
            cycles(2);
            btn[k] = 1'b0;
            cycles(2);
        end
    endtask
    task check(input [3:0] expected_led);
        begin
            if (led !== expected_led) begin
                $display("FAIL: expected LED %b, got %b", expected_led, led);
                $fatal(1);
            end
        end
    endtask
    initial begin
        cycles(2); reset = 0; cycles(3);
        check(4'b0100); // IDLE
        press(0); check(4'b0001); // RUNNING
        press(1); check(4'b0010); // PAUSED
        cycles(5001);
        if (!animation || anim_step !== 0) $fatal(1, "Idle animation entry error");
        check(4'b1000);
        cycles(150); if (anim_step !== 1) $fatal(1, "right segment error");
        cycles(150); if (anim_step !== 2) $fatal(1, "bottom segment error");
        cycles(150); if (anim_step !== 3) $fatal(1, "left segment error");
        cycles(150); if (anim_step !== 0) $fatal(1, "top segment loop error");
        press(1); // Pause during animation exits animation, stay PAUSED
        if (animation) $fatal(1, "Pause did not exit animation");
        check(4'b0010);
        cycles(5001);
        if (!animation) $fatal(1, "Animation did not re-enter after pause");
        press(2); // Reset during animation -> IDLE
        if (animation || digits !== 16'h0000) $fatal(1, "Reset during animation error");
        check(4'b0100);
        press(0); check(4'b0001);
        press(1); check(4'b0010);
        cycles(5001); check(4'b1000);
        press(0); // Start during animation -> RUNNING
        if (animation) $fatal(1, "Start did not exit animation");
        check(4'b0001);
        $display("PASS: LED state outputs and animation FSM transitions");
        $finish;
    end
endmodule
