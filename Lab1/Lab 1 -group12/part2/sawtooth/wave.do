onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /sawtooth_tb/clock
add wave -noupdate /sawtooth_tb/rst
add wave -noupdate /sawtooth_tb/led_out
add wave -noupdate -color {Violet Red} -format Analog-Step -height 100 -max 255.0 -radix unsigned /sawtooth_tb/DUT/Obj2/duty_cycle
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {3019 ps}
