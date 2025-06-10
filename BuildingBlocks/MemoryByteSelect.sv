`ifndef BUILDINGBLOCK_MEMORYBYTESELECT_SV
`define BUILDINGBLOCK_MEMORYBYTESELECT_SV


module MemoryByteSelect(
  input logic [1:0] address_end,
  input logic [1:0] read_write_size,
  input logic [31:0] read_value,
  input logic [31:0] write_value,
  output logic [3:0] byte_select,
  output logic [31:0] shifted_read_value,
  output logic [31:0] shifted_write_value
);

always_comb begin
  unique case(read_write_size)
    2'b00: begin // Write a byte
      unique case(address_end)
        2'b00: begin
          byte_select = 4'b0001;
          shifted_read_value = { 24'b0, read_value[7:0] };
          shifted_write_value = { 24'b0, write_value[7:0] };
        end
        2'b01: begin
          byte_select = 4'b0010;
          shifted_read_value = { 24'b0, read_value[15:8] };
          shifted_write_value = { 16'b0, write_value[7:0], 8'b0 };
        end
        2'b10: begin
          byte_select = 4'b0100;
          shifted_read_value = { 24'b0, read_value[23:16] };
          shifted_write_value = { 8'b0, write_value[7:0], 16'b0 };
        end
        2'b11: begin
          byte_select = 4'b1000;
          shifted_read_value = { 24'b0, read_value[31:24] };
          shifted_write_value = { write_value[7:0], 24'b0 };
        end
      endcase
    end
    2'b01: begin // Write a half-word
      unique case(address_end)
        1'b0: begin
          byte_select = 4'b0011;
          shifted_read_value = { 16'b0, read_value[15:0] };
          shifted_write_value = { 16'b0, write_value[15:0] };
        end
        1'b1: begin
          byte_select = 4'b1100;
          shifted_read_value = { 16'b0, read_value[31:16] };
          shifted_write_value = { write_value[15:0], 16'b0 };
        end
      endcase
    end
    2'b10: begin // Write a full word
      byte_select = 4'b1111;
      shifted_read_value = read_value;
      shifted_write_value = write_value;
    end
    default: begin // Don't read or write this clock cycle
      byte_select = 4'b0000;
      shifted_read_value = read_value;
      shifted_write_value = write_value;
    end
  endcase
end

endmodule

`endif
