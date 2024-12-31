module SnakeControl(
    input CLK,                      // Clock input
    input RESET,                    // Reset input
    input CURRENT_MODE,             // Mode of the game (e.g., play or paused)
    input [9:0] X,                  // Horizontal address of the current pixel
    input [8:0] Y,                  // Vertical address of the current pixel
    input [9:0] ADDRH,
    input [8:0] ADDRV,
    input [9:0] TargetX,
    input [8:0] TargetY,
    input [1:0] DIRECTION,          // Direction the snake is moving (up, down, left, right)
    output reg ReachedTarget,       // Asserted when snake reaches the target
    output reg [11:0] COLOUR_IN,    // Color output
    output reg ENABLE
);

    // Parameters
    parameter MaxX = 640;
    parameter MaxY = 480;
    parameter SquareSize = 10;
    parameter RED = 12'hF00;
    parameter GREEN = 12'h0F0;
    parameter YELLOW = 12'hFF0;
    parameter BLUE = 12'h00F;
    parameter WHITE = 12'hFFF;
    parameter ENABLE_DURATION = 1_000_000; 

    // Snake position registers
    reg [9:0] SnakeX[4:0];
    reg [8:0] SnakeY[4:0];

    // Slow movement counter and enable timer
    reg [23:0] slow_counter;
    reg [28:0] enable_timer;        // Timer for the 3-second enable duration

    // Variable for looping
    integer i;

    // Initialize/reset snake position and enable timer
    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            // Initialize snake segments in the middle
            SnakeX[0] <= MaxX / 2;
            SnakeY[0] <= MaxY / 2;
            SnakeX[1] <= MaxX / 2 - SquareSize;
            SnakeY[1] <= MaxY / 2;
            SnakeX[2] <= MaxX / 2 - 2 * SquareSize;
            SnakeY[2] <= MaxY / 2;
            SnakeX[3] <= MaxX / 2 - 3 * SquareSize;
            SnakeY[3] <= MaxY / 2;
            SnakeX[4] <= MaxX / 2 - 4 * SquareSize;
            SnakeY[4] <= MaxY / 2;

            slow_counter <= 0;
            enable_timer <= 0;
            ENABLE <= 0;
        end else if (CURRENT_MODE) begin
            // Increment the slow movement counter
            slow_counter <= slow_counter + 1;

            if (slow_counter == 24'd9999999) begin
                slow_counter <= 0;
                for (i = 4; i > 0; i = i - 1) begin
                    SnakeX[i] <= SnakeX[i-1];
                    SnakeY[i] <= SnakeY[i-1];
                end

                // Update head position based on direction with wrapping
                case (DIRECTION)
                    2'b00: if (SnakeY[0] < SquareSize) SnakeY[0] <= MaxY - SquareSize;
                           else SnakeY[0] <= SnakeY[0] - SquareSize;
                    2'b10: if (SnakeY[0] >= MaxY - SquareSize) SnakeY[0] <= 0;
                           else SnakeY[0] <= SnakeY[0] + SquareSize;
                    2'b11: if (SnakeX[0] < SquareSize) SnakeX[0] <= MaxX - SquareSize;
                           else SnakeX[0] <= SnakeX[0] - SquareSize;
                    2'b01: if (SnakeX[0] >= MaxX - SquareSize) SnakeX[0] <= 0;
                           else SnakeX[0] <= SnakeX[0] + SquareSize;
                endcase
            end

            // Check if snake reaches target
            if ((SnakeX[0] >= TargetX) && (SnakeX[0] < TargetX + SquareSize) &&
                (SnakeY[0] >= TargetY) && (SnakeY[0] < TargetY + SquareSize)) begin
                ReachedTarget <= 1;
                ENABLE <= 1;             // Set ENABLE high
                enable_timer <= ENABLE_DURATION;  // Set enable_timer for 3 seconds
            end else begin
                ReachedTarget <= 0;
            end

            // Enable signal timer
            if (ENABLE) begin
                if (enable_timer > 0) begin
                    enable_timer <= enable_timer - 1;
                end else begin
                    ENABLE <= 0;         // Reset ENABLE after 3 seconds
                end
            end
        end
    end

    // Color output logic
    always @(posedge CLK) begin
        if (RESET) begin
            COLOUR_IN <= BLUE;
        end else begin
            COLOUR_IN <= BLUE;
            for (i = 0; i < 5; i = i + 1) begin
                if ((X >= SnakeX[i]) && (X < SnakeX[i] + SquareSize) &&
                    (Y >= SnakeY[i]) && (Y < SnakeY[i] + SquareSize)) begin
                    COLOUR_IN <= YELLOW;
                end
            end

            // Draw the target
            if ((X >= TargetX) && (X < TargetX + SquareSize) &&
                (Y >= TargetY) && (Y < TargetY + SquareSize)) begin
                COLOUR_IN <= WHITE;
            end
        end
    end

endmodule


