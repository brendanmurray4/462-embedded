onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /spi_controller_tb/clk
add wave -noupdate /spi_controller_tb/rst
add wave -noupdate -divider BFM
add wave -noupdate /spi_controller_tb/BFM/next_sample
add wave -noupdate -divider DUT
add wave -noupdate /spi_controller_tb/DUT/cs
add wave -noupdate /spi_controller_tb/DUT/sclk
add wave -noupdate /spi_controller_tb/DUT/miso
add wave -noupdate /spi_controller_tb/DUT/ready
add wave -noupdate /spi_controller_tb/DUT/valid
add wave -noupdate /spi_controller_tb/DUT/data
add wave -noupdate /spi_controller_tb/DUT/bit_count
add wave -noupdate /spi_controller_tb/DUT/state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 226
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
WaveRestoreZoom {0 ps} {925 ps}
