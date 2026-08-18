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
// Split the packed value into individual digits.
    wire [3:0] d0 = frequency[3:0];
    wire [3:0] d1 = frequency[7:4];
    wire [3:0] d2 = frequency[11:8];
    wire [3:0] d3 = frequency[15:12];
    wire [3:0] d4 = frequency[19:16];
    wire [3:0] d5 = frequency[23:20];
    wire [3:0] d6 = frequency[27:24];
    wire [3:0] d7 = frequency[31:28];
     reg [3:0] sel3, sel2, sel1, sel0;
    reg [1:0] sel_unit, sel_decimal;
 // Pick the four most significant digits that carry information
    // and set the unit and decimal point to match.
    always @(*) begin
        if (d7 != 0) begin                      // 10 to 99 MHz
            sel3 = d7; sel2 = d6; sel1 = d5; sel0 = d4;
            sel_unit = 2'b10; sel_decimal = 2'd2;
        end else if (d6 != 0) begin             // 1 to 9 MHz
            sel3 = d6; sel2 = d5; sel1 = d4; sel0 = d3;
            sel_unit = 2'b10; sel_decimal = 2'd3;
        end else if (d5 != 0) begin             // 100 to 999 kHz
            sel3 = d5; sel2 = d4; sel1 = d3; sel0 = d2;
            sel_unit = 2'b01; sel_decimal = 2'd1;
        end else if (d4 != 0) begin             // 10 to 99 kHz
            sel3 = d4; sel2 = d3; sel1 = d2; sel0 = d1;
            sel_unit = 2'b01; sel_decimal = 2'd2;
        end else if (d3 != 0) begin             // 1 to 9 kHz
            sel3 = d3; sel2 = d2; sel1 = d1; sel0 = d0;
            sel_unit = 2'b01; sel_decimal = 2'd3;
        end else begin                          // 0 to 999 Hz
            sel3 = d3; sel2 = d2; sel1 = d1; sel0 = d0;
            sel_unit = 2'b00; sel_decimal = 2'd0;
        end
    end
    
    always @(posedge clk_100mhz or posedge reset) begin
        if (reset) begin
             digit3 <= 0; digit2 <= 0; digit1 <= 0; digit0 <= 0;
            unit <= 2'b00; decimal_position <= 2'd0;
        end else begin
             digit3 <= sel3; digit2 <= sel2; digit1 <= sel1; digit0 <= sel0;
            unit <= sel_unit; decimal_position <= sel_decimal;
        end
    end

endmodule
