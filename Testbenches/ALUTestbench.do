vsim -gui work.ALUTestbench

# Clear previous waveforms
restart -force -nowave
destroy wave *

# Add current waveforms
add wave -unsigned to_perform input1 input2 measured expected

run -all
