`ifndef CONSTANT_INSTRUCTION
`define CONSTANT_INSTRUCTION


typedef struct packed {
  logic R;
  logic I;
  logic S;
  logic B;
  logic U;
  logic J;
} EncodingType;

typedef struct packed {
  logic LUI;
  logic AUIPC;
  logic JAL;
  logic JALR;
  logic BEQ;
  logic BNE;
  logic BLT;
  logic BGE;
  logic BLTU;
  logic BGEU;
  logic LB;
  logic LH;
  logic LW;
  logic LBU;
  logic LHU;
  logic SB;
  logic SH;
  logic SW;
  logic ADDI;
  logic SLTI;
  logic SLTIU;
  logic XORI;
  logic ORI;
  logic ANDI;
  logic SLLI;
  logic SRLI;
  logic SRAI;
  logic ADD;
  logic SUB;
  logic SLL;
  logic SLT;
  logic SLTU;
  logic XOR;
  logic SRL;
  logic SRA;
  logic OR;
  logic AND;
  logic FENCE;
  logic FENCE_TSO;
  logic PAUSE;
  logic ECALL;
  logic EBREAK;
} InstructionSet;

typedef struct packed {
  logic ADD;
  logic SUB;
  logic SLL;
  logic SLT;
  logic SLTU;
  logic XOR;
  logic SRL;
  logic SRA;
  logic OR;
  logic AND;

  // Secondary operations
  logic SLT_B;
  logic SLTU_B;
  logic SEQ_B;
} InstructionSetALU;


`endif