vlog Testbenches/CPUTestbench.sv
vsim -gui work.CPUTestbench

# Clear previous waveforms
restart -force -nowave
destroy wave *

# Add instruction waveforms
add wave clock
add wave -hexadecimal instruction program_counter
add wave -unsigned dut.alu_out {dut.registers.mem[2]} {dut.registers.mem[4]} {dut.registers.mem[5]} {dut.registers.mem[7]}

# Add memory waveforms
add wave memory_write_en
add wave -hexadecimal memory_address
add wave -unsigned memory_read_value memory_write_value

run -all
