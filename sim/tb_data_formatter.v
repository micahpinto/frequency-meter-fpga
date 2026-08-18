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
        frequency = 32'h02000000;
        #100;
        $display("  Display: %d%d%d%d", digit3, digit2, digit1, digit0);
     $display("  Expected: 2000, unit 10 (MHz), decimal after digit 3");
$display("  Got: unit %b, decimal %d\n", unit, decimal_position);
       
      $display("Test 2: 5,542 Hz");
        frequency = 32'h00005542;
        #100;
        $display("  Display: %d%d%d%d", digit3, digit2, digit1, digit0);
       $display("  Expected: 5542, unit 01 (kHz), decimal after digit 3");
        $display("  Got: unit %b, decimal %d\n", unit, decimal_position);
       
        $display("Test 3: 2 Hz");
       frequency = 32'h00000002;
        #100;
        $display("  Display: %d%d%d%d", digit3, digit2, digit1, digit0);
      $display("  Expected: 0002, unit 00 (Hz), no decimal");
        $display("  Got: unit %b, decimal %d\n", unit, decimal_position);
       
      $display("Test 4: 3,500 Hz");
      frequency = 32'h00003500;
        #100;
        $display("  Display: %d%d%d%d", digit3, digit2, digit1, digit0);
      $display("  Expected: 3500, unit 01 (kHz), decimal after digit 3");
        $display("  Got: unit %b, decimal %d\n", unit, decimal_position);
       
      $display("Test 5: 50,485 Hz");
        frequency = 32'h00050485;
        #100;
        $display("  Display: %d%d%d%d", digit3, digit2, digit1, digit0);
       $display("  Expected: 5048, unit 01 (kHz), decimal after digit 2");
        $display("  Got: unit %b, decimal %d\n", unit, decimal_position);
       
        $display(" Test Completed\n");
        $finish;
    end

endmodule
