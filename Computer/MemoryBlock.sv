`ifndef COMPUTER_MEMORYBLOCK
`define COMPUTER_MEMORYBLOCK

`include "BuildingBlocks/MemoryWord.sv"

module MemoryBlock #(parameter int ADDRESS_WIDTH = 10)(
  input logic clk,
  input logic reset_n,
  input logic [ADDRESS_WIDTH-1:0] address,
  input logic [1:0] write_enable,
  input logic [31:0] write_value,
  output logic [31:0] read_value
);

localparam int ROW_WIDTH = (ADDRESS_WIDTH - 2) / 2;
localparam int COL_WIDTH = (ADDRESS_WIDTH - 1) / 2;

logic [ROW_WIDTH-1:0] row_address;
logic [COL_WIDTH-1:0] column_address;

logic [(1<<ROW_WIDTH)-1:0] row_select;
logic [(1<<COL_WIDTH)-1:0] column_select;

logic [3:0] write_select;
logic [31:0] shifted_write_value;

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

always_comb begin : write_enable_decoder
  unique case(write_enable)
    2'b01: begin // Write a byte
      unique case(address[1:0])
        2'b00: begin
          write_select = 4'b0001;
          shifted_write_value = write_value;
        end
        2'b01: begin
          write_select = 4'b0010;
          shifted_write_value = { write_value[23:0], 8'b0 };
        end
        2'b10: begin
          write_select = 4'b0100;
          shifted_write_value = { write_value[15:0], 16'b0 };
        end
        2'b11: begin
          write_select = 4'b1000;
          shifted_write_value = { write_value[7:0], 24'b0 };
        end
      endcase
    end
    2'b10: begin // Write a half-word
      unique case(address[1])
        1'b0: begin
          write_select = 4'b0011;
          shifted_write_value = write_value;
        end
        1'b1: begin
          write_select = 4'b1100;
          shifted_write_value = { write_value[15:0], 16'b0 };
        end
      endcase
    end
    2'b11: begin // Write a full word
      write_select = 4'b1111;
      shifted_write_value = write_value;
    end
    default: begin // Don't write this clock cycle
      write_select = 4'b0000;
      shifted_write_value = write_value;
    end
  endcase
end


wire [31:0] row_values [(1<<ROW_WIDTH)-1:0];

genvar row;
genvar col;
generate
  for(row = 0; row < 1<<ROW_WIDTH; row++) begin : memory_rows
    for(col = 0; col < 1<<COL_WIDTH; col++) begin : memory_cols
      MemoryWord word(
        .clk(clk),
        .reset_n(reset_n),
        .address_enable(row_select[row] & column_select[col]),
        .write_enable(write_select),
        .write_value(shifted_write_value),
        .read_value(row_values[row])
      );
    end
  end
endgenerate

assign read_value = row_values[row_address];


endmodule

`endif
