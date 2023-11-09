ENSC 462 : Final Project
Nicholas Polyzogopoulos & Brendan Murray
April. 14th. 2022
-----------------------------------------

*File Hierarchy:
project / <folder>
	
	- "StemPlayer" folder contains our vivado project.
		-"/StemPlayer.srcs/sources_1/imports" contains dependent vhdl source code
			-/"Part3" contains our VGA components:
				-video_controller.vhd
				-test_rom_package.vhd
				-res_1080p_package.vhd
			-/"FinalProj" contains our i2s controller:
				-i2s_audio_interface.vhd
		-"\StemPlayer.srcs\constrs_1\imports\Part3" contains our xdc constraints file:
			-top.xdc
	
	-/"src" folder contains the source C code for the application
			-platform.c and platform.h
			-platform_config.h
			-sdCard.c and sdCard.h
			-StemPlayer.c

	- "i2s_controller" folder contains our i2s controller .vhd file, and a testbench 
		for the i2s controller, as well  as modelsim scripts. 
			- The /"debug" folder contains screenshots of the waveforms.
			-i2s_audio_interface.vhd
			-i2s_audio_interface_tb.vhd
			-run.do and wave.do
