`ifndef BUILDINGBLOCK_REGISTER
`define BUILDINGBLOCK_REGISTER

module Register #(parameter int WIDTH)(
  input logic clk,
  input logic reset_n,
  input logic enable,
  input logic [WIDTH-1:0] in,
  output logic [WIDTH-1:0] out
);

always_ff @(posedge clk, negedge reset_n) begin
  if(!reset_n) begin
    out <= '0;
  end else begin
    if(enable) begin
      out <= in;
    end
  end
end

endmodule

`endif
