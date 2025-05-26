`ifndef BUILDINGBLOCK_SIGNEXTENDER
`define BUILDINGBLOCK_SIGNEXTENDER


/*
 * Takes a single input bus of some width less than 32, and extends it to
 *  32-bits via sign-extension. The leading bit is copied to more significant
 *  bits in the 32-bit result.
 */
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