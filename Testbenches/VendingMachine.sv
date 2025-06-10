`include "Computer/CentralProcessingUnit.sv"
`include "Programs/vending.sv"


/*
 * Uses the CPU module and a set of instructions to control vending machine
 *  functionality. The vending machine inputs and outputs are memory-mapped.
 */
module VendingMachineTop(
  input logic clk,
  input logic reset,
  input logic nickel,
  input logic dime,
  input logic quarter,
  input logic refund,
  output logic vend,
  output logic nickel_out,
  output logic dime_out,
  output logic quarter_out
);

logic clock_1Hz; // 1Hz clock signal to add as a waveform for display
// Create 1Hz clock, as described in the assignment (for waveform reference only)
logic [3:0] clock_count;
logic [3:0] clock_count_next;
logic match;
always_ff @(posedge clk, posedge reset) begin
  if(reset)
    clock_count <= '0;
  else begin
    if(match)
      clock_count <= '0;
    else
      clock_count <= clock_count_next;
  end
end
assign clock_count_next = clock_count + 1'b1;
assign match = (clock_count == 4'hf);
assign clock_1Hz = ~clock_count[3];

// Define CPU input and output wires
logic [31:0] instruction;
logic [31:0] program_counter;
// CPU interface with memory
logic [31:0] memory_address;
logic [1:0] memory_read_write_size;
logic memory_write_enable;
logic [31:0] memory_read_value; // Needs to be driven
logic [31:0] memory_write_value;

// Assign instructions to be hard-wired into the vending machine
logic [29:0] instruction_index;
assign instruction_index = program_counter[31:2];
assign instruction = INSTRUCTIONS_VENDING[instruction_index];

// Map vending machine inputs to CPU memory read input
assign memory_read_value[5:0] = (nickel ? 5 : 0) + (dime ? 10 : 0) + (quarter ? 25 : 0);
assign memory_read_value[30:6] = '0; // All the other bits should be zero
assign memory_read_value[31] = refund;

// Create the vending machine cpu unit
CentralProcessingUnit vend_cpu(
  .clock(clk),
  .reset_n(~reset),
  .instruction(instruction),
  .program_counter(program_counter),
  .memory_write_enable(memory_write_enable),
  .memory_read_write_size(memory_read_write_size),
  .memory_address(memory_address),
  .memory_read_value(memory_read_value),
  .memory_write_value(memory_write_value)
);


// Parse CPU memory write output for vending machine outputs
logic nickel_out_mapping;
logic dime_out_mapping;
logic quarter_out_mapping;
logic vend_mapping;
assign nickel_out_mapping = memory_write_value[2] & memory_write_value[0];
assign dime_out_mapping = memory_write_value[3] & memory_write_value[1];
assign quarter_out_mapping = memory_write_value[4] & memory_write_value[3] & memory_write_value[0];
assign vend_mapping = memory_write_value[31];

// Only adjust outputs when a write to memory instruction is recieved from the CPU.
//    Otherwise, should store the previous value. The CPU should write to memory once
//    every 16 clock cycles exactly, generating a new output at a 1Hz frequency.
always_ff @(posedge clk, posedge reset) begin
  if(reset) begin
    nickel_out <= '0;
    dime_out <= '0;
    quarter_out <= '0;
    vend <= '0;
  end else begin
    if(memory_write_enable) begin
      nickel_out <= nickel_out_mapping;
      dime_out <= dime_out_mapping;
      quarter_out <= quarter_out_mapping;
      vend <= vend_mapping;
    end
  end
end

endmodule
