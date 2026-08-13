`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Micah Pinto
// 
// Create Date: 11.04.2024 21:14:56
// Design Name: 
// Module Name: tb_data_formatter
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


`timescale 1ns / 1ns

module tb_data_formatter;

    reg clk_100mhz;
    reg reset;
    reg [31:0] frequency;
    wire [3:0] digit3, digit2, digit1, digit0;
    wire [1:0] unit;
    wire [1:0] decimal_position;
   
    data_formatter uut (
        .clk_100mhz(clk_100mhz),
        .reset(reset),
        .frequency(frequency),
        .digit3(digit3),
        .digit2(digit2),
        .digit1(digit1),
        .digit0(digit0),
        .unit(unit),
        .decimal_position(decimal_position)
    );
   
    initial begin
        clk_100mhz = 0;
        forever #5 clk_100mhz = ~clk_100mhz;
    end
   
    initial begin
        reset = 1;
        frequency = 0;
        #100;
        reset = 0;
       
        $display("\n=== Data Formatter Test ===\n");
       
      $display("Test 1: 2,000,000 Hz");
        frequency = 2000000;
        #100;
        $display("  Display: %d%d%d%d", digit3, digit2, digit1, digit0);
      $display("  Unit: %b (10=MHz), Decimal Position:Before 2 digits (%b)\n", unit, decimal_position);
       
      $display("Test 2: 5,542 Hz");
        frequency = 5542;
        #100;
        $display("  Display: %d%d%d%d", digit3, digit2, digit1, digit0);
      $display("  Unit: %b (01=KHz), Decimal Position:Before 2 digits (%b)\n", unit, decimal_position);
       
        $display("Test 3: 2 Hz");
        frequency = 2;
        #100;
        $display("  Display: %d%d%d%d", digit3, digit2, digit1, digit0);
      $display("  Unit: %b (00=Hz), Decimal Position:Before 2 digits (%b)\n", unit, decimal_position);
       
      $display("Test 4: 3,500 Hz");
        frequency = 3500;
        #100;
        $display("  Display: %d%d%d%d", digit3, digit2, digit1, digit0);
      $display("  Unit: %b (01=KHz), Decimal Position:Before 2 digits (%b)\n", unit, decimal_position);
       
      $display("Test 5: 50,485 Hz");
        frequency = 50485;
        #100;
        $display("  Display: %d%d%d%d", digit3, digit2, digit1, digit0);
      $display("  Unit: %b (01=KHz), Decimal Position:Before 2 digits (%b)\n", unit, decimal_position);
       
        $display(" Test Complete\n");
        $finish;
    end

endmodule
