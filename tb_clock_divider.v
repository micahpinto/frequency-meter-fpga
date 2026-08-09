`timescale 1ns / 1ns

module tb_clock_divider;

    reg clk_100mhz;
    reg reset;
    wire clk_1hz;
    
    integer toggle_count; // Counter for number of toggles detected
    reg prev_clk_1hz; // Previous value of clk_1hz to detect changes

    clock_divider uut (
        .clk_100mhz(clk_100mhz),
        .reset(reset),
        .clk_1hz(clk_1hz)
    );
// Clock generation: create 100 MHz clock (10 ns period)
    initial begin
        clk_100mhz = 0;
        forever #5 clk_100mhz = ~clk_100mhz;
    end

    initial begin
        toggle_count = 0; 
        prev_clk_1hz = 0; 
        
        reset = 1;
        #100;
        reset = 0;
        // Run simulation for 100 million clock cycles (1 second)
        repeat(100_000_000) begin
            @(posedge clk_100mhz);
                        if (clk_1hz !== prev_clk_1hz) begin  // Check if clk_1hz has changed (edge detected)
                toggle_count = toggle_count + 1;
                $display("Toggle detected"); // Print message when toggle occurs
                prev_clk_1hz = clk_1hz; // Update previous value for next comparison
            end
        end
        
        $display("Total toggles: %d", toggle_count);
        $finish;
    end

endmodule