`timescale 1ns / 1ps
module top_lab8(
    input         clk,
    input         btnC,        // reset
    input  [15:0] sw,
    output [15:0] led,
    output reg [6:0] seg,
    output        dp,
    output reg [3:0] an
);
    wire rst;
    debouncer db(.clk(clk), .pbin(btnC), .pbout(rst));

    // bus signals come straight from the switches
    wire [31:0] address     = {22'b0, sw[9:8], 2'b00, sw[15:10]};
    wire [31:0] writeData   = {24'b0, sw[7:0]};
    wire        writeEnable = ~sw[8];   // 00, 10 are writes
    wire        readEnable  =  sw[8];   // 01, 11 are reads
    wire [31:0] readData;

    reg [31:0] lastRead = 0;
    always @(posedge clk) begin
        if (rst) lastRead <= 0;
        else if (readEnable) lastRead <= readData;
    end

    addressDecoderTop mem_sys(
        .clk(clk), .rst(rst), .address(address),
        .readEnable(readEnable), .writeEnable(writeEnable),
        .writeData(writeData), .switches(sw),
        .readData(readData), .leds(led));

    // 7-segment: show lastRead[15:0] as 4 hex digits
    reg [18:0] rc = 0;
    always @(posedge clk) rc <= rc + 1;
    reg [3:0] nib;
    always @(*) begin
        case (rc[18:17])
            2'd0: begin an = 4'b1110; nib = lastRead[3:0];   end
            2'd1: begin an = 4'b1101; nib = lastRead[7:4];   end
            2'd2: begin an = 4'b1011; nib = lastRead[11:8];  end
            default: begin an = 4'b0111; nib = lastRead[15:12]; end
        endcase
        case (nib)
            4'h0: seg = 7'b1000000; 4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100; 4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001; 4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010; 4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000; 4'h9: seg = 7'b0010000;
            4'hA: seg = 7'b0001000; 4'hB: seg = 7'b0000011;
            4'hC: seg = 7'b1000110; 4'hD: seg = 7'b0100001;
            4'hE: seg = 7'b0000110; default: seg = 7'b0001110;
        endcase
    end
    assign dp = 1'b1;
endmodule