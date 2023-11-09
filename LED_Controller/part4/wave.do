onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /final_controller_tb/sawtooth_enable
add wave -noupdate /final_controller_tb/breathing_enable
add wave -noupdate /final_controller_tb/clk
add wave -noupdate /final_controller_tb/rst
add wave -noupdate -format Analog-Step -max 255.0 -radix unsigned /final_controller_tb/led_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {107875135 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 240
configure wave -valuecolwidth 60
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
WaveRestoreZoom {0 ps} {336000021 ns}
