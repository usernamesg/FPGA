`timescale 1ns / 1ps

// 시뮬레이션 시간 단위: 1ns
// 시뮬레이션 시간 정밀도: 1ps
// 실제 FPGA의 클럭 주파수를 설정하는 명령은 아님

// ===========================================================
// main_controller : 스톱워치 메인 제어 모듈
// ===========================================================
// 주요 기능
// 1. 시작, 일시정지, 초기화 버튼 처리
// 2. 10ms 단위로 스톱워치 시간 계산
// 3. 7-Segment에 표시할 4자리 숫자 출력
// 4. 일시정지 5초 후 애니메이션 실행
// 5. 현재 동작 상태를 LED로 출력
// 6. 소수점 점멸 신호 생성
//
// 표시 형식 : M.SS.T
// M : 분 (0~9)
// SS: 초 (00~59)
// T : 100ms 단위 (0~9)
//
// 내부에서는 10ms 단위까지 시간을 저장함
// ===========================================================
module main_controller #(
    parameter integer CLK_FREQ = 100_000_000
)(
    input clk,
    input reset,
    // btn[2] : btnR (초기화)
    // btn[1] : btnC (일시정지)
    // btn[0] : btnL (시작/재시작)
    // 디바운싱 처리된 입력이라고 가정
    input [2:0] btn,
    output [15:0] digits, // {minutes, seconds_tens, seconds_ones, tenths}
    output animation,
    output [2:0] anim_step,
    output dot_on,
    output [3:0] led // {ANIMATION, IDLE/RESET, PAUSED, RUNNING}; active-high
);

    // =======================================================
    // 1. FSM 상태 정의
    // =======================================================
    // FSM(Finite State Machine) : 유한 상태 머신
    // 현재 상태에 따라 서로 다른 동작을 수행함
    //
    // 2비트로 총 4개의 상태 표현 가능
    localparam [1:0] IDLE=2'd0, RUNNING=2'd1, PAUSED=2'd2, ANIMATION=2'd3;

    // =======================================================
    // 2. 시간 계산에 필요한 상수
    // =======================================================
    // 10ms = 0.01초
    // 100MHz 기준 : 1,000,000 클럭
    localparam integer TICK10_COUNT = CLK_FREQ / 100;  // 10ms
    // 500ms = 0.5초
    // 100MHz 기준 : 50,000,000 클럭
    // 소수점 LED 점멸에 사용
    localparam integer HALF_SEC = CLK_FREQ / 2;       // 500ms
    // 5초
    // 100MHz 기준 : 500,000,000 클럭
    // 일시정지 후 애니메이션 진입 시간
    localparam integer FIVE_SEC = 5 * CLK_FREQ;
    
    // 150ms = 0.15초
    // 100MHz 기준 : 15,000,000 클럭
    // 애니메이션 프레임 전환 간격
    localparam integer ANIM_INTERVAL = 15 * CLK_FREQ / 100; // 150ms

    reg [1:0] state;
    reg [3:0] minutes;
    reg [5:0] seconds;
    reg [6:0] centisec; // 00..99, keeps a true 1-second time base
    reg [31:0] tick10_count, idle_count, anim_count, blink_count;
    reg [2:0] prev_btn, anim_index;
    reg blink_state;

    // =======================================================
    // 4. 버튼 상승 엣지 검출
    // =======================================================
    // 버튼이 0에서 1로 변경되는 순간만 감지
    //
    // 현재 버튼 = 1
    // 이전 버튼 = 0
    // => 새로운 버튼 입력으로 판단
    //
    // 버튼을 계속 누르고 있어도 한 번만 동작하도록 함

    // btnR 초기화 버튼
    // max_fanout은 합성 최적화를 위한 힌트
    // 실제 적용 여부는 Vivado 합성 결과에 따라 달라짐
    (* max_fanout = 16 *) wire reset_pressed = btn[2] & ~prev_btn[2];
    // btnC와 btnL의 상승 엣지를 동시에 계산
    // pressed[1] : btnC
    // pressed[0] : btnL
    wire [1:0] pressed = btn[1:0] & ~prev_btn[1:0];

    // =======================================================
    // 5. 7-Segment 표시 데이터 생성
    // =======================================================

    // 초를 십의 자리와 일의 자리로 분리
    // 예: seconds = 37
    // sec_tens = 3
    // sec_ones = 7
    wire [3:0] sec_tens = seconds / 10;
    wire [3:0] sec_ones = seconds % 10;
    wire [3:0] tenths = centisec / 10;  // 0..9, changes every 100ms

    assign digits = {minutes, sec_tens, sec_ones, tenths};
    // =======================================================
    // 6. FSM 상태에 따른 출력 신호
    // =======================================================
    // 현재 상태에 해당하는 LED 하나만 켜짐
    assign led = { (state == ANIMATION), (state == IDLE),
                   (state == PAUSED), (state == RUNNING) };
    assign animation = (state == ANIMATION);
    assign anim_step = anim_index;
    // 500ms 간격 점멸 신호
    // 애니메이션 중에는 소수점 OFF
    // 실제 소수점 위치는 외부 표시 모듈에서 결정
    assign dot_on = blink_state && !animation;


    // =======================================================
    // 7. 메인 순차 논리 블록
    // =======================================================
    // posedge clk   : 클럭 상승 엣지에서 동작
    // posedge reset : reset 상승 엣지에서도 동작
    //
    // reset은 비동기 리셋
    // btnR은 클럭에 동기화된 버튼 이벤트로 처리
    //
    // <= : non-blocking assignment
    // 클럭 기반 순차회로에서 사용하는 대입 방식
    always @(posedge clk or posedge reset) begin
        // ---------------------------------------------------
        // 7-1. 외부 리셋 신호 처리
        // ---------------------------------------------------
        if (reset) begin
            state <= IDLE;
            minutes <= 0; seconds <= 0;
            centisec <= 0;
            tick10_count <= 0; idle_count <= 0;
            anim_count <= 0; anim_index <= 0;
            blink_count <= 0; blink_state <= 1'b1;
            prev_btn <= 0;
        end else begin
            // ------------------------------------------------
            // 7-2. 현재 버튼 상태 저장
            // ------------------------------------------------
            // 다음 클럭에서 이전 버튼 상태로 사용
            prev_btn <= btn;

            // ------------------------------------------------
            // 7-3. 소수점 점멸 처리
            // ------------------------------------------------
            // 500ms가 지날 때마다 blink_state 반전
            // ON 500ms -> OFF 500ms -> 반복
            if (blink_count == HALF_SEC-1) begin
                blink_count <= 0;
                blink_state <= ~blink_state;
            end else begin
                blink_count <= blink_count + 1'b1;
            end

            // =================================================
            // 8. 버튼 입력 처리
            // =================================================
            // 버튼 우선순위
            // 1순위 : btnR (초기화)
            // 2순위 : btnC (일시정지)
            // 3순위 : btnL (시작)
            //
            // 버튼이 처리된 클럭에서는
            // 아래 FSM case문을 실행하지 않음
            // =================================================

            // ------------------------------------------------
            // 8-1. 초기화 버튼 (btnR)
            // ------------------------------------------------
            if (reset_pressed) begin  // btnR: reset stopwatch
                state <= IDLE;
                minutes <= 0; seconds <= 0;
                centisec <= 0;
                tick10_count <= 0; idle_count <= 0;
                anim_count <= 0; anim_index <= 0;
                // 주의:
                // btnR은 blink_count와 blink_state를
                // 초기화하지 않음


            // ------------------------------------------------
            // 8-2. 일시정지 버튼 (btnC)
            // ------------------------------------------------
            end else if (pressed[1]) begin  // btnC: pause / exit animation
                if (state == RUNNING || state == ANIMATION)
                    state <= PAUSED;
                idle_count <= 0;
                anim_count <= 0; anim_index <= 0;

            // ------------------------------------------------
            // 8-3. 시작/재시작 버튼 (btnL)
            // ------------------------------------------------
            end else if (pressed[0]) begin  // btnL: start / resume
                if (!(minutes == 9 && seconds == 59 && centisec == 99))
                    state <= RUNNING;
                else if (state == ANIMATION)
                    state <= PAUSED;
                idle_count <= 0;
                anim_count <= 0; anim_index <= 0;

            // ------------------------------------------------
            // 8-4. 새 버튼 입력이 없다면 FSM 실행
            // ------------------------------------------------   
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
                                    end
                                end else begin
                                    seconds <= seconds + 1'b1;
                                    centisec <= 0;
                                end
                            end else begin
                                centisec <= centisec + 1'b1;
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
