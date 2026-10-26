`timescale 1ns / 1ps

module tb_moor_fsm_101();
    reg clk=0;
    reg reset=0;
    reg x=0;     // 입력
    wire y;      // 출력 

    reg r_error=1'b0;

    moor_fsm_101 u_moor_fsm_101(
        .clk(ckl),
        .reset(reset),
        .x(x),
        .y(y)
    );

    always #5 clk = ~clk;    //100MHz clk 생성

    task send_data(input a, input expect_val);
        begin
            x=a; #1;
            @(posedge clk); #1;
            if(y !== expect_val) begin
                r_error=1'b1;   // error detect flag
            $display("FAIL t=%0t x=%b y=%b expect_val=%b", $time, a, y, expect_val);
            end
        end
    endtask

    initial begin
        #100 reset=1;
        #100 reset=0;
        sned_data(1,0);
        send_data(0,0);
        send_data(1,1);
        send_data(0,0); send_data(1,1);

        send_data(1,0); send_data(0, 0); send_data(1,1);
        if (r_error == 0) $display("PASS moor fsm_101");
        else  $display("FAIL moor fsm_101");
        $finish;
    end

endmodule
