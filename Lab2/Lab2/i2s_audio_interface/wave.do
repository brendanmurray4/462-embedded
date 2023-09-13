onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /i2s_audio_interface_tb/clk
add wave -noupdate /i2s_audio_interface_tb/lrclk
add wave -noupdate /i2s_audio_interface_tb/bclk
add wave -noupdate /i2s_audio_interface_tb/sdata_in
add wave -noupdate /i2s_audio_interface_tb/sdata_out
add wave -noupdate /i2s_audio_interface_tb/DUT/audio_l_pl
add wave -noupdate /i2s_audio_interface_tb/DUT/audio_r_pl
add wave -noupdate /i2s_audio_interface_tb/DUT/audio_valid_pl
add wave -noupdate /i2s_audio_interface_tb/DUT/samp_bit_countRX
add wave -noupdate /i2s_audio_interface_tb/DUT/rx_state
add wave -noupdate /i2s_audio_interface_tb/DUT/samp_bit_countTX
add wave -noupdate /i2s_audio_interface_tb/DUT/tx_state
add wave -noupdate /i2s_audio_interface_tb/DUT/audio_tx_sig
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {31388438 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 275
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
configure wave -timelineunits sec
update
WaveRestoreZoom {30859941 ps} {38523149 ps}
