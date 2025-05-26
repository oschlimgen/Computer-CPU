vlog Testbenches/VendingMachine.sv
vsim -gui work.VendingMachineTop

# Clear any current simulations
restart -force -nowave
destroy wave *
add wave -unsigned {vend_cpu.registers.mem[2]} {vend_cpu.registers.mem[4]} {vend_cpu.registers.mem[5]} {vend_cpu.registers.mem[7]}
# Add in waveforms
add wave clk

# Added a waveform to show the 1Hz clock from the assignment
# -----------------------------------------------------------
add wave clock_1Hz
# -----------------------------------------------------------

add wave reset
add wave nickel
add wave dime
add wave refund
add wave vend
add wave nickel_out
add wave dime_out


#Create a repeating clock of 1S

# Modified clock cycle to be 16Hz
# -----------------------------------------------------------
force clk 0 0,1 31.25ms -repeat 62.5ms
# -----------------------------------------------------------

#Set initial input values
force nickel 0
force dime 0
force refund 0

# Force asynchronous reset for 10pS and run for 100ps more. 
# This should be wait for 3 cycles before moving to TB direction
force reset 1
run 250 mS
force reset 0
run 1000ms

# Test vending with refund (should vend and output nickel)
force nickel 1
run 5000ms
force nickel 0
run 1000ms
force dime 1
run 1000ms
force dime 0
run 3000ms

# Check refund with continuous coin input
force dime 1
run 2000ms
force dime 0
force nickel 1
force refund 1
run 1000ms
force refund 0
run 2000ms
force nickel 0
run 3000ms
