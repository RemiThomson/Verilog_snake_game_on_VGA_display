module TargetGenerator(
    input CLK,
    input RESET,
    input ReachedTarget,
    output reg [9:0] TargetX,
    output reg [8:0] TargetY
);

    // LFSR for X and Y target coordinates
    reg [7:0] lfsr_x;               // 8-bit LFSR for X (horizontal position)
    reg [6:0] lfsr_y;               // 7-bit LFSR for Y (vertical position)
    wire feedback_x = (lfsr_x[7] ~^ lfsr_x[5] ~^ lfsr_x[4] ~^ lfsr_x[3]);
    wire feedback_y = (lfsr_y[6] ~^ lfsr_y[5]);

    // Generate new LFSR values on each clock cycle
    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            lfsr_x <= 8'b00000001;
            lfsr_y <= 7'b0000001;
        end else begin
            lfsr_x <= {lfsr_x[6:0], feedback_x};
            lfsr_y <= {lfsr_y[5:0], feedback_y};
        end
    end

    // Update TargetX and TargetY when ReachedTarget is asserted
    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            TargetX <= 100;        // Initial position (for testing)
            TargetY <= 100;
        end else if (ReachedTarget) begin
            // Randomize target position using LFSR values within screen bounds
            TargetX <= (lfsr_x % 63) * 10;   // Adjust to fit the horizontal resolution, e.g., 630 pixels max
            TargetY <= (lfsr_y % 48) * 10;   // Adjust to fit the vertical resolution, e.g., 480 pixels max
        end
    end
endmodule
