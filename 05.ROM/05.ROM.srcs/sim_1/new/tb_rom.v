`timescale 1ns / 1ps

module tb_rom();

    reg [3:0] r_addr;
    reg r_oe;
    wire [7:0] w_dataout;

    rom uut (
        .addr(r_addr),
        .oe(r_oe),
        .dataout(w_dataout)
    );

    initial begin
        // Test case 1: Enable output and read from address 0
        r_addr = 4'b0000;
        r_oe = 0;
        // Wait for 10 time units
        $display("Address: %b, Output: %h", r_addr, w_dataout);
        
        #10; 
        r_addr = 4'b0000;
        r_oe = 1;
        // Wait for 10 time units
        $display("Address: %b, Output: %h", r_addr, w_dataout);

        #10;
        // Test case 2: Enable output and read from address 5
        r_addr = 4'b0001;
        $display("Address: %b, Output: %h", r_addr, w_dataout);
        #10; 
        // Test case 3: Disable output and read from address 3
        r_addr = 4'b0010;
        $display("Address: %b, Output: %h", r_addr, w_dataout);
        #10; 
        // Test case 4: Enable output and read from address 15
        r_addr = 4'b0100;
        $display("Address: %b, Output: %h", r_addr, w_dataout);
         #10; 
        // Test case 4: Enable output and read from address 15
        r_addr = 4'b1000;
        $display("Address: %b, Output: %h", r_addr, w_dataout);
        #10; // Wait for 10 time units        
        $finish;

    end
endmodule
