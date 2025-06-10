`ifndef BUILDINGBLOCK_MEMORYWORD_SV
`define BUILDINGBLOCK_MEMORYWORD_SV


module MemoryWord(
  input logic clk,
  input logic reset_n,
  input logic address_enable,
  input logic [3:0] write_enable,
  input logic [31:0] write_value,
  output logic [31:0] read_value
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

assign read_value = value;

endmodule

`endif