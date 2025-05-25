`ifndef BUILDINGBLOCK_BITSHIFTLEFT
`define BUILDINGBLOCK_BITSHIFTLEFT


module BitShiftLeftLayer #(parameter int WIDTH, parameter int AMOUNT)(
  input logic [WIDTH-1:0] in,
  input logic enable,
  input logic fill_value,
  output logic [WIDTH-1:0] out
);

always_comb begin
  for(int i = 0; i < AMOUNT; i++) begin : filler
    if(enable) begin
      out[i] = fill_value;
    end else begin
      out[i] = in[i];
    end
  end
  for(int i = AMOUNT; i < WIDTH; i++) begin : shifter
    if(enable) begin
      out[i] = in[i - AMOUNT];
    end else begin
      out[i] = in[i];
    end
  end
end

endmodule


module BitShiftLeft(
  input logic [31:0] in,
  input logic [4:0] amount,
  input logic fill_value,
  output logic [31:0] out
);

logic [31:0] layer[5:0];
assign layer[0] = in;

generate
  genvar i;
  for(i = 0; i < 5; i++) begin : shift_layers
    BitShiftLeftLayer #(32, 2 ** i) shifter(
      .in(layer[i]),
      .enable(amount[i]),
      .fill_value(fill_value),
      .out(layer[i + 1])
    );
  end
endgenerate

assign out = layer[5];

endmodule

`endif
