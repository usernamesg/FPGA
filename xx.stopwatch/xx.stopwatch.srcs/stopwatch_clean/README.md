# Basys3 stopwatch — M.SS.D + 4-digit perimeter animation

## 기존 설계 유지 사항
- Top: `top`; 100 MHz clk; buttons `btn[0]`=L(start), `btn[1]`=C(pause), `btn[2]`=R(reset).
- 4자리 FND: AN3=0~9분, AN2=초 십의 자리, AN1=초 일의 자리, AN0=10ms **한 자리**.
- DP AN3: 0.5초 ON/OFF, DP AN1: 상시 ON (숫자 표시 중에만).
- 내부 10ms 카운터는 00~99를 순환하고, AN0에는 1의 자리만 표시합니다.
  따라서 마지막 표시 4는 40/140/.../940ms를 구별하지 못합니다.
- IDLE / RUNNING / PAUSED / ANIMATION FSM, PAUSED 5초 후 애니메이션, 버튼 입력 시 종료/기능 수행.

## 이번 변경: 4자리 전체 테두리를 한 번에 회전
애니메이션은 각 자리에서 a,b,c,d,e,f가 회전하는 것이 아니라 다음 4개 패턴으로 순환합니다.

| 순서 | 표시 | 켜지는 세그먼트 | 시간 |
| --- | --- | --- | --- |
| 0 | `----` | 네 자리 모두 a | 150ms |
| 1 | `   |` | 맨 오른쪽 AN0의 b,c | 150ms |
| 2 | `____` | 네 자리 모두 d | 150ms |
| 3 | `|   ` | 맨 왼쪽 AN3의 e,f | 150ms |

전체 주기 600ms. 모든 애니메이션 패턴에서 DP OFF.

## 수정 파일 (기존 RTL 7개 중 2개만 변경)
- `main_controller.v`: 애니메이션 단계 순환 마지막 값을 `5`에서 `3`으로 수정 (0,1,2,3 반복).
- `fnd_digit_display.v`: 애니메이션 분기만 위 표의 4자리 테두리 패턴으로 변경.

그 외 `top.v`, `button_debounce10ms.v`, `tick_generator.v`, `fnd_controller.v`, `fnd_digit_select.v`는 변경하지 않았습니다.

## FPGA 타이밍·신호 품질 문제: 기존 코드에서 대응 여부
1. **Setup/Hold**: 플립플롭과 동기식 FSM, 100MHz `create_clock` XDC는 존재하지만, 충족 여부는 Vivado 구현 후 `report_timing_summary`의 setup/hold 및 경로 분석으로 검증해야 합니다. RTL 자체로 보장할 수 없습니다. `reset`의 비동기 해제 또한 recovery/removal 분석이 필요할 수 있습니다.
2. **Metastability**: `button_debounce10ms.v`의 `sync1 <= noisy_btn; sync2 <= sync1;` 2단 동기화가 버튼의 비동기 입력에 대해 위험을 낮춥니다. 완전히 제거하지는 못합니다. `(* ASYNC_REG = "TRUE" *)` 지정은 추가 개선 사항입니다.
3. **Glitch**: 10ms 디바운싱은 **버튼 채터링** 억제에 유효합니다. `tick_generator.v`와 `fnd_digit_select.v`에 등록된 `tick/sel`이 있지만, `fnd_digit_display.v`는 `always @(*)` 조합 출력이므로 물리적 FND 출력의 순간 글리치나 고스팅까지 방지하도록 설계되지는 않았습니다. 필요시 디스플레이 전환 구간에 전체 자리 OFF(blanking) 삽입이 권장됩니다.
4. **Fan-out**: 별도의 RTL fan-out 최적화, 버퍼링, register replication은 없습니다. 높은 부하가 타이밍 문제를 일으키는지는 합성 및 배치배선 후 fan-out/timing 리포트로 검증하고 필요시 구조 수정, 복제 및 물리적 최적화를 수행합니다.

## 시뮬레이션
- `tb_main_controller.v`: 기존 stopwatch 기능 기본 테스트(변경 없음).
- `tb_animation_display.v`: 추가한 4단계/4자리 FND 애니메이션 패턴과 DP 표시 테스트.

예시 (Icarus Verilog 설치 환경):

```
iverilog -g2012 -s tb_animation_display -o tb_anim.out fnd_digit_display.v tb_animation_display.v
vvp tb_anim.out
```

Vivado에서는 `top.v`를 Design Sources top으로 지정하고 `basys3_stopwatch.xdc`를 Constraints로 적용합니다. `tb_*.v`는 Simulation Sources에만 추가하세요.

이 환경에는 Verilog 컴파일러가 확인되지 않아 RTL 컴파일/시뮬레이션은 실행하지 못했습니다.


## Fan-out 제어 추가 (이번 변경)
- 수정 RTL: `main_controller.v` **1개만** 변경.
- `btnR`의 edge-detected 내부 이벤트 `reset_pressed`에 `(* max_fanout = 16 *)` 속성을 적용.
- 기존 `if (pressed[2])`를 `if (reset_pressed)`로 교체 (논리 동일).
- `clk`와 외부 `reset`은 변경하지 않음.
- Vivado가 실제로 driver 복제나 fan-out 개선을 수행하는지는 구현 결과에 달렸으며, 설계 규모상 복제가 필요 없을 수 있음. 성능 개선을 보장하지 않음.
- Vivado 구현 후 `fanout_reports.tcl`을 Tcl Console에서 실행하고, 적용 전후 `fanout_after.rpt`, `timing_after.rpt` 비교.
- `MAX_FANOUT`은 유효한 RTL 속성이지만 과다한 복제는 면적·지연 면에서 역효과를 낼 수 있음.


## 4개 LED 상태 표시 추가
- `led[0]` (U16): RUNNING = btnL로 시작/재개한 상태
- `led[1]` (E19): PAUSED = btnC 일시정지 상태
- `led[2]` (U19): IDLE = 별도 reset 또는 btnR 초기화 후 대기 (btnR 눌렀을 때 1회 펄스가 아니라 유지되는 상태)
- `led[3]` (V19): ANIMATION = 5초 일시정지 대기 후 회전 패턴 중
- ON=1, OFF=0, FSM의 state에서 직접 1-of-4 디코딩하므로 LED 한 개만 켜짐.
- 수정된 파일: `top.v`, `main_controller.v`, `basys3_stopwatch.xdc`.
- 4단계 회전 애니메이션: `----`(FE) → 오른쪽 `|`(F9, AN0) → `____`(F7) → 왼쪽 `|`(CF, AN3), 각 150ms, DP는 OFF.
- 기존 `max_fanout=16` 속성은 유지함.

## 확인 방법
- `python check_static.py`: LED 연결·XDC 핀·4단계 애니메이션 비트 패턴의 정적 점검 (Verilog 실행 아님).
- `tb_animation_display.v`: step × digit 16개 조합을 검사하도록 기존 그대로 유지.
- `tb_main_controller.v`: LED 상태와 step 0→1→2→3→0 추가 확인.
- `tb_fsm_led_animation.v`: PAUSED 5초 후 진입, 애니메이션 중 Start/Pause/Reset 처리, LED 상태를 확인하는 별도 테스트.
- 시뮬레이터가 있는 경우: `iverilog -g2012 -s tb_fsm_led_animation -o fsm.out main_controller.v tb_fsm_led_animation.v && vvp fsm.out`.
- 실제 100MHz 설계에서 150ms/step; 테스트벤치 CLK_FREQ=1000에서 150 clock/step으로 축소해서 확인.
- 주의: 코드의 정적 점검 성공이 Vivado 합성 및 실물 FND 동작 성공을 보장하지는 않음.
