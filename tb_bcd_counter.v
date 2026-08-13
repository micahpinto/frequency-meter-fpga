`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

// By: Micah Pinto
// Module Name: bcd_counter
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
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

module tb_bcd_counter;
    reg clk_100mhz;
    reg reset;
    reg enable;
    wire [3:0] count;
    wire carry;
    
    bcd_counter uut (
        .clk_100mhz(clk_100mhz),
        .reset(reset),
        .enable(enable),
        .count(count),
        .carry(carry)
    );
    
    initial begin
        clk_100mhz = 0;
        forever #5 clk_100mhz = ~clk_100mhz;
    end
    
    initial begin
        reset = 1;
        enable = 0;
        #100;
        reset = 0;
        enable = 1;
        
        $display("\n=== BCD Counter Test ===\n");
        $display("Counting 0 to 9:");
        
        repeat(10) begin
            $display("  Count: %d, Carry: %b", count, carry);
            #10;
        end
        
        $display("\nCycle 2: Counting again");
        repeat(10) begin
            $display("  Count: %d, Carry: %b", count, carry);
            #10;
        end
        
        $display("\n✓ Test Complete!\n");
        $finish;
    end

endmodule
