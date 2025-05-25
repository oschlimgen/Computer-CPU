`include "Computer/CentralProcessingUnit.sv"
`include "Programs/vending.sv"

`define HALT 32'b0000_0000_0001_00000_000_00000_1110011
`define EXCEPTION 32'b0000_0000_0000_00000_000_00000_1110011
`define MAX_INSTRUCTIONS 'h100

`define PROGRAM_TO_RUN INSTRUCTIONS_VENDING


module CPUTestbench();

logic clock;
logic reset_n;
logic [31:0] instruction;
logic [31:0] program_counter;
// Interface with memory
logic memory_write_en;
logic [31:0] memory_address;
logic [31:0] memory_read_value; // Needs to be driven by this testbench
logic [31:0] memory_write_value;

logic [29:0] instruction_index;
assign instruction_index = program_counter[31:2];
assign instruction = `PROGRAM_TO_RUN[instruction_index];

assign memory_read_value = 'b00101;

CentralProcessingUnit dut(
  .clock(clock),
  .reset_n(reset_n),
  .instruction(instruction),
  .program_counter(program_counter),
  .memory_write_en(memory_write_en),
  .memory_address(memory_address),
  .memory_read_value(memory_read_value),
  .memory_write_value(memory_write_value)
);

always begin
  clock = 1'b0;
  #5;
  clock = 1'b1;
  #5;
end

task clear();
  reset_n = 1'b0;
  #10;
  reset_n = 1'b1;
endtask

task executeProgram();
  if(instruction_index >= $size(`PROGRAM_TO_RUN)) begin
    $display("Error: No instruction at address 0x%h (index %d).", program_counter, instruction_index);
    $stop;
  end
  if(instruction == `HALT) begin
    $display("Recieved instruction EBREAK at index %d. Stopping execution...", instruction_index);
    $stop;
  end
  if(instruction == `EXCEPTION) begin
    $display("Recieved instruction ECALL (exception throw) at index %d. Stopping execution...", instruction_index);
    $stop;
  end
  #10;
  if(memory_write_en) begin
    $display("Write at address 0x%h: %d", memory_address, memory_write_value);
  end
endtask

initial begin
  $display("\n\n");

  clear();
  for(int i = 0; i < `MAX_INSTRUCTIONS; i++) begin
    executeProgram();
  end

  $display("Instruction execution limit reached. Stopping execution...");
  $stop;
end

endmodule
