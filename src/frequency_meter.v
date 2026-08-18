`timescale 1ns / 1ps
// FREQUENCY METER - TOP LEVEL
// Target: Digilent Arty S7-25 (Spartan-7 XC7S25)
//
// Measures frequency by the direct method: count rising edges of
// the input signal during a one-second window derived from the
// 100 MHz board clock.
module frequency_meter_top (
    input clk_100mhz,          
    input reset,               // BTN0 (G15), active high, asynchronous
    output [3:0] leds          // LD2-LD5, threshold indicators
);

    // MEASUREMENT GATE
    // clk_1hz is high for one second, low for one second. Its
    // rising edge clears the counter and its falling edge latches
    // the result, so a measurement completes every two seconds.
    // ========================================================
    wire clk_1hz;

    clock_divider clk_div (
        .clk_100mhz(clk_100mhz),
        .reset(reset),
        .clk_1hz(clk_1hz)
    );

    reg gate_prev;
    always @(posedge clk_100mhz or posedge reset) begin
        if (reset) gate_prev <= 0;
        else       gate_prev <= clk_1hz;
    end

    wire gate_start = clk_1hz & ~gate_prev;   // window opens
    wire gate_end   = ~clk_1hz & gate_prev;   // window closes

    // TEST SEQUENCER
    // Steps through four frequencies, ten seconds each, then
    // repeats. Phase changes are aligned to the gate closing so
    // no measurement window spans two frequencies.
    reg [1:0]  phase;
    reg [2:0]  gate_count;
    reg [31:0] half_period;

    // half_period = 50,000,000 / desired frequency
    always @(*) begin
        case (phase)
            2'd0: half_period = 32'd166_666;   //300 Hz
            2'd1: half_period = 32'd1_000;     //50 kHz
            2'd2: half_period = 32'd100;       //500 kHz
            2'd3: half_period = 32'd25;        //2 MHz
        endcase
    end

    always @(posedge clk_100mhz or posedge reset) begin
        if (reset) begin
            phase      <= 0;
            gate_count <= 0;
        end else if (gate_end) begin
            if (gate_count == 3'd4) begin      // 5 windows x 2s = 10s
                gate_count <= 0;
                phase      <= phase + 1'b1;
            end else begin
                gate_count <= gate_count + 1'b1;
            end
        end
    end

    wire phase_change = gate_end & (gate_count == 3'd4);

    // TEST SIGNAL GENERATOR
    // Toggles every half_period clocks, giving a square wave at
    // 50,000,000 / half_period Hz.
    
    // The counter is cleared on a phase change. Without this, a
    // residual count larger than the new half_period would never
    // satisfy the equality test and the generator would stall
    // until the 32-bit counter wrapped.
    reg [31:0] test_counter;
    reg        test_signal;

    always @(posedge clk_100mhz or posedge reset) begin
        if (reset) begin
            test_counter <= 0;
            test_signal  <= 0;
        end else if (phase_change) begin
            test_counter <= 0;
            test_signal  <= 0;
        end else if (test_counter == half_period - 1) begin
            test_counter <= 0;
            test_signal  <= ~test_signal;
        end else begin
            test_counter <= test_counter + 1;
        end
    end
    // EDGE DETECTION AND COUNTING

    wire edge_pulse;

    edge_detector edge_det (
        .clk_100mhz(clk_100mhz),
        .reset(reset),
        .signal_in(test_signal),
        .edge_pulse(edge_pulse)
    );

    wire [31:0] frequency_count;

    frequency_counter freq_cnt (
        .clk_100mhz(clk_100mhz),
        .reset(reset | gate_start),   // cleared at the start of each window
        .enable(clk_1hz),
        .pulse_in(edge_pulse),
        .count_out(frequency_count)
    );

    // RESULT LATCH AND LED THRESHOLDS
    // count_out is packed BCD, so 500,000 decimal reads as
    // 0x00500000 and the thresholds are written in hex to match.
    // Eight decades, so the range is 0 to 99,999,999.
    reg [31:0] measured_freq;

    always @(posedge clk_100mhz or posedge reset) begin
        if (reset)         measured_freq <= 0;
        else if (gate_end) measured_freq <= frequency_count;
    end

    assign leds[0] = (measured_freq >= 32'h00000100);   // >= 100 Hz
    assign leds[1] = (measured_freq >= 32'h00010000);   // >= 10 kHz
    assign leds[2] = (measured_freq >= 32'h00100000);   // >= 100 kHz
    assign leds[3] = (measured_freq >= 32'h01000000);   // >= 1 MHz

endmodule