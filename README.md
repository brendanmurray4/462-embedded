# 462-embedded
This repository stores the source code written by Brendan Murray and Nicholas Polyzogopoulos from January to May 2022 for ENSC 462 @ SFU.

VHDL and C were written in tandem to create and operate various hardware blocks and bare-metal software that ran on a Xilinx FPGA.

## I2S_Audio_Interface
An I2S interface for processing an audio signal and filtering it with an IIR filter. Both high-pass and low-pass filters were created.

## LED_Controller
Designed in a multi-step process to allow various different lighting animations such as sinusoidal and sawtooth duty cycles to be displayed on an LED.

## SPI_Controller
An SPI controller for communicating in the SPI protocol. Incorporates previous components such as pulse-width modulation and prescalar.

## StemPlayer
A Stem Player designed to concurrently play different wav files at the same time with separate controls. Includes bare-metal software for SD card reading designed to run on the Xilinx SoC.

## VGA_Controller
A VGA controller for writing pixels to a monitor through VGA. Includes a test ROM package that displays a test rainbow animation on the screen.
