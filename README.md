# Frequency Meter (Verilog, Spartan-7)
Digital frequency meter for the Digilent Arty S7-25 (Spartan-7). Counts rising edges of an input signal during a one-second gate derived from the 100 MHz board clock, so the count equals the frequency in hertz.

## Background

This was originally a project during my Masters, built in VHDL on a Digilent Nexys A7 (Artix-7). I have rebuilt it here from scratch in Verilog, as a way back into FPGA design, working through each component again rather than relying on what I remembered.

The original specification calls for a range of 1 Hz to 10 MHz,automatic unit selection (Hz, kHz, MHz), four significant digits and a display refreshing every two seconds. 
The first implementation targets the Arty S7-25, which has four discrete LEDs and no on-board display. The measurement logic follows the specification; the output stage instead indicates the measured frequency across four LED thresholds, and the signal under test is generated inside the FPGA, so the design runs with nothing connected to the board.

## Approach

Measurement uses the direct method: rising edges of the input signal are counted during a one-second window, so the count equals the frequency in hertz.
The design keeps the structural approach the specification requires.
Each component is described and simulated individually before integration, there is a single asynchronous reset, and all sequential logic is clocked at 100 MHz.
