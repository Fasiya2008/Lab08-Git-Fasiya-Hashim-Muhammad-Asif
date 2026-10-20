module addressDecoderTop(
    input         clk, rst,
    input  [31:0] address,
    input         readEnable, writeEnable,
    input  [31:0] writeData,
    input  [15:0] switches,
    output [31:0] readData,
    output [15:0] leds);
    wire DataMemWrite, DataMemRead, LEDWrite, SwitchReadEnable;
    wire [31:0] memData;
    AddressDecoder dec(
        .address(address), .readEnable(readEnable), .writeEnable(writeEnable),
        .DataMemWrite(DataMemWrite), .DataMemRead(DataMemRead),
        .LEDWrite(LEDWrite), .SwitchReadEnable(SwitchReadEnable));
    DataMemory dmem(
        .clk(clk), .MemWrite(DataMemWrite), .MemRead(DataMemRead),
        .address(address[7:0]), .write_data(writeData), .read_data(memData));
    reg [15:0] ledReg;
    always @(posedge clk or posedge rst)
        if (rst) ledReg <= 16'b0;
        else if (LEDWrite) ledReg <= writeData[15:0];
    assign leds = ledReg;
    assign readData = DataMemRead      ? memData : 
    SwitchReadEnable ? {16'b0, switches} : 32'b0;
endmodule