`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Micah Pinto
// Design Name: 
// Module Name: edge_detector
// Project Name: frequency_meter
// Description: 
// 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module edge_detector(
    input clk_100mhz,
    input reset,
    input signal_in,
    output edge_pulse
    );
     // Stage 1: Synchronize input to clock domain
    reg sync1;
    // Stage 2: Delay for edge detection
    reg sync2;
    // Stage 3: Delay for comparison
    reg sync3;

    // Synchronize the input signal through 3 registers
    always @(posedge clk_100mhz or posedge reset) begin
        if (reset) begin
            // Clear all stages on reset
            sync1 <= 0;
            sync2 <= 0;
            sync3 <= 0;
        end else begin
            // Pipeline: input -> sync1 -> sync2 -> sync3
            sync1 <= signal_in;   // Capture input
            sync2 <= sync1;       // Delay one cycle
            sync3 <= sync2;       // Delay another cycle
        end
    end

    // Detect rising edge: sync2 is 1 AND sync3 is 0
    // This means signal just went from 0 to 1
    assign edge_pulse = sync2 & ~sync3;

endmodule
