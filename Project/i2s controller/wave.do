onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /i2s_audio_interface_tb/clk
add wave -noupdate /i2s_audio_interface_tb/bclk
add wave -noupdate -color Cyan -itemcolor Cyan /i2s_audio_interface_tb/lrclk
add wave -noupdate /i2s_audio_interface_tb/sdata_out
add wave -noupdate /i2s_audio_interface_tb/S_AXIS_ARESETN
add wave -noupdate /i2s_audio_interface_tb/S_AXIS_TVALID
add wave -noupdate /i2s_audio_interface_tb/S_AXIS_TLAST
add wave -noupdate -radix hexadecimal /i2s_audio_interface_tb/S_AXIS_TDATA
add wave -noupdate /i2s_audio_interface_tb/S_AXIS_TREADY
add wave -noupdate -divider DUT
add wave -noupdate -color Magenta /i2s_audio_interface_tb/DUT/S_AXIS_ACLK
add wave -noupdate /i2s_audio_interface_tb/DUT/S_AXIS_ARESETN
add wave -noupdate /i2s_audio_interface_tb/DUT/S_AXIS_TVALID
add wave -noupdate /i2s_audio_interface_tb/DUT/S_AXIS_TLAST
add wave -noupdate -radix hexadecimal /i2s_audio_interface_tb/DUT/S_AXIS_TDATA
add wave -noupdate /i2s_audio_interface_tb/DUT/S_AXIS_TREADY
add wave -noupdate /i2s_audio_interface_tb/DUT/bclk
add wave -noupdate -color Cyan -itemcolor Cyan /i2s_audio_interface_tb/DUT/lrclk
add wave -noupdate /i2s_audio_interface_tb/DUT/bclk_p
add wave -noupdate /i2s_audio_interface_tb/DUT/lrclk_p
add wave -noupdate -divider dBuffer
add wave -noupdate -color Blue -itemcolor Blue /i2s_audio_interface_tb/DUT/state_dbuffer_read
add wave -noupdate /i2s_audio_interface_tb/DUT/dbuffer_filled
add wave -noupdate -radix hexadecimal /i2s_audio_interface_tb/DUT/dbuffer
add wave -noupdate /i2s_audio_interface_tb/DUT/packet_count
add wave -noupdate /i2s_audio_interface_tb/DUT/p_packet_count
add wave -noupdate /i2s_audio_interface_tb/DUT/dbuffer_transfer
add wave -noupdate -divider pBuffer
add wave -noupdate -color Blue -itemcolor Blue /i2s_audio_interface_tb/DUT/state_out
add wave -noupdate /i2s_audio_interface_tb/DUT/bit_out
add wave -noupdate /i2s_audio_interface_tb/DUT/pbuffer_empty
add wave -noupdate -radix hexadecimal /i2s_audio_interface_tb/DUT/pbuffer
add wave -noupdate /i2s_audio_interface_tb/DUT/packet_cnt
add wave -noupdate -divider output
add wave -noupdate /i2s_audio_interface_tb/DUT/sdata_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1619149554 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 286
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
WaveRestoreZoom {1278105345 ps} {1858389888 ps}
