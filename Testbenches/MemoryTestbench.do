vlog Testbenches/MemoryTestbench.sv
vsim -gui work.MemoryTestbench

# Clear previous waveforms
restart -force -nowave
destroy wave *

# Add current waveforms
add wave clk
add wave -unsigned write_enable
add wave -hexadecimal address write_value read_value

run -all
