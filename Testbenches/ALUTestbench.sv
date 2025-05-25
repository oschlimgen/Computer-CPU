`include "Computer/ArithmeticLogicUnit.sv"

`define TEST_TO 32
`define MAX_ERRORS 10

module ALUTestbench();

int num_errors = 0;

InstructionSetALU to_perform;

logic [31:0] input1;
logic [31:0] input2;
logic [31:0] measured;

logic [31:0] input1_b;
logic [31:0] input2_b;
logic measured_b;

logic [31:0] expected;
logic expected_b;

ArithmeticLogicUnit dut(
  .op(to_perform),
  .in1(input1),
  .in2(input2),
  .in1_b(input1_b),
  .in2_b(input2_b),
  .out(measured),
  .out_b(measured_b)
);


task report_error(string operationName);
  if(measured !== expected || measured_b !== expected_b) begin
    if (num_errors >= `MAX_ERRORS) begin
      $display("Too many errors.  Halting simulation.");
      $stop;
    end
    num_errors++;

    // Print error
    $display("%0tps: %s %2d %2d measured %d expected %d",
      $time, operationName,
      input1, input2,
      measured, expected
    );
  end
endtask

task check_nop(int in1, int in2);
  to_perform = 0;
  expected = 0;
  expected_b = 0;
  #2;
  report_error("NOP");
endtask
task check_add(int in1, int in2);
  to_perform = 0;
  to_perform.ADD = 1;
  expected = in1 + in2;
  expected_b = 0;
  #2;
  report_error("ADD");
endtask
task check_sub(int in1, int in2);
  to_perform = 0;
  to_perform.SUB = 1;
  expected = in1 - in2;
  expected_b = 0;
  #2;
  report_error("SUB");
endtask
task check_sll(int in1, int in2);
  to_perform = 0;
  to_perform.SLL = 1;
  expected = in1 << (unsigned'(in2) % 32);
  expected_b = 0;
  #2;
  report_error("SLL");
endtask
task check_slt(int in1, int in2);
  to_perform = 0;
  to_perform.SLT = 1;
  expected = 0;
  expected[0] = in1 < in2;
  expected_b = 0;
  #2;
  report_error("SLT");
endtask
task check_sltu(int in1, int in2);
  to_perform = 0;
  to_perform.SLTU = 1;
  expected = 0;
  expected[0] = unsigned'(in1) < unsigned'(in2);
  expected_b = 0;
  #2;
  report_error("SLTU");
endtask
task check_xor(int in1, int in2);
  to_perform = 0;
  to_perform.XOR = 1;
  expected = in1 ^ in2;
  expected_b = 0;
  #2;
  report_error("XOR");
endtask
task check_srl(int in1, int in2);
  to_perform = 0;
  to_perform.SRL = 1;
  expected = in1 >> (unsigned'(in2) % 32);
  expected_b = 0;
  #2;
  report_error("SRL");
endtask
task check_sra(int in1, int in2);
  to_perform = 0;
  to_perform.SRA = 1;
  expected = in1 >>> (unsigned'(in2) % 32);
  expected_b = 0;
  #2;
  report_error("SRA");
endtask
task check_or(int in1, int in2);
  to_perform = 0;
  to_perform.OR = 1;
  expected = in1 | in2;
  expected_b = 0;
  #2;
  report_error("OR");
endtask
task check_and(int in1, int in2);
  to_perform = 0;
  to_perform.AND = 1;
  expected = in1 & in2;
  expected_b = 0;
  #2;
  report_error("AND");
endtask

task check_slt_b(int in1, int in2);
  to_perform = 0;
  to_perform.ADD = 1;
  to_perform.SLT_B = 1;
  expected = in1 + in2;
  expected_b = in1 < in2;
  #2;
  report_error("SLT B");
endtask
task check_sltu_b(int in1, int in2);
  to_perform = 0;
  to_perform.ADD = 1;
  to_perform.SLTU_B = 1;
  expected = in1 + in2;
  expected_b = unsigned'(in1) < unsigned'(in2);
  #2;
  report_error("SLTU B");
endtask
task check_seq_b(int in1, int in2);
  to_perform = 0;
  to_perform.ADD = 1;
  to_perform.SEQ_B = 1;
  expected = in1 + in2;
  expected_b = (in1 == in2);
  #2;
  report_error("SEQ B");
endtask


task test_all_operations(int i, int j);
      input1 = i;
      input2 = j;
      input1_b = i;
      input2_b = j;

      check_nop(i, j);
      check_add(i, j);
      check_sub(i, j);
      check_sll(i, j);
      check_slt(i, j);
      check_sltu(i, j);
      check_xor(i, j);
      check_srl(i, j);
      check_sra(i, j);
      check_or(i, j);
      check_and(i, j);

      // Check secondary operations
      check_slt_b(i, j);
      check_sltu_b(i, j);
      check_seq_b(i, j);
endtask

task validate();
  for(int i = 0; i < `TEST_TO; i++) begin
    for(int j = 0; j < `TEST_TO; j++) begin
      test_all_operations(i, j);
    end
    for(int j = -`TEST_TO; j < 0; j++) begin
      test_all_operations(i, j);
    end
  end
  for(int i = -`TEST_TO; i < 0; i++) begin
    for(int j = 0; j < `TEST_TO; j++) begin
      test_all_operations(i, j);
    end
    for(int j = -`TEST_TO; j < 0; j++) begin
      test_all_operations(i, j);
    end
  end
endtask


initial begin
  validate();

  if (num_errors == 0) begin
    $display("ALU module validated successfully!");
  end
  $stop;
end

endmodule