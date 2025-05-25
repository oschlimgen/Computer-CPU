`include "BuildingBlocks/Register.sv"


/*
 * Creates a custom register, the program counter, that holds the address
 *  of the current instruction to execute. The program counter will
 *  automatically count up by 4 bytes each clock cycle (when enabled). It can
 *  also be set to some arbitrary address during a jump instruction.
 */
module ProgramCounter(
  input logic clk,
  input logic reset_n,
  input logic pc_enable,
  input logic jump_en,
  input logic [31:0] jump_to,
  output logic [31:0] pc,
  output logic [31:0] link_value
);

// Create the addition logic for finding the next instruction
logic [31:0] pc_incr;
assign pc_incr = pc + 4;

// Select whether to move to the next instruction or to jump to
//    a new location (if processing a jump instruction).
logic [31:0] next_pc;
always_comb begin
  if(jump_en) begin
    next_pc <= jump_to;
  end else begin
    next_pc <= pc_incr;
  end
end

// Create the register to hold the program counter
Register #(32) program_counter(
  .clk(clk),
  .reset_n(reset_n),
  .enable(pc_enable),
  .in(next_pc),
  .out(pc)
);

// The link value is the address to return to after branching (typically to a function call).
//    Should return to the instruction after the branch instruction, which is the next instruction
//    when processing the jump and link instruction.
assign link_value = pc_incr;

endmodule