# 100 MHz clock
set_property -dict { PACKAGE_PIN R2   IOSTANDARD LVCMOS33 } [get_ports clk_100mhz]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk_100mhz]

# BTN0 as reset (active HIGH: low at rest, high when pressed)
set_property -dict { PACKAGE_PIN G15  IOSTANDARD LVCMOS33 } [get_ports reset]

# LEDs LD2-LD5
set_property -dict { PACKAGE_PIN E18  IOSTANDARD LVCMOS33 } [get_ports {leds[0]}]
set_property -dict { PACKAGE_PIN F13  IOSTANDARD LVCMOS33 } [get_ports {leds[1]}]
set_property -dict { PACKAGE_PIN E13  IOSTANDARD LVCMOS33 } [get_ports {leds[2]}]
set_property -dict { PACKAGE_PIN H15  IOSTANDARD LVCMOS33 } [get_ports {leds[3]}]
