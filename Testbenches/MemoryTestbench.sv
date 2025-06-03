`include "Computer/MemoryBlock.sv"


module MemoryTestbench();

parameter int SIZE = 10;

logic clk;
logic reset_n;
logic [SIZE-1:0] address;
logic [1:0] write_enable;
logic [31:0] write_value;
logic [31:0] read_value;

MemoryBlock #(SIZE) dut(
  .clk(clk),
  .reset_n(reset_n),
  .address(address),
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
    while(random[1:0] == 2'b00) begin
      random = $urandom();
    end
    load_size = 1<<(random[1:0]-2'b01);

    // Load 32 bits
    write_enable = random[1:0];
    for(int j = 0; j < 4; j += load_size) begin
      address = 4*i + j;
      write_value = memory_image[i] >> (8*j);
      #10;
    end

    // Validate the write was correct
    write_enable = 2'b00;
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
  write_enable = 2'b00;
  write_value = 32'b0;
  for(int i = 0; i < 1<<(SIZE-2); i++) begin
    address = 4*i + 1; // Offset read address to ensure read is always word-aligned
    #10;
    if(read_value !== memory_image[i]) begin
      $display("Expected %h from memory read, but got %h.", memory_image[i], read_value);
      $stop();
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
