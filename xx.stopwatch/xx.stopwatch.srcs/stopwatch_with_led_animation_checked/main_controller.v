`timescale 1ns / 1ps

// Stopwatch shown on the four built-in Basys3 digits as M.SS.D
// M = minutes (0..9), SS = seconds (00..59), D = 10ms digit (0..9).
// D repeats every 100ms: only the units digit of centiseconds is shown.
// Two decimal points are driven by fnd_digit_display.v.
module main_controller #(
    parameter integer CLK_FREQ = 100_000_000
)(
    input clk,
    input reset,
    input [2:0] btn,      // {btnR, btnC, btnL}, debounced
    output [15:0] digits, // {minutes, seconds_tens, seconds_ones, 10ms_digit}
    output animation,
    output [2:0] anim_step,
    output dot_on,
    output [3:0] led // {ANIMATION, IDLE/RESET, PAUSED, RUNNING}; active-high
);
    localparam [1:0] IDLE=2'd0, RUNNING=2'd1, PAUSED=2'd2, ANIMATION=2'd3;
    localparam integer TICK10_COUNT = CLK_FREQ / 100;  // 10ms
    localparam integer HALF_SEC = CLK_FREQ / 2;       // 500ms
    localparam integer FIVE_SEC = 5 * CLK_FREQ;
    localparam integer ANIM_INTERVAL = 15 * CLK_FREQ / 100; // 150ms

    reg [1:0] state;
    reg [3:0] minutes, ten_ms_digit;
    reg [5:0] seconds;
    reg [6:0] centisec; // 00..99, keeps a true 1-second time base
    reg [31:0] tick10_count, idle_count, anim_count, blink_count;
    reg [2:0] prev_btn, anim_index;
    reg blink_state;

    // Fan-out optimization hint for the synchronous btnR reset EVENT.
    // btnR clears several counters/controls and can drive many D-path muxes.
    // Replication is synthesis-dependent; inspect Vivado reports to verify.
    // Do NOT apply MAX_FANOUT to the global clock or asynchronous reset input.
    (* max_fanout = 16 *) wire reset_pressed = btn[2] & ~prev_btn[2];
    wire [1:0] pressed = btn[1:0] & ~prev_btn[1:0];
    wire [3:0] sec_tens = seconds / 10;
    wire [3:0] sec_ones = seconds % 10;

    assign digits = {minutes, sec_tens, sec_ones, ten_ms_digit};
    // Status LEDs: one-hot encoding of the four FSM states.
    // LED0=RUNNING, LED1=PAUSED, LED2=IDLE/RESET, LED3=ANIMATION.
    assign led = { (state == ANIMATION), (state == IDLE),
                   (state == PAUSED), (state == RUNNING) };
    assign animation = (state == ANIMATION);
    assign anim_step = anim_index;
    assign dot_on = blink_state && !animation; // blink only the FIRST dot

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            minutes <= 0; seconds <= 0;
            centisec <= 0; ten_ms_digit <= 0;
            tick10_count <= 0; idle_count <= 0;
            anim_count <= 0; anim_index <= 0;
            blink_count <= 0; blink_state <= 1'b1;
            prev_btn <= 0;
        end else begin
            prev_btn <= btn;

            // Dot between M and SS: on 500ms / off 500ms.
            if (blink_count == HALF_SEC-1) begin
                blink_count <= 0;
                blink_state <= ~blink_state;
            end else begin
                blink_count <= blink_count + 1'b1;
            end

            // One button press has priority over idle timeout and animation.
            // Priority among buttons: Reset > Pause > Start.
            if (reset_pressed) begin  // btnR: reset stopwatch
                state <= IDLE;
                minutes <= 0; seconds <= 0;
                centisec <= 0; ten_ms_digit <= 0;
                tick10_count <= 0; idle_count <= 0;
                anim_count <= 0; anim_index <= 0;
            end else if (pressed[1]) begin  // btnC: pause / exit animation
                if (state == RUNNING || state == ANIMATION)
                    state <= PAUSED;
                idle_count <= 0;
                anim_count <= 0; anim_index <= 0;
            end else if (pressed[0]) begin  // btnL: start / resume
                if (!(minutes == 9 && seconds == 59 && centisec == 99))
                    state <= RUNNING;
                else if (state == ANIMATION)
                    state <= PAUSED;
                idle_count <= 0;
                anim_count <= 0; anim_index <= 0;
            end else begin
                case (state)
                    IDLE: begin
                        idle_count <= 0;
                        tick10_count <= 0;
                    end
                    RUNNING: begin
                        idle_count <= 0;
                        if (tick10_count == TICK10_COUNT-1) begin
                            tick10_count <= 0;
                            if (centisec == 99) begin
                                if (seconds == 59) begin
                                    if (minutes == 9) begin
                                        // Maximum real time 9m 59s 990ms reached.
                                        // Hold last displayed digit and stop.
                                        state <= PAUSED;
                                    end else begin
                                        minutes <= minutes + 1'b1;
                                        seconds <= 0;
                                        centisec <= 0;
                                        ten_ms_digit <= 0;
                                    end
                                end else begin
                                    seconds <= seconds + 1'b1;
                                    centisec <= 0;
                                    ten_ms_digit <= 0;
                                end
                            end else begin
                                centisec <= centisec + 1'b1;
                                ten_ms_digit <= (ten_ms_digit == 9)
                                                   ? 0 : ten_ms_digit + 1'b1;
                            end
                        end else begin
                            tick10_count <= tick10_count + 1'b1;
                        end
                    end
                    PAUSED: begin
                        if (idle_count == FIVE_SEC-1) begin
                            idle_count <= 0;
                            anim_count <= 0; anim_index <= 0;
                            state <= ANIMATION;
                        end else begin
                            idle_count <= idle_count + 1'b1;
                        end
                    end
                    ANIMATION: begin
                        if (anim_count == ANIM_INTERVAL-1) begin
                            anim_count <= 0;
                            anim_index <= (anim_index == 3)
                                           ? 0 : anim_index + 1'b1;
                        end else begin
                            anim_count <= anim_count + 1'b1;
                        end
                    end
                    default: state <= IDLE;
                endcase
            end
        end
    end
endmodule
