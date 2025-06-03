`ifndef COMPUTER_CENTRALPROCESSINGUNIT
`define COMPUTER_CENTRALPROCESSINGUNIT


`include "Constants/Instruction.sv"


/*
 * Each clock cycle, processes a single instruction. The instruction should
 *  come from memory at the address given by the program counter. Also has
 *  inputs and outputs for writing to and reading from memory at any given
 *  address. Instructions follow the RISC-V format, although the CPU currently
 *  lacks several base instructions, machine-level registers and instructions,
 *  and exception handling methods (as described in the RISC-V specifications).
 *  Input / output capabilities can be achieved through memory-mapped I/O
 *  devices.
 */
module CentralProcessingUnit(
  input logic clock,
  input logic reset_n,
  input logic [31:0] instruction,
  output logic [31:0] program_counter,
  // Interface with memory
  output logic memory_write_en,
  output logic [31:0] memory_address,
  output logic [31:0] memory_write_value,
  input logic [31:0] memory_read_value
);

// Create instruction decoding modules
EncodingType encoding_type;
InstructionSet operation;
logic error_illegal_instruction;

logic [4:0] instruction_rd;
logic [4:0] instruction_rs1;
logic [4:0] instruction_rs2;
logic [31:0] instruction_imm;

InstructionDecoder decoder(
  .inst(instruction),
  .en(encoding_type),
  .op(operation),
  .illegal(error_illegal_instruction)
);

InstructionExtract extractor(
  .inst(instruction[31:7]),
  .en(encoding_type),
  .rd(instruction_rd),
  .rs1(instruction_rs1),
  .rs2(instruction_rs2),
  .imm(instruction_imm)
);


// Create register and program counter modules
logic [31:0] reg_read_value1;
logic [31:0] reg_read_value2;

logic reg_write_en;
logic [31:0] reg_write_value;

logic pc_enable_n;
logic pc_jump_en;
logic [31:0] pc_jump_to;
logic [31:0] pc_link_value;

Registers registers(
  .clk(clock),
  .reset_n(reset_n),
  .write_enable(reg_write_en),
  .address_read1(instruction_rs1),
  .address_read2(instruction_rs2),
  .address_write(instruction_rd),
  .value_write(reg_write_value),
  .value_read1(reg_read_value1),
  .value_read2(reg_read_value2)
);

ProgramCounter pc_register(
  .clk(clock),
  .reset_n(reset_n),
  .pc_enable(1'b1),
  .jump_en(pc_jump_en),
  .jump_to(pc_jump_to),
  .pc(program_counter),
  .link_value(pc_link_value)
);


// Create ALU module with wiring to instructions and registers
logic [31:0] alu_out;
logic alu_out_b;

WiringALU alu(
  .op(operation),
  .en(encoding_type),
  .reg1(reg_read_value1),
  .reg2(reg_read_value2),
  .pc(program_counter),
  .imm(instruction_imm),
  .out(alu_out),
  .out_b(alu_out_b)
);


// Define which instructions to write on
assign reg_write_en = encoding_type.R | encoding_type.I |
                      encoding_type.U | encoding_type.J;

// Assign which value to write to rd
always_comb begin
  // Write the immediate
  if(operation.LUI) begin
    reg_write_value = instruction_imm;
  end
  // Write the link value from program counter
  else if(operation.JAL | operation.JALR) begin
    reg_write_value = pc_link_value;
  end
  // Write to a register from memory for load instructions
  else if(operation.LW | operation.LH | operation.LB |
          operation.LHU | operation.LBU) begin
    reg_write_value = memory_read_value;
  end
  // Write ALU output
  else begin
    reg_write_value = alu_out;
  end
end

// Define which instructions to write to program counter
assign pc_jump_to = { alu_out[31:1], 1'b0 };
assign pc_jump_en = operation.JAL | operation.JALR |
                    (operation.BEQ & alu_out_b) | (operation.BNE & ~alu_out_b) |
                    (operation.BLT & alu_out_b) | (operation.BLTU & alu_out_b) |
                    (operation.BGE & ~alu_out_b) | (operation.BGEU & ~alu_out_b);

// Control writing to memory
assign memory_write_en = operation.SW | operation.SH | operation.SB;
assign memory_address = alu_out;
assign memory_write_value = reg_read_value2;

endmodule

`endif