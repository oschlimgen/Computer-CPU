`ifndef COMPUTER_MEMORYBLOCK_SV
`define COMPUTER_MEMORYBLOCK_SV

`include "BuildingBlocks/MemoryWord.sv"
`include "BuildingBlocks/MemoryByteSelect.sv"


module MemoryBlock #(parameter int ADDRESS_WIDTH = 10, parameter int ONLY_ALLOW_WORDS = 0)(
  input logic clock,
  input logic reset_n,
  input logic [ADDRESS_WIDTH-1:0] address,
  input logic [1:0] read_write_size, // 0: Byte, 1: Half-Word, 2: Word
  input logic write_enable,
  input logic [31:0] write_value,
  output logic [31:0] read_value
);

localparam int ROW_WIDTH = (ADDRESS_WIDTH - 2) / 2;
localparam int COL_WIDTH = (ADDRESS_WIDTH - 1) / 2;

logic [ROW_WIDTH-1:0] row_address;
logic [COL_WIDTH-1:0] column_address;

logic [(1<<ROW_WIDTH)-1:0] row_select;
logic [(1<<COL_WIDTH)-1:0] column_select;

assign row_address = address[ADDRESS_WIDTH-1 : ADDRESS_WIDTH-ROW_WIDTH];
assign column_address = address[COL_WIDTH+1 : 2];

always_comb begin : row_decoder
  row_select = '0;
  row_select[row_address] = 1'b1;
end

always_comb begin : column_decoder
  column_select = '0;
  column_select[column_address] = 1'b1;
end

logic [3:0] write_select;
logic [3:0] write_select_with_enable;
logic [31:0] read_value_raw;
logic [31:0] shifted_read_value;
logic [31:0] shifted_write_value;

generate
  if(ONLY_ALLOW_WORDS == 0) begin
    MemoryByteSelect enable_decoder(
      .address_end(address[1:0]),
      .read_write_size(read_write_size),
      .read_value(read_value_raw),
      .write_value(write_value),
      .byte_select(write_select),
      .shifted_read_value(shifted_read_value),
      .shifted_write_value(shifted_write_value)
    );
  end else begin
    assign write_select = 4'b1111;
    assign shifted_read_value = read_value_raw;
    assign shifted_write_value = write_value;
  end
endgenerate

assign write_select_with_enable = (write_enable ? write_select : 4'b0);


logic [31:0] values [(1<<ROW_WIDTH)-1:0][(1<<COL_WIDTH)-1:0];

genvar row;
genvar col;
generate
  for(row = 0; row < 1<<ROW_WIDTH; row++) begin : memory_rows
    for(col = 0; col < 1<<COL_WIDTH; col++) begin : memory_cols
      MemoryWord word(
        .clk(clock),
        .reset_n(reset_n),
        .address_enable(row_select[row] & column_select[col]),
        .write_enable(write_select_with_enable),
        .write_value(shifted_write_value),
        .read_value(values[row][col])
      );
    end
  end
endgenerate

assign read_value_raw = values[row_address][column_address];
assign read_value = shifted_read_value;


endmodule

`endif
