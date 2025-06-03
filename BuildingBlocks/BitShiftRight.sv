`ifndef BUILDINGBLOCK_BITSHIFTRIGHT
`define BUILDINGBLOCK_BITSHIFTRIGHT


/*
 * Shifts an input right by some fixed amount, filling new bits with the value
 *  given as an input. Additionally has an enable input to determine if the
 *  shift should occur or the original input should be outputted without
 *  modification.
 */
module BitShiftRightLayer #(parameter int WIDTH, parameter int AMOUNT)(
  input logic [WIDTH-1:0] in,
  input logic enable,
  input logic fill_value,
  output logic [WIDTH-1:0] out
);

always_comb begin
  for(int i = 0; i < WIDTH - AMOUNT; i++) begin : filler
    if(enable) begin
      out[i] = in[i + AMOUNT];
    end else begin
      out[i] = in[i];
    end
  end
  for(int i = WIDTH - AMOUNT; i < WIDTH; i++) begin : shifter
    if(enable) begin
      out[i] = fill_value;
    end else begin
      out[i] = in[i];
    end
  end
end

endmodule


/*
 * Performs a bitwise shift on the 32-bit input by an amount given by another
 *  input. Does so by shifting the input by powers of two corresponding to the
 *  bits of the shift amount input. Each sequential power-of-two shift is
 *  enabled by that bit of the shift amount.
 */
module BitShiftRight(
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
    BitShiftRightLayer #(.WIDTH(32), .AMOUNT(2 ** i)) shifter(
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
