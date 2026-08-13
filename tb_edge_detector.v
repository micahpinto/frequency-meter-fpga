`timescale 1ns / 1ns

module tb_edge_detector;

    // Test signals
    reg clk_100mhz;        // 100 MHz clock
    reg reset;             // Reset signal
    reg signal_in;         // Input signal to measure
    wire edge_pulse;       // Edge detected output
    
    // Test counters
    integer edge_count;    // Count of edges detected
    
    // Instantiate edge detector
    edge_detector uut (
        .clk_100mhz(clk_100mhz),
        .reset(reset),
        .signal_in(signal_in),
        .edge_pulse(edge_pulse)
    );
    
    // Generate 100 MHz clock (10 ns period)
    initial begin
        clk_100mhz = 0;
        forever #5 clk_100mhz = ~clk_100mhz;
    end
    
    // Main test
    initial begin
        // Initialize
        edge_count = 0;
        signal_in = 0;
        
        // Apply reset
        reset = 1;
        #100;
        reset = 0;
        $display("=== Edge Detector Test ===");
        
        // Test Case 1: First rising edge (0 -> 1)
        $display("Test 1: Rising edge (0 -> 1)");
        #100;
        signal_in = 1;
        #100
        
        // Test Case 2: Falling edge (1 -> 0) - should NOT detect
        $display("Test 2: Falling edge - should NOT trigger");
        signal_in = 0;
        #100
        
        // Test Case 3: Another rising edge
        $display("Test 3: Another rising edge");
        signal_in = 1;
        #100
        
        // Test Case 4: Multiple quick edges
        $display("Test 4: Multiple edges");
        signal_in = 0;
        #100
        signal_in = 1;
        #100
        signal_in = 0;
        #100
        signal_in = 1;
        #100
        
        // Print results
        $display("\n Results");
        $display("Total edges detected: %d", edge_count);
        $display("Expected: 4 rising edges\n");
        
        if (edge_count == 4) begin
            $display("TEST PASSED\n");
        end else begin
            $display("TEST FAILED\n");
        end
        
    end
    
    // Monitor for edge pulses
    always @(posedge clk_100mhz) begin
        if (edge_pulse) begin
            edge_count = edge_count + 1;
            $display("  -> Edge #%d detected at time %d ns", edge_count, $time);
        end
    end
   

endmodule