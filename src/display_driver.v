`timescale 1ns / 1ps

module display_driver (
    input clk_100mhz,                 
    input reset,                      
    input [3:0] digit3,               // Thousands digit (leftmost display)
    input [3:0] digit2,               // Hundreds digit
    input [3:0] digit1,               // Tens digit
    input [3:0] digit0,               // Units digit (rightmost display)
    input [1:0] decimal_position,     // Which display shows the decimal point
    output reg [6:0] segments,        // Segment pattern a-g for the active display
    output reg [3:0] anode,           // Display select, active LOW
    output wire dp                    // Decimal point, active HIGH
);

    reg [19:0] refresh_counter;       // Sets how long each display stays lit
    reg [1:0]  display_select_reg;    // Which of the four displays is active
    reg [3:0]  current_digit;         // Digit value routed to the segment decoder

    
    // REFRESH TIMER
    // can be lit at a time. This counter cycles through them fast
    // 2^20 clocks at 100 MHz = 10.5 ms per digit, ~24 Hz per digit
    // and ~95 Hz around the full cycle.
    
    always @(posedge clk_100mhz or posedge reset) begin
        if (reset) begin
            refresh_counter    <= 0;
            display_select_reg <= 0;
        end else begin
            refresh_counter <= refresh_counter + 1;
            if (refresh_counter == 20'hFFFFF) begin   // dwell time elapsed
                refresh_counter    <= 0;
                display_select_reg <= display_select_reg + 1;  // move to next display
            end
        end
    end    
    // DIGIT MUX
    // Selects the inputs and feeds the decoder based on which display is currently active.
  
    always @(*) begin
        case (display_select_reg)
            2'b00:   current_digit = digit0;
            2'b01:   current_digit = digit1;
            2'b10:   current_digit = digit2;
            2'b11:   current_digit = digit3;
            default: current_digit = 0;
        endcase
    end    
    // SEVEN-SEGMENT DECODER
    // Maps a BCD value to its segment pattern, bit order a..g.
    
    always @(*) begin
        case (current_digit)
            4'd0:    segments = 7'b1111110;   // all but g
            4'd1:    segments = 7'b0110000;   // b, c
            4'd2:    segments = 7'b1101101;
            4'd3:    segments = 7'b1111001;
            4'd4:    segments = 7'b0110011;
            4'd5:    segments = 7'b1011011;
            4'd6:    segments = 7'b1011111;
            4'd7:    segments = 7'b1110000;   // a, b, c
            4'd8:    segments = 7'b1111111;   // all segments
            4'd9:    segments = 7'b1111011;
            default: segments = 7'b0000000;   // blank
        endcase
    end
        // ANODE DRIVER
    // Active LOW: the zero bit selects the display that is lit.
    // Exactly one bit is low at a time.
    
    always @(*) begin
        case (display_select_reg)
            2'b00:   anode = 4'b1110;   // display 0 on
            2'b01:   anode = 4'b1101;   // display 1 on
            2'b10:   anode = 4'b1011;   // display 2 on
            2'b11:   anode = 4'b0111;   // display 3 on
            default: anode = 4'b1111;   // all off
        endcase
    end
    // DECIMAL POINT
    // Lit only while the display matching decimal_position is active.
       assign dp = (decimal_position == display_select_reg) ? 1'b1 : 1'b0;

endmodule