`timescale 1ns / 1ps
// is open. Eight BCD decade counters in cascade give a range of
// 0 to 99,999,999, covering the 1 Hz to 10 MHz specification.
// Each stage is enabled by the carry of the stage below. The carry is
// combinational, so a rollover propagates through all eight stages
// within a single clock cycle and the digits stay consistent.
module frequency_counter (
    input clk_100mhz,         
    input reset,             
    input enable,              
    input pulse_in,            // One-cycle pulse per detected edge
    output [31:0] count_out    // Packed BCD: 1,234,567 reads as 0x01234567
);

    wire [3:0] d0, d1, d2, d3, d4, d5, d6, d7;
    wire c0, c1, c2, c3, c4, c5, c6;

    // Units: the only stage driven by the input signal
    bcd_counter u0 (
        .clk_100mhz(clk_100mhz), .reset(reset),
        .enable(enable & pulse_in),
        .count(d0), .carry(c0)
    );

    // Tens
    bcd_counter u1 (
        .clk_100mhz(clk_100mhz), .reset(reset),
        .enable(c0), .count(d1), .carry(c1)
    );

    // Hundreds
    bcd_counter u2 (
        .clk_100mhz(clk_100mhz), .reset(reset),
        .enable(c1), .count(d2), .carry(c2)
    );

    // Thousands
    bcd_counter u3 (
        .clk_100mhz(clk_100mhz), .reset(reset),
        .enable(c2), .count(d3), .carry(c3)
    );

    // Ten thousands
    bcd_counter u4 (
        .clk_100mhz(clk_100mhz), .reset(reset),
        .enable(c3), .count(d4), .carry(c4)
    );

    // Hundred thousands
    bcd_counter u5 (
        .clk_100mhz(clk_100mhz), .reset(reset),
        .enable(c4), .count(d5), .carry(c5)
    );

    // Millions
    bcd_counter u6 (
        .clk_100mhz(clk_100mhz), .reset(reset),
        .enable(c5), .count(d6), .carry(c6)
    );

    // Ten millions: most significant stage. Its carry is left
    // unconnected, so the counter wraps rather than saturating.
    bcd_counter u7 (
        .clk_100mhz(clk_100mhz), .reset(reset),
        .enable(c6), .count(d7), .carry()
    );

    // Pack digits, most significant first
    assign count_out = {d7, d6, d5, d4, d3, d2, d1, d0};

endmodule