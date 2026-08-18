`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Micah PINTO
// 
// Create Date: 01.02.2024 19:38:31
// Design Name: 
// Module Name: frequency_counter
// Project Name: frequency_meter
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module frequency_counter (
    input clk_100mhz,          
    input reset,               
    input enable,              
    input pulse_in,            // One-cycle pulse from the edge detector, one per input edge
    output [31:0] count_out    // Result as packed BCD: 1234 decimal reads as 0x1234
);

    // Digit outputs from each decade, and the carries that chain them together
    wire [3:0] ones, tens, hundreds, thousands;
    wire carry_ones, carry_tens, carry_hundreds;

    // Units digit: the only stage driven by the input signal.
    // Increments when the gate is open AND an edge arrives this cycle.
    bcd_counter ones_counter (
        .clk_100mhz(clk_100mhz),
        .reset(reset),
        .enable(enable & pulse_in),
        .count(ones),
        .carry(carry_ones)
    );

    // Tens digit: advances when the units digit completes a decade.
    // The carry is combinational, so this increments on the same clock
    // edge that takes the units digit from 9 back to 0.
    bcd_counter tens_counter (
        .clk_100mhz(clk_100mhz),
        .reset(reset),
        .enable(carry_ones),
        .count(tens),
        .carry(carry_tens)
    );

    // Hundreds digit: advances when the tens digit completes a decade
    bcd_counter hundreds_counter (
        .clk_100mhz(clk_100mhz),
        .reset(reset),
        .enable(carry_tens),
        .count(hundreds),
        .carry(carry_hundreds)
    );

    // Thousands digit: most significant stage.
    // Its carry is left unconnected, so the counter wraps past 9999
    // rather than saturating. This sets the upper measurement limit.
    bcd_counter thousands_counter (
        .clk_100mhz(clk_100mhz),
        .reset(reset),
        .enable(carry_hundreds),
        .count(thousands),
        .carry()
    );

    assign count_out = {thousands, hundreds, tens, ones};

endmodule