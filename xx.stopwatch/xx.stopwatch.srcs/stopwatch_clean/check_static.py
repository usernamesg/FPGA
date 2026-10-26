#!/usr/bin/env python3
"""Static, non-simulation sanity checks for LED hookup and animation patterns."""
from pathlib import Path
import re
root=Path(__file__).resolve().parent
main=(root/'main_controller.v').read_text()
fd=(root/'fnd_digit_display.v').read_text()
top=(root/'top.v').read_text()
xdc=(root/'basys3_stopwatch.xdc').read_text()
assert 'output [3:0] led' in main and 'output [3:0] led' in top
assert '.led(led)' in top
assert re.search(r'assign\s+led\s*=\s*\{\s*\(state == ANIMATION\),\s*\(state == IDLE\),\s*\(state == PAUSED\),\s*\(state == RUNNING\)',main)
for i,pin in enumerate(['U16','E19','U19','V19']):
    assert f'PACKAGE_PIN {pin} IOSTANDARD LVCMOS33' in xdc and f'[get_ports {{led[{i}]}}]' in xdc
assert 'anim_index == 3' in main
for step,literal in [(0,"8'b1111_1110"),(1,"8'b1111_1001"),(2,"8'b1111_0111"),(3,"8'b1100_1111")]:
    assert f"3'd{step}:" in fd and literal in fd
assert "sel == 2'b00" in fd and "sel == 2'b11" in fd
assert 'if (animation)' in fd and "8'b1111_1111" in fd
# Assert 7-segment bit meaning, active low: a=0,b=1,c=2,d=3,e=4,f=5,g=6,dp=7.
patterns={0:{0:0xFE,1:0xFE,2:0xFE,3:0xFE},
          1:{0:0xF9,1:0xFF,2:0xFF,3:0xFF},
          2:{0:0xF7,1:0xF7,2:0xF7,3:0xF7},
          3:{0:0xFF,1:0xFF,2:0xFF,3:0xCF}}
for step,digits in patterns.items():
    active={idx:[name for bit,name in enumerate('abcdefg') if not value & (1<<bit)] for idx,value in digits.items()}
    assert all(value & 0x80 for value in digits.values()),'DP on in animation'
    print(f'Step {step}: ' + ', '.join(f'AN{i}={"".join(letters) or "off"}' for i,letters in active.items()))
assert [b for b in [0xFE,0xF9,0xF7,0xCF]] == [0xFE,0xF9,0xF7,0xCF]
print('PASS: static LED connections, animation ordering and segment bit maps.')
print('NOTE: This does NOT compile or simulate the Verilog.')
