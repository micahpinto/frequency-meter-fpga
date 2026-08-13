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
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

module bcd_counter(
    input clk_100mhz,
    input reset,
    input enable,
    output reg [3:0] count,
    output carry
    );
    
    always @(posedge clk_100mhz or posedge reset) begin
        if (reset)
            count <= 4'd0;
        else if (enable) begin
            if (count == 4'd9)
                count <= 4'd0;
            else
                count <= count + 1'b1;
        end
    end
    
    assign carry = (count == 4'd9) & enable;
    
endmodule
