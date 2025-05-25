`ifndef BUILDINGBLOCK_SIGNEXTENDER
`define BUILDINGBLOCK_SIGNEXTENDER

module SignExtender #(parameter int WIDTH)(
  input logic [WIDTH-1:0] in,
  output logic [31:0] out
);

assign out[WIDTH-1:0] = in;

generate
  genvar i;
  for(i = WIDTH; i < 32; i++) begin : extension_wires
    assign out[i] = in[WIDTH-1];
  end
endgenerate

endmodule

`endif