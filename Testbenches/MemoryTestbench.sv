`include "Computer/MemoryBlock.sv"


module MemoryTestbench();

parameter int SIZE = 10;

logic clk;
logic reset_n;
logic [SIZE-1:0] address;
logic [1:0] read_write_size;
logic write_enable;
logic [31:0] write_value;
logic [31:0] read_value;

MemoryBlock #(.ADDRESS_WIDTH(SIZE), .ONLY_ALLOW_WORDS(0)) dut(
  .clk(clk),
  .reset_n(reset_n),
  .address(address),
  .read_write_size(read_write_size),
  .write_enable(write_enable),
  .write_value(write_value),
  .read_value(read_value)
);


bit [31:0] memory_image [0:(1<<(SIZE-2))-1];

task createMemoryImage();
  for(int i = 0; i < 1<<(SIZE-2); i++) begin
    memory_image[i] = $urandom();
  end
endtask

always begin
  clk = 1'b0;
  #5;
  clk = 1'b1;
  #5;
end

task clear();
  reset_n = 1'b0;
  #10;
  reset_n = 1'b1;
endtask

// Check the write functionality of the memory block
task loadMemoryImage();
  bit [31:0] random;
  int load_size;

  random = '0;
  for(int i = 0; i < 1<<(SIZE-2); i++) begin
    // Choose a method of loading the word
    random = random >> 2;
    while(random[1:0] == 2'b11) begin
      random = $urandom();
    end
    load_size = 1<<random[1:0];

    // Load 32 bits
    write_enable = 1'b1;
    read_write_size = random[1:0];
    for(int j = 0; j < 4; j += load_size) begin
      address = 4*i + j;
      write_value = memory_image[i] >> (8*j);
      #10;
    end

    // Validate the write was correct
    write_enable = 1'b0;
    read_write_size = 2'b10; // read full word
    address = 4*i;
    #10;
    if(read_value !== memory_image[i]) begin
      $display("Expected %h from memory read, but got %h.", memory_image[i], read_value);
      $stop();
    end
  end
endtask

// Check the read functionality of the memory block
task verifyMemoryImage();
  bit [31:0] random;
  int load_size;
  logic [31:0] read_mask;
  logic [31:0] expected_read_value;

  write_enable = 1'b0;
  write_value = 32'b0;

  random = '0;
  for(int i = 0; i < 1<<(SIZE-2); i++) begin
    // Choose a method of loading the word
    random = random >> 2;
    while(random[1:0] == 2'b11) begin
      random = $urandom();
    end
    load_size = 1<<random[1:0];

    // Load 32 bits
    read_write_size = random[1:0];
    for(int j = 0; j < 4; j += load_size) begin
      address = 4*i + j;
      #10;

      case(read_write_size)
      2'b00: read_mask = {24'b0, {8{1'b1}}};
      2'b01: read_mask = {16'b0, {16{1'b1}}};
      2'b10: read_mask = {32{1'b1}};
      endcase
      expected_read_value = read_mask & (memory_image[i] >> (8*j));

      if(read_value !== expected_read_value) begin
        $display("Expected %h from memory read, but got %h.", expected_read_value, read_value);
        $stop();
      end
    end
  end
endtask


initial begin
  createMemoryImage();
  $display("\n\n");

  clear();
  loadMemoryImage();
  verifyMemoryImage();

  $display("Memory design successfully validated!");
  $stop;
end


endmodule
