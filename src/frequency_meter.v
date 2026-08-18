`timescale 1ns / 1ps

module frequency_meter_top (
    input clk_100mhz,
    input reset,              // BTN0 (G15), active HIGH
    output [3:0] leds
);

    // MEASUREMENT GATE
    // clk_1hz is 1 s HIGH / 1 s LOW. One measurement per 2 s.
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

    wire gate_start = clk_1hz & ~gate_prev;   // clear the counter
    wire gate_end   = ~clk_1hz & gate_prev;   // latch the result

    // TEST SEQUENCER
    // Cycles 120 -> 600 -> 1200 -> 6000 Hz, 10 s each, repeating.
    // Phase changes land on gate_end so no measurement is ever
    // split across two different frequencies.
    reg [1:0]  phase;
    reg [2:0]  gate_count;        // completed gate cycles this phase
    reg [31:0] half_period;

    // half_period = 50_000_000 / desired_frequency
    always @(*) begin
        case (phase)
            2'd0: half_period = 32'd416_666;   //  120 Hz
            2'd1: half_period = 32'd83_333;    //  600 Hz
            2'd2: half_period = 32'd41_666;    // 1200 Hz
            2'd3: half_period = 32'd8_333;     // 6000 Hz
        endcase
    end

    always @(posedge clk_100mhz or posedge reset) begin
        if (reset) begin
            phase      <= 0;
            gate_count <= 0;
        end else if (gate_end) begin
            if (gate_count == 3'd4) begin      // 5 gates x 2 s = 10 s
                gate_count <= 0;
                phase      <= phase + 1'b1;
            end else begin
                gate_count <= gate_count + 1'b1;
            end
        end
    end

    wire phase_change = gate_end & (gate_count == 3'd4);

   
    // TEST SIGNAL GENERATOR
    // Counter is cleared on phase change: without this, a large
    // stale count with a smaller new half_period would miss the
    // == compare and stall until the 32-bit counter wrapped.
  
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

    // COUNT EDGES DURING THE GATE
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
        .reset(reset | gate_start),
        .enable(clk_1hz),
        .pulse_in(edge_pulse),
        .count_out(frequency_count)
    );

    // LATCH AND DISPLAY
    // count_out is packed BCD: 1200 decimal reads as 0x1200,
    // so thresholds are written in hex to match.
    // 4 digits, so the usable range is 0-9999.
  
    reg [31:0] measured_freq;

    always @(posedge clk_100mhz or posedge reset) begin
        if (reset)         measured_freq <= 0;
        else if (gate_end) measured_freq <= frequency_count;
    end

    assign leds[0] = (measured_freq >= 32'h0100);   // >=  100 Hz
    assign leds[1] = (measured_freq >= 32'h0500);   // >=  500 Hz
    assign leds[2] = (measured_freq >= 32'h1000);   // >= 1000 Hz
    assign leds[3] = (measured_freq >= 32'h5000);   // >= 5000 Hz

endmodule