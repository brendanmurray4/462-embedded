onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top_tb/clk
add wave -noupdate -divider BFM
add wave -noupdate -radix unsigned /top_tb/BFM/next_sample
add wave -noupdate -divider DUT
add wave -noupdate /top_tb/DUT/miso
add wave -noupdate /top_tb/DUT/cs
add wave -noupdate /top_tb/DUT/sclk
add wave -noupdate /top_tb/DUT/led_out
add wave -noupdate /top_tb/DUT/ready
add wave -noupdate /top_tb/DUT/valid
add wave -noupdate /top_tb/DUT/state
add wave -noupdate -divider PWM
add wave -noupdate /top_tb/DUT/pwm1/rst
add wave -noupdate -radix unsigned /top_tb/DUT/pwm1/duty_cycle
add wave -noupdate -radix unsigned /top_tb/DUT/pwm1/pwm_count
add wave -noupdate /top_tb/DUT/pwm1/pwm_out
add wave -noupdate -divider {SPI Controller}
add wave -noupdate /top_tb/DUT/spi_controller1/clk
add wave -noupdate /top_tb/DUT/spi_controller1/rst
add wave -noupdate /top_tb/DUT/spi_controller1/cs
add wave -noupdate /top_tb/DUT/spi_controller1/sclk
add wave -noupdate /top_tb/DUT/spi_controller1/miso
add wave -noupdate /top_tb/DUT/spi_controller1/ready
add wave -noupdate /top_tb/DUT/spi_controller1/valid
add wave -noupdate -radix unsigned /top_tb/DUT/spi_controller1/data
add wave -noupdate /top_tb/DUT/spi_controller1/state
add wave -noupdate /top_tb/DUT/spi_controller1/bit_count
add wave -noupdate -divider {Reset Sync}
add wave -noupdate /top_tb/DUT/reset_sync1/clk
add wave -noupdate /top_tb/DUT/reset_sync1/rst_in
add wave -noupdate /top_tb/DUT/reset_sync1/rst_out
add wave -noupdate /top_tb/DUT/reset_sync1/counter
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {68790000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 221
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
WaveRestoreZoom {43517365 ps} {262386232 ps}
