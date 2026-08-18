module clock_divider (
    input clk_100mhz, // 100 MHz input clock
    input reset, // Asynchronous reset
    output reg clk_1hz  // 1 Hz output
);

    reg [25:0] counter;  // 26-bit counter register

    always @(posedge clk_100mhz or posedge reset) begin
        if (reset) begin // When reset is active, clear counter & output to 0
            counter <= 0;
            clk_1hz <= 0;
        end else begin
            if (counter == 49_999_999) begin
                counter <= 0;   // Reset counter back to 0
                clk_1hz <= ~clk_1hz; // Toggle the output (flip between 0 and 1)
            end else begin
                counter <= counter + 1; // Increment counter by 1 on each clock cycle
            end
        end
    end

endmodule
