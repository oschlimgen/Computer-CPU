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
force sim:/VendingMachineTop/clk 0 0,1 31.25ms -repeat 62.5ms
# -----------------------------------------------------------

#Set initial input values
force sim:/VendingMachineTop/nickel 0
force sim:/VendingMachineTop/dime 0
force sim:/VendingMachineTop/refund 0

# Force asynchronous reset for 10pS and run for 100ps more. 
# This should be wait for 3 cycles before moving to TB direction
force sim:/VendingMachineTop/reset 1
run 250 mS
force sim:/VendingMachineTop/reset 0
run 1000ms

# This sequence deposits 6 nickels so we should see a vend activation at the end
force sim:/VendingMachineTop/nickel 1
run 1000ms
force sim:/VendingMachineTop/nickel 0
run 1000ms
force sim:/VendingMachineTop/nickel 1
run 1000ms
force sim:/VendingMachineTop/nickel 0
run 1000ms
force sim:/VendingMachineTop/nickel 1
run 1000ms
force sim:/VendingMachineTop/nickel 0
run 1000ms
force sim:/VendingMachineTop/nickel 1
run 1000ms
force sim:/VendingMachineTop/nickel 0
run 1000ms
force sim:/VendingMachineTop/nickel 1
run 1000ms
force sim:/VendingMachineTop/nickel 0
run 1000ms
force sim:/VendingMachineTop/nickel 1
run 1000ms
force sim:/VendingMachineTop/nickel 0
run 1000ms
run 1000ms
run 1000ms

# This sequence deposits 3 nickels then a refund activation. We should see a refund totaling $0.15
force sim:/VendingMachineTop/nickel 1
run 1000ms
force sim:/VendingMachineTop/nickel 0
run 1000ms
force sim:/VendingMachineTop/nickel 1
run 1000ms
force sim:/VendingMachineTop/nickel 0
run 1000ms
force sim:/VendingMachineTop/nickel 1
run 1000ms
force sim:/VendingMachineTop/nickel 0
run 1000ms

force sim:/VendingMachineTop/refund 1
run 1000ms
force sim:/VendingMachineTop/refund 0
run 6000ms