`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Micah Pinto
// 
// Create Date: 11.04.2024 21:13:45
// Design Name: 
// Module Name: data_formatter
// Project Name: 
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

module data_formatter (
    input clk_100mhz,
    input reset,
    input [31:0] frequency,
    output reg [3:0] digit3,
    output reg [3:0] digit2,
    output reg [3:0] digit1,
    output reg [3:0] digit0,
    output reg [1:0] unit,
    output reg [1:0] decimal_position
);

    reg [31:0] scaled_freq;
    reg [1:0] selected_unit;
    reg [1:0] selected_decimal;

    always @(*) begin
        if (frequency >= 1000000) begin
            selected_unit = 2'b10;
            scaled_freq = frequency / 10000;
            selected_decimal = 2'b10;
        end else if (frequency >= 1000) begin
            selected_unit = 2'b01;
            scaled_freq = frequency / 10;
            selected_decimal = 2'b10;
        end else begin
            selected_unit = 2'b00;
            scaled_freq = frequency / 1;
            selected_decimal = 2'b10;
        end
    end

    always @(*) begin
        digit0 = scaled_freq % 10;
        digit1 = (scaled_freq / 10) % 10;
        digit2 = (scaled_freq / 100) % 10;
        digit3 = (scaled_freq / 1000) % 10;
    end

    always @(posedge clk_100mhz or posedge reset) begin
        if (reset) begin
            unit <= 2'b00;
            decimal_position <= 2'b10;
        end else begin
            unit <= selected_unit;
            decimal_position <= selected_decimal;
        end
    end

endmodule
