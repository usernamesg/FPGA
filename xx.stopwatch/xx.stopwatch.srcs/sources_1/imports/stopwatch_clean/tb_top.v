`timescale 1ns / 1ps
// Integrated testbench for the EXISTING top.v (no RTL changes required).
// Simulation scaling: 1000 clk cycles = 1 simulated second.
// For simulation ONLY: use defparam to override submodule parameters.
module tb_top;
    reg clk = 1'b0;
    reg reset = 1'b1;
    reg [2:0] btn = 3'b000;
    wire [7:0] seg;
    wire [3:0] an, led;
    integer checks = 0;
    integer k;
    reg [7:0] expected_seg;
    reg [3:0] expected_an;
    reg [3:0] expected_digit;

    always #5 clk = ~clk;

    top dut (
        .clk(clk), .reset(reset), .btn(btn),
        .seg(seg), .an(an), .led(led)
    );

    // Override timing parameters in the existing instances.
    // WARNING: these defparams are for testbench simulation, not synthesis.
    defparam dut.u_main.CLK_FREQ = 1000;
    defparam dut.u_tick.INPUT_FREQ = 1000;
    defparam dut.u_tick.TICK_Hz = 100;
    defparam dut.u_debounce.u_btnL_debouncer.DEBOUNCE_LIMIT = 3;
    defparam dut.u_debounce.u_btnC_debouncer.DEBOUNCE_LIMIT = 3;
    defparam dut.u_debounce.u_btnR_debouncer.DEBOUNCE_LIMIT = 3;

    task cycles(input integer n);
        integer i;
        begin
            for (i=0; i<n; i=i+1) @(negedge clk);
        end
    endtask

    task press(input integer button_number);
        begin
            @(negedge clk);
            btn[button_number] = 1'b1;
            cycles(12); // Sync(2FF)+debounce(3cycles)+edge detect margin
            btn[button_number] = 1'b0;
            cycles(12);
        end
    endtask

    task check_led(input [3:0] want, input [255:0] msg);
        begin
            if (led !== want) begin
                $display("FAIL LED %0s expected %b got %b at %0t", msg, want, led, $time);
                $fatal(1);
            end
            checks = checks + 1;
        end
    endtask

    task check_digits(input [15:0] want, input [255:0] msg);
        begin
            if (dut.u_main.digits !== want) begin
                $display("FAIL DIGITS %0s expected %h got %h at %0t", msg, want, dut.u_main.digits, $time);
                $fatal(1);
            end
            checks = checks + 1;
        end
    endtask

    function [7:0] decode(input [3:0] d);
        begin
            case (d)
                0: decode=8'hC0; 1: decode=8'hF9; 2: decode=8'hA4;
                3: decode=8'hB0; 4: decode=8'h99; 5: decode=8'h92;
                6: decode=8'h82; 7: decode=8'hF8; 8: decode=8'h80;
                9: decode=8'h90; default: decode=8'hFF;
            endcase
        end
    endfunction

    // Check the actual physical multiplexed pins against the current sel.
    task check_fnd_pins;
        reg [1:0] s;
        begin
            #1; // allow combinational logic to settle after negedge
            s = dut.u_fnd.u_select.sel;
            case (s)
                2'd0: begin expected_an=4'b1110; expected_digit=dut.u_main.digits[3:0]; end
                2'd1: begin expected_an=4'b1101; expected_digit=dut.u_main.digits[7:4]; end
                2'd2: begin expected_an=4'b1011; expected_digit=dut.u_main.digits[11:8]; end
                2'd3: begin expected_an=4'b0111; expected_digit=dut.u_main.digits[15:12]; end
            endcase
            if (dut.u_main.animation) begin
                case (dut.u_main.anim_step)
                    0: expected_seg=8'hFE; // all 4 top bars (a)
                    1: expected_seg=(s==0) ? 8'hF9 : 8'hFF; // right b+c
                    2: expected_seg=8'hF7; // all 4 bottom bars (d)
                    3: expected_seg=(s==3) ? 8'hCF : 8'hFF; // left e+f
                    default: expected_seg=8'hFF;
                endcase
            end else begin
                expected_seg=decode(expected_digit);
                if ((s==3 || s==1) && dut.u_main.dot_on)
                    expected_seg[7]=1'b0;
            end
            if (an !== expected_an || seg !== expected_seg) begin
                $display("FAIL FND: sel=%d anim=%b step=%d an=%b/%b seg=%h/%h time=%0t",
                         s, dut.u_main.animation, dut.u_main.anim_step,
                         an, expected_an, seg, expected_seg, $time);
                $fatal(1);
            end
            checks = checks + 1;
        end
    endtask

    // Exercise 4 mux positions; check dot + segment on each scan selection.
    task sample_scans(input integer n);
        integer j;
        begin
            for (j=0; j<n; j=j+1) begin
                @(negedge clk);
                check_fnd_pins;
            end
        end
    endtask

    initial begin : run_test
        reg [15:0] saved;
        reg first_dot;
        $display("[TB] top-level integrated stopwatch test begins");
        $dumpfile("tb_top.vcd");
        $dumpvars(0,tb_top);
        cycles(3);
        reset=0;
        cycles(4);
        check_led(4'b0100, "boot IDLE");
        check_digits(16'h0000, "boot time");
        sample_scans(42);

        // Stopwatch start and 10ms progression (10 scaled cycles / centisecond)
        press(0); // btnL
        check_led(4'b0001, "start RUNNING");
        cycles(110); // >= 10 centiseconds, < 1 second
        if (dut.u_main.seconds !== 0 || dut.u_main.centisec < 10) begin
            $display("FAIL 10ms increment seconds=%0d centisec=%0d",dut.u_main.seconds,dut.u_main.centisec);
            $fatal(1);
        end
        checks=checks+1;
        check_digits(16'h0001, "AN0 100ms digit equals 1 after 110ms");
        sample_scans(42);

        // Dot should toggle every 500 simulated cycles, regardless of run state.
        first_dot=dut.u_main.dot_on;
        cycles(510);
        if (dut.u_main.dot_on === first_dot) begin
            $display("FAIL dot blink did not toggle in 510 cycles"); $fatal(1);
        end
        checks=checks+1;
        cycles(510);
        // AN0 should be 0..9 tenths, not the fast 10ms units digit.
        if (dut.u_main.digits[3:0] !== dut.u_main.centisec / 10)
            $fatal(1, "AN0 tenths display mismatch");
        checks=checks+1;
        sample_scans(42);

        // Pause must hold the time and then enter animation after 5 sec.
        press(1); // btnC
        check_led(4'b0010,"paused");
        saved=dut.u_main.digits;
        cycles(100);
        check_digits(saved,"pause holds time");
        if (dut.u_main.animation) $fatal(1,"animation entered too early");
        cycles(4905); // > 5000 paused clocks from pause entry
        check_led(4'b1000,"5-second idle animation");
        check_digits(saved,"animation preserves time");

        // Check all 4 animation phases, actual 7-seg/an pins, 4-digit scan.
        for (k=0; k<4; k=k+1) begin
            if (dut.u_main.anim_step !== k) begin
                $display("FAIL animation step expected %0d got %0d",k,dut.u_main.anim_step);
                $fatal(1);
            end
            sample_scans(42);
            if (k<3) cycles(108); // sum 150 clocks per animation phase
        end
        cycles(108);
        if (dut.u_main.anim_step !== 0) $fatal(1,"animation did not wrap 3->0");
        checks=checks+1;

        // btnC during animation exits and restarts 5s idle timer.
        press(1);
        check_led(4'b0010,"btnC exits animation");
        cycles(100);
        if (dut.u_main.animation) $fatal(1,"animation re-entered early");
        checks=checks+1;
        // btnL during pause resumes.
        press(0);
        check_led(4'b0001,"resume after pause");
        // btnR stops and resets time.
        press(2);
        check_led(4'b0100,"reset IDLE");
        check_digits(16'h0000,"reset time");
        sample_scans(42);

        // btnR should also terminate animation.
        press(0); press(1);
        cycles(5005);
        check_led(4'b1000,"animation again");
        press(2);
        check_led(4'b0100,"btnR exits animation");
        check_digits(16'h0000,"reset from animation");

        // btnL should terminate animation and resume.
        press(0); press(1);
        cycles(5005);
        check_led(4'b1000,"animation before start");
        press(0);
        check_led(4'b0001,"btnL exits animation");

        // Directed boundary tests (hierarchical preload in TB only):
        // 0:59.99 -> 1:00.00 (BCD display 0599 -> 1000)
        @(negedge clk);
        dut.u_main.minutes=0;
        dut.u_main.seconds=59;
        dut.u_main.centisec=99;
                dut.u_main.tick10_count=9;
        cycles(2);
        check_digits(16'h1000,"second/minute rollover");
        check_led(4'b0001,"keep RUNNING after rollover");
        // 9:59.99 -> PAUSED at maximum, without incrementing values
        @(negedge clk);
        dut.u_main.minutes=9;
        dut.u_main.seconds=59;
        dut.u_main.centisec=99;
                dut.u_main.tick10_count=9;
        cycles(2);
        check_digits(16'h9599,"maximum displayed time");
        check_led(4'b0010,"maximum reached PAUSED");

        $display("PASS tb_top: %0d checks", checks);
        $finish;
    end

    initial begin
        #500000; // 50,000 cycles at 10 ns: watchdog
        $fatal(1,"TIMEOUT tb_top");
    end
endmodule
