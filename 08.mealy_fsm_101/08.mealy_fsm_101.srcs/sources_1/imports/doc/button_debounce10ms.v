`timescale 1ns / 1ps

module debouncer(
    input clk,
    input reset,
    input btn,
    output reg pulse
);

    reg [1:0] r_sync;
    reg r_stable;
    reg [19:0] r_cnt;

    // 1) 버튼 동기화
    always @(posedge clk or posedge reset) begin
        if (reset) r_sync <= 0;
        else r_sync <= {r_sync[0], btn};
    end

    // 2) 디바운싱 + 펄스 생성
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_stable <= 0;
            r_cnt <= 0;
            pulse <= 0;
        end
        else begin
            pulse <= 0;
            if (r_sync[1] == r_stable) r_cnt <= 0;
            else if (r_cnt == 20'd999_999) begin
                r_cnt <= 0;
                r_stable <= r_sync[1];
                if (r_sync[1])
                    pulse <= 1;
            end else r_cnt <= r_cnt + 1'b1;
        end
    end

endmodule