onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color Magenta -height 25 -radix decimal /iir_tb/x
add wave -noupdate -radix decimal /iir_tb/DUT/validx
add wave -noupdate -color Blue -format Analog-Step -height 74 -max 985553.0 -radix decimal /iir_tb/y
add wave -noupdate -radix unsigned /iir_tb/DUT/ff0gain
add wave -noupdate -radix decimal /iir_tb/DUT/ff1gain
add wave -noupdate -radix decimal /iir_tb/DUT/ff2gain
add wave -noupdate -radix decimal /iir_tb/DUT/fb1gain
add wave -noupdate -radix decimal /iir_tb/DUT/fb2gain
add wave -noupdate -radix decimal /iir_tb/DUT/fb12sum
add wave -noupdate -radix decimal /iir_tb/DUT/ff12sum
add wave -noupdate -radix decimal /iir_tb/DUT/fftotal
add wave -noupdate -radix unsigned /iir_tb/count
add wave -noupdate /iir_tb/DUT/clk
add wave -noupdate /iir_tb/DUT/valid
add wave -noupdate /iir_tb/DUT/rst
add wave -noupdate -radix decimal /iir_tb/DUT/ff1
add wave -noupdate -radix decimal /iir_tb/DUT/ff2
add wave -noupdate -radix decimal /iir_tb/DUT/fb0
add wave -noupdate -radix decimal /iir_tb/DUT/fb1
add wave -noupdate -radix decimal /iir_tb/DUT/fb2
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {23826301514 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 72
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
WaveRestoreZoom {17080291970 ps} {46096970576 ps}
