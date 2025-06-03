`ifndef BUILDINGBLOCK_MEMORYWORD
`define BUILDINGBLOCK_MEMORYWORD

`include "BuildingBlocks/Register.sv"


module MemoryWord(
  input logic clk,
  input logic reset_n,
  input logic address_enable,
  input logic [3:0] write_enable,
  input logic [31:0] write_value,
  inout logic [31:0] read_value
);

logic [31:0] value;

logic [31:0] next_value;
genvar i;
generate
  for(i = 0; i < 4; i++) begin : next_bytes
    // assign next_value[8*i+7 : 8*i] = (write_enable[i] ? write_value[8*i+7 : 8*i] : value[8*i+7 : 8*i]);
    always_ff @(posedge clk, negedge reset_n) begin
      if(!reset_n) begin
        value[8*i+7 : 8*i] <= 8'b0;
      end else begin
        if(address_enable & write_enable[i]) begin
          value[8*i+7 : 8*i] <= write_value[8*i+7 : 8*i];
        end
      end
    end
  end
endgenerate

assign read_value = (address_enable ? value : {32{1'bZ}});

endmodule

`endif