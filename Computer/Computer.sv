`ifndef COMPUTER_COMPUTER_SV
`define COMPUTER_COMPUTER_SV

`include "Computer/CentralProcessingUnit.sv"
`include "Computer/MemoryBock.sv"


module Computer #(CACHE_SIZE = 10, INSTRUCTION_BANK_SIZE = 10)(
  input logic clock,
  input logic reset_n,

);

parameter int CACHE_START = 11;

parameter int IO_START = 12;
parameter int RAM_START = 14;

logic [31:0] instruction;
logic [31:0] program_counter;

logic [31:0] memory_address;
logic [1:0] memory_read_write_size;
logic memory_write_enable;
logic [31:0] memory_write_value;
logic [31:0] memory_read_value;

CentralProcessingUnit cpu(
  .clock(clock),
  .reset_n(reset_n),
  .instruciton(instrction),
  .program_counter(program_counter),
  .memory_address(memory_address),
  .memory_read_write_size(memory_read_write_size),
  .memory_write_enable(memory_write_enable),
  .memory_write_value(memory_write_value),
  .memory_read_value(memory_read_value)
);

logic [CACHE_SIZE-1:0] cache_address;
logic cahce_write_enable;
logic [31:0] cache_read_value;

assign cahce_write_enable = (memory_address[31:CACHE_START] == '0) &&
    (memory_address[CACHE_START-1:CACHE_SIZE] == {(CACHE_START-CACHE_SIZE){1'b1}});

MemoryBlock #(CACHE_SIZE) cache(
  .clock(clock),
  .reset_n(reset_n),
  .address(cache_address),
  .read_write_size(memory_read_write_size),
  .write_enable(cahce_write_enable),
  .write_value(memory_write_value),
  .read_value(cache_read_value)
);

logic [INSTRUCTION_BANK_SIZE-1:0] instruction_address;
logic instruction_bank_write_enable;

assign instruction_address = program_counter[INSTRUCTION_BANK_SIZE-1:0];
assign instruction_bank_write_enable = (memory_address[31:INSTRUCTION_BANK_SIZE] == '0);

MemoryBlock #(.ADDRESS_WIDTH(INSTRUCTION_BANK_SIZE), .ONLY_ALLOW_WORDS(1)) instruction_bank(
  .clock(clock),
  .reset_n(reset_n),
  .address(instruction_address),
  .read_write_size(2'b0),
  .write_enable(instruction_bank_write_enable),
  .write_value(memory_write_value),
  .read_value(instrction)
);

endmodule

`endif