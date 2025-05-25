`include "Constants/Instruction.sv"

module WiringALU(
  input InstructionSet op,
  input logic [31:0] reg1,
  input logic [31:0] reg2,
  input logic [31:0] pc,
  input logic [31:0] imm,
  output logic [31:0] out,
  output logic out_b
);

// Create wires to ALU, and instantiate the module
InstructionSetALU alu_op;
logic [31:0] in1;
logic [31:0] in2;
logic [31:0] in1_b;
logic [31:0] in2_b;

ArithmeticLogicUnit alu(
  .op(alu_op),
  .in1(in1),
  .in2(in2),
  .in1_b(in1_b),
  .in2_b(in2_b),
  .out(out),
  .out_b(out_b)
);


// Assign ALU primary operation based on instruction operation
assign alu_op.ADD = op.ADD | op.ADDI | op.AUIPC | op.JAL | op.JALR |
                    op.BEQ | op.BNE | op.BLT | op.BLTU | op.BGE | op.BGEU |
                    op.SW | op.LW;
assign alu_op.SUB = op.SUB;
assign alu_op.SLL = op.SLL | op.SLLI;
assign alu_op.SLT = op.SLT | op.SLTI;
assign alu_op.SLTU = op.SLTU | op.SLTIU;
assign alu_op.XOR = op.XOR | op.XORI;
assign alu_op.SRL = op.SRL | op.SRLI;
assign alu_op.SRA = op.SRA | op.SRAI;
assign alu_op.OR = op.OR | op.ORI;
assign alu_op.AND = op.AND | op.ANDI;
// Assign ALU secondary operation based on instruction operation
assign alu_op.SLT_B = op.BLT | op.BGE;
assign alu_op.SLTU_B = op.BLTU | op.BGEU;
assign alu_op.SEQ_B = op.BEQ | op.BNE;

// Assign ALU primary inputs
always_comb begin
  // Program Counter & Immediate
  if(op.AUIPC || op.JAL || op.BEQ || op.BNE ||
      op.BLT || op.BLTU || op.BGE || op.BGEU) begin
    in1 <= pc;
    in2 <= imm;
  end
  // Register & Immediate
  else if(op.ADDI || op.SLLI || op.SLTI || op.SLTIU ||
          op.XORI || op.SRLI || op.SRAI || op.ORI ||
          op.ANDI || op.JALR || op.SW || op.LW) begin
    in1 <= reg1;
    in2 <= imm;
  end
  // Register & Register
  else begin
    in1 <= reg1;
    in2 <= reg2;
  end
end

// Assign ALU secondary inputs as always Register & Register
assign in1_b = reg1;
assign in2_b = reg2;


endmodule
