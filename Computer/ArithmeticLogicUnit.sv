`ifndef COMPUTER_ARITHMETICLOGICUNIT_SV
`define COMPUTER_ARITHMETICLOGICUNIT_SV


`include "Constants/Instruction.sv"
`include "BuildingBlocks/BitShiftLeft.sv"
`include "BuildingBlocks/BitShiftRight.sv"


/*
 * Performs integer arithmetic and bit operations on 32-bit numbers.
 *  Has primary inputs and outputs, on which any available operation can be
 *  performed, and has secondary inputs and outputs that compute integer
 *  comparisons in parallel to the primary operations. These secondary
 *  comparisons are used to evaluate conditional branch instructions.
 */
module ArithmeticLogicUnit(
  input InstructionSetALU op,
  input logic [31:0] in1,
  input logic [31:0] in2,
  input logic [31:0] in1_b, // Secondary computation
  input logic [31:0] in2_b, // Secondary computation
  output logic [31:0] out,
  output logic out_b // Secondary computation
);

// Bitwise operation results
logic [31:0] bitwise_and;
logic [31:0] bitwise_or;
logic [31:0] bitwise_xor;

// Addition / subtraction results
logic subtract;
logic [31:0] neg_in2;
logic [31:0] sum;
logic [31:0] diff;
logic sum_overflow;

// Primary input (signed) comparison results
logic sign_in1;
logic sign_in2;
logic adjusted_overflow;
logic signed_comp;

// Logical / arithmetic shift results
logic [4:0] shift_dist;
logic [31:0] left_shift;
logic [31:0] right_shift;

// Secodary input comparisons for checking branch conditions in parallel
logic sign_in1_b;
logic sign_in2_b;
logic signed_comp_b;
logic unsigned_comp_b;
logic equal_b;

// Compute bitwise operations
assign bitwise_and = in1 & in2;
assign bitwise_or = in1 | in2;
assign bitwise_xor = in1 ^ in2;

// Compute addition / subtraction
assign subtract = op.SUB | op.SLT | op.SLTU;
assign neg_in2 = (subtract ? ~in2 : in2);
assign {sum_overflow, sum} = in1 + neg_in2 + subtract;

// Compute primary input comparisons
assign sign_in1 = in1[31];
assign sign_in2 = in2[31];
assign adjusted_overflow = sum_overflow ^ subtract;
assign signed_comp =  (sign_in1 & ~sign_in2) |
                      (sign_in1 & adjusted_overflow) |
                      (~sign_in2 & adjusted_overflow);

// Compute logical / arithmetic shifts
assign shift_dist = in2[4:0];
BitShiftLeft left_shifter(
  .in(in1),
  .amount(shift_dist),
  .fill_value(1'b0),
  .out(left_shift)
);
BitShiftRight right_shifter(
  .in(in1),
  .amount(shift_dist),
  .fill_value(op.SRA & in1[31]),
  .out(right_shift)
);


// Compute secondary comparisons
assign sign_in1_b = in1_b[31];
assign sign_in2_b = in2_b[31];
assign unsigned_comp_b = (in1_b < in2_b);
assign signed_comp_b =  (sign_in1_b & ~sign_in2_b) |
                        (sign_in1_b & unsigned_comp_b) |
                        (~sign_in2_b & unsigned_comp_b);
assign equal_b = (in1_b == in2_b);


// Select primary output based on requested operation
always_comb begin
  unique case(1'b1)
    op.ADD, op.SUB: out = sum;
    op.SLL:         out = left_shift;
    op.SLT:         out = {31'b0, signed_comp};
    op.SLTU:        out = {31'b0, adjusted_overflow};
    op.XOR:         out = bitwise_xor;
    op.SRL, op.SRA: out = right_shift;
    op.OR:          out = bitwise_or;
    op.AND:         out = bitwise_and;
    default:        out = 32'b0;
  endcase
end

// Select secondary output
always_comb begin
  unique case(1'b1)
    op.SLT_B:   out_b = signed_comp_b;
    op.SLTU_B:  out_b = unsigned_comp_b;
    op.SEQ_B:   out_b = equal_b;
    default:    out_b = 1'b0;
  endcase
end

endmodule

`endif
