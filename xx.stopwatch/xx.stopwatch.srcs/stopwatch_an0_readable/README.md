# AN0 가독성 개선 버전

원인: `ten_ms_digit`이 10ms마다 1 증가해 AN0가 초당 100회 변경됐습니다. FND의 자리 스캔 주파수 문제가 아닙니다.

변경: `main_controller.v`에서 내부 10ms 카운터 `centisec`을 유지하되 AN0에는 `centisec/10` (100ms 자리)를 표시합니다. 출력은 **M.SS.T**, 예: 1.23.4 = 1분 23.4초. `fnd_digit_display.v`에서 AN3/AN1의 두 Dot가 동일한 500ms ON/OFF 주기로 점멸하도록 이전 요청도 적용했습니다.

기존 4단계 둘레 애니메이션, 5초 대기, 버튼 및 상태 LED, MAX_FANOUT 힌트는 유지했습니다. `tb_top.v`는 100ms 표시 및 두 DP 점멸에 맞춰 수정했습니다.

검증 상태: 코드 대조 및 정적 검사만 수행. Vivado/XSim 실행은 필요합니다. XDC 제약은 원본 그대로입니다.
