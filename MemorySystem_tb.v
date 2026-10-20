`timescale 1ns/1ps
module MemorySystem_tb;
    reg clk = 0, rst = 1;
    reg [31:0] address = 0, writeData = 0;
    reg readEnable = 0, writeEnable = 0;
    reg [15:0] switches = 0;
    wire [31:0] readData;
    wire [15:0] leds;
    addressDecoderTop dut(clk, rst, address, readEnable, writeEnable,
                          writeData, switches, readData, leds);
    always #5 clk = ~clk;
    task write(input [31:0] a, input [31:0] d);
    begin
        @(negedge clk); address = a; writeData = d; writeEnable = 1; readEnable = 0;
        @(negedge clk); writeEnable = 0;
    end endtask
    task read(input [31:0] a);
    begin
        @(negedge clk); address = a; readEnable = 1; writeEnable = 0;
        #1;
    end endtask

    initial begin
        $dumpfile("mem.vcd"); $dumpvars(0, MemorySystem_tb);
        #12 rst = 0;
        write(32'h005, 32'hDEADBEEF);          // 00 -> mem write
        read (32'h105);                         // 01 -> mem read
        $display("MEM read  = %h (exp DEADBEEF)", readData);
        write(32'h205, 32'h0000A5A5);          // 10 -> LED write
        @(negedge clk);
        $display("LEDs      = %h (exp A5A5)", leds);
        switches = 16'h1234;
        read(32'h305);                          // 11 -> switch read
        $display("SWITCHES  = %h (exp 00001234)", readData);
        write(32'h205, 32'h0000FFFF);          // LED write must not touch memory
        read (32'h105);
        $display("MEM still = %h (exp DEADBEEF)", readData);
        read (32'h205);                         // LED addr read -> nothing
        $display("LED read  = %h (exp 0)", readData);
        @(negedge clk) readEnable = 0;
        #20 $finish;
    end
endmodule