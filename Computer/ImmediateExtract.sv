`ifndef COMPUTER_IMMEDIATEEXTRACT_SV
`define COMPUTER_IMMEDIATEEXTRACT_SV

`include "Constants/Instruction.sv"
`include "BuildingBlocks/SignExtender.sv"


/*
 * Parses the instruction for immediates of each of the various types, and
 *  outputs the one that matches the encoding type of the instruciton. Each
 *  immediate is sign-extended to 32 bits, regardless of its size in the
 *  instruction.
 */
module ImmediateExtract(
  input logic [31:7] inst,
  input EncodingType en,
  output logic [4:0] rd,
  output logic [4:0] rs1,
  output logic [4:0] rs2,
  output logic [31:0] imm
);

// Location of rd, rs1, rs2 values will always be the same
assign rd = inst[11:7];
assign rs1 = inst[19:15];
assign rs2 = inst[24:20];

// Immediates will be constructed from different bits depending on instruction type
logic [31:0] immi;
logic [31:0] imms;
logic [31:0] immb;
logic [31:0] immu;
logic [31:0] immj;

// All immediates must be sign-extended. Here, immediate bits are selected
//    then sign-extended to 32 bits.
SignExtender #(12) immi_extend(
  .in(inst[31:20]),
  .out(immi)
);
SignExtender #(12) imms_extend(
  .in({ inst[31:25], inst[11:7] }),
  .out(imms)
);
SignExtender #(13) immb_extend(
  .in({ inst[31], inst[7], inst[30:25], inst[11:8], 1'b0 }),
  .out(immb)
);
SignExtender #(32) immu_extend(
  .in({ inst[31:12], 12'b0 }),
  .out(immu)
);
SignExtender #(21) immj_extend(
  .in({ inst[31], inst[19:12], inst[20], inst[30:21], 1'b0 }),
  .out(immj)
);

// Select which immediate format to return based on the instruction encoding type
always_comb begin
  unique case(1'b1)
    en.I:     imm = immi;
    en.S:     imm = imms;
    en.B:     imm = immb;
    en.U:     imm = immu;
    en.J:     imm = immj;
    default:  imm = 32'b0;
  endcase
end

endmodule

`endif