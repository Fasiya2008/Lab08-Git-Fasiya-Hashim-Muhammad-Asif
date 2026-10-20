// address[9:8] = 00 -> Data Memory WRITE
//                01 -> Data Memory READ
//                10 -> LEDs   (write only)
//                11 -> Switches (read only)
module AddressDecoder(
    input  [31:0] address,
    input         readEnable, writeEnable,   // from CPU control
    output        DataMemWrite,
    output        DataMemRead,
    output        LEDWrite,
    output        SwitchReadEnable
);
    wire [1:0] sel = address[9:8];            // bits 31:10 unused

    assign DataMemWrite     = writeEnable & (sel == 2'b00);
    assign DataMemRead      = readEnable  & (sel == 2'b01);
    assign LEDWrite         = writeEnable & (sel == 2'b10);
    assign SwitchReadEnable = readEnable  & (sel == 2'b11);
endmodule