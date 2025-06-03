`include "Constants/Instruction.sv"


/*
 * Based on the binary encoding of the instruction, create combinational logic
 *  for a one-hot encoding of the instruction type and format. The instruction
 *  type determines what operation is performed. The instruction format
 *  determines where the registers used for the operation are and which bits
 *  are associated with the immediate.
 */
module InstructionDecoder(
  input logic [31:0] inst,
  output EncodingType en,
  output InstructionSet op,
  output logic illegal
);

// Parse out parts of instruction that specify its type
logic [4:0] opcode;
logic [2:0] funct3;
logic [6:0] funct7;
assign opcode = inst[6:2];
assign funct3 = inst[14:12];
assign funct7 = inst[31:25];

// Need to select instrction type, through 
always_comb begin
  en = '0;
  op = '0;
  illegal = '0;

  // Instrction ending in 0b11 signifies 32-bit instruction format.
  //  - 16-bit format isn't supported, so sets illegal instruction bit
  //    if instruction doesn't end in 0b11.
  if(inst[1:0] == 2'b11) begin
    unique case(opcode)
      // LUI
      5'b01101: begin
        en.U = 1'b1;
        op.LUI = 1'b1;
      end
      // AUIPC
      5'b00101: begin
        en.U = 1'b1;
        op.AUIPC = 1'b1;
      end
      // JAL
      5'b11011: begin
        en.J = 1'b1;
        op.JAL = 1'b1;
      end
      // JALR
      5'b11001: begin
        en.I = 1'b1;
        op.JALR = 1'b1;
      end
      // Conditional Branch
      5'b11000: begin
        en.B = 1'b1;
        unique case(funct3)
          3'b000: op.BEQ = 1'b1;
          3'b001: op.BNE = 1'b1;
          3'b100: op.BLT = 1'b1;
          3'b101: op.BGE = 1'b1;
          3'b110: op.BLTU = 1'b1;
          3'b111: op.BGEU = 1'b1;
          default: illegal =  1'b1;
        endcase
      end
      // L Operations
      5'b00000: begin
        en.I = 1'b1;
        unique case(funct3)
          3'b000: op.LB = 1'b1;
          3'b001: op.LH = 1'b1;
          3'b010: op.LW = 1'b1;
          3'b100: op.LBU = 1'b1;
          3'b101: op.LHU = 1'b1;
          default: illegal = 1'b1;
        endcase
      end
      // S Operations
      5'b01000: begin
        en.S = 1'b1;
        unique case(funct3)
          3'b000: op.SB = 1'b1;
          3'b001: op.SH = 1'b1;
          3'b010: op.SW = 1'b1;
          default: illegal = 1'b1;
        endcase
      end
      // Immediate Operations
      5'b00100: begin
        en.I = 1'b1;
        unique case(funct3)
          3'b000: op.ADDI = 1'b1;
          3'b010: op.SLTI = 1'b1;
          3'b011: op.SLTIU = 1'b1;
          3'b100: op.XORI = 1'b1;
          3'b110: op.ORI = 1'b1;
          3'b111: op.ANDI = 1'b1;
          // Shift Operations
          3'b001: begin
            // Left Shift
            unique case(funct7)
              7'b0000000: op.SLLI = 1'b1;
              default: illegal = 1'b1;
            endcase
          end
          3'b101: begin
            // Right Shift
            unique case(funct7)
              7'b0000000: op.SRLI = 1'b1;
              7'b0100000: op.SRAI = 1'b1;
              default: illegal = 1'b1;
            endcase
          end
          default: illegal = 1'b1;
        endcase
      end
      // Register Operations
      5'b01100: begin
        en.R = 1'b1;
        unique case(funct3)
          // Add Subtract
          3'b000: begin
            unique case(funct7)
              7'b0000000: op.ADD = 1'b1;
              7'b0100000: op.SUB = 1'b1;
              default: illegal = 1'b1;
            endcase
          end
          // Left Shift
          3'b001: begin
            unique case(funct7)
              7'b0000000: op.SLL = 1'b1;
              default: illegal = 1'b1;
            endcase
          end
          // Store Less Than
          3'b010: begin
            unique case(funct7)
              7'b0000000: op.SLT = 1'b1;
              default: illegal = 1'b1;
            endcase
          end
          // Store Less Than Unsigned
          3'b011: begin
            unique case(funct7)
              7'b0000000: op.SLTU = 1'b1;
              default: illegal = 1'b1;
            endcase
          end
          // XOR
          3'b100: begin
            unique case(funct7)
              7'b0000000: op.XOR = 1'b1;
              default: illegal = 1'b1;
            endcase
          end
          // Shift Right
          3'b101: begin
            unique case(funct7)
              7'b0000000: op.SRL = 1'b1;
              7'b0100000: op.SRA = 1'b1;
              default: illegal = 1'b1;
            endcase
          end
          // OR
          3'b110: begin
            unique case(funct7)
              7'b0000000: op.OR = 1'b1;
              default: illegal = 1'b1;
            endcase
          end
          // AND
          3'b111: begin
            unique case(funct7)
              7'b0000000: op.AND = 1'b1;
              default: illegal = 1'b1;
            endcase
          end
        endcase
      end
      // Fence Pause
      5'b00011: begin
        unique case(inst[31:7])
          // FENCE
          default: begin
            unique case(funct3)
              3'b000: begin
                en.I = 1'b1;
                op.FENCE = 1'b1;
              end
              default: illegal = 1'b1;
            endcase
          end
          // FENCE.TSO
          25'b1000_0011_0011_00000_000_00000: op.FENCE_TSO = 1'b1;
          // PAUSE
          25'b0000_0001_0000_00000_000_00000: op.PAUSE = 1'b1;
        endcase
      end
      // Ecall Ebreak
      5'b11100: begin
        unique case(inst[31:7])
          // ECALL
          25'b000000000000_00000_000_00000: op.ECALL = 1'b1;
          25'b000000000001_00000_000_00000: op.EBREAK = 1'b1;
          default: illegal = 1'b1;
        endcase
      end
      // Not Implemented
      default: illegal = 1'b1;
    endcase
  end else begin
    illegal = 1'b1;
  end
end

endmodule
