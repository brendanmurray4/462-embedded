onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /luminance_tb/DUT/clock
add wave -noupdate /luminance_tb/DUT/rst
add wave -noupdate -radix unsigned /luminance_tb/DUT/pwm_count
add wave -noupdate -format Analog-Step -height 74 -max 73.0 -min 3.0 -radix unsigned /luminance_tb/DUT/duty_cycle
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {79853129161 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 212
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ms
update
WaveRestoreZoom {0 ps} {1052100 us}
