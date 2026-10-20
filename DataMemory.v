module DataMemory(
    input         clk,
    input         MemWrite,
    input         MemRead,
    input  [7:0]  address,       // address[7:0]
    input  [31:0] write_data,
    output [31:0] read_data
);
    reg [31:0] mem [0:255];
    integer i;
    initial for (i = 0; i < 256; i = i + 1) mem[i] = 32'b0;

    always @(posedge clk)
        if (MemWrite) mem[address] <= write_data;

    assign read_data = MemRead ? mem[address] : 32'b0;
endmodule