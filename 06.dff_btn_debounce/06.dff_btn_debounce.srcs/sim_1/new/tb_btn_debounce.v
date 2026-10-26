`timescale 1ns / 1ps

module tb_btn_debounce();
    parameter CLK_FREQ = 100_000_000;
    parameter CLK_PERIOD =10; //10ns


    parameter SIMULATION_DIV = 100;
    localparam SAMPLE_PERIOD = SIMULATION_DIV * CLK_PERIOD;

    parameter BTN_PRESS_LIMIT = SAMPLE_PERIOD * 3;

    defparam top_btn_debounce.u_button_debounce.u_clock_80Hz.DIV = SIMULATION_DIV; 

    reg r_clk;
    reg r_reset;
    reg r_btnC;
    wire w_led;

    top_btn_debounce u_top_btn_debounce(
        .clk(r_clk),
        .reset(r_reset),
        .btnC(r_btnC),
        .led(w_led)
    );

    initial begin
        r_clk = 0;
        forever begin
            #(CLK_PERIOD/2) r_clk = ~r_clk; //100MHz
        end
    end       

    initial begin
        r_reset = 1;
        r_btnC = 0;
        #100;
        r_reset = 0;
             
        $display("[%0t] start noise sig generation ........", $time);
        #100; r_btnC = 1;
        #200; r_btnC = 0;
        #300; r_btnC = 1;
        #120; r_btnC = 0;
        #500; //noise todtjd
        r_btnC = 1;
        #(BTN_PRESS_LIMIT); //3us(3w주기)
        #100
        if(w_led == 1'b1)begin
            $display("[0t] SIM TEST PASSED !!!!........", $time);
        end else begin
            $display("[0t] SIM TEST FAILED !!!!........", $time);
        end
        #1000;
        $display("[0t] ==== simulation finish ====.", $time);
        $finish; 
    end
    
endmodule
