`ifndef COMPUTER_REGISTERS_SV
`define COMPUTER_REGISTERS_SV

`include "BuildingBlocks/Register.sv"

/*
 * Creates 32 registers, including a zero register. Each has 32 bits of
 *  storage and a unique 5 bit address. This module allows for two registers
 *  to be read and one to be written to each clock cycle, to support the
 *  RISC-V instruction set.
 */
module Registers(
  input logic clk,
  input logic reset_n,
  input logic write_enable,
  input logic [4:0] address_read1,
  input logic [4:0] address_read2,
  input logic [4:0] address_write,
  input logic [31:0] value_write,
  output logic [31:0] value_read1,
  output logic [31:0] value_read2
);

// Holds values of registers x1 to x31
logic [31:0] mem [31:1];

// Hold values of general purpose registers and the zero register x0
logic [31:0] all_registers [31:0];
assign all_registers[0] = 32'b0; // Force x0 register to always be 0

// Assign each other value in all_registers to be the same as mem
genvar i;
generate
  for(i = 1; i < 32; i++) begin : mem_wires
    assign all_registers[i] = mem[i];
  end
endgenerate

// Assign values to read1 and read2 based on read addresses
assign value_read1 = all_registers[address_read1]; // First read
assign value_read2 = all_registers[address_read2]; // Second read

logic [31:0] write;
always_comb begin
  // Write enable decoder to select register to write to
  write = '0;
  write[address_write] = write_enable;
end

// Create 31 general-purpose registers x1 to x31
generate
  for(i = 1; i < 32; i++) begin : registers
    Register #(.WIDTH(32)) register(
      .clk(clk),
      .reset_n(reset_n),
      .enable(write[i]),
      .in(value_write),
      .out(mem[i])
    );
  end
endgenerate

endmodule

`endif