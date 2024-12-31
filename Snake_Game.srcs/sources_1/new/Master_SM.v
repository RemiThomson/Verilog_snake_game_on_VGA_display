`timescale 1ns / 1ps

module Master_SM(
    input CLK,
    input RESET,
    input BTNC,
    input SCORE_LIMIT,
    output reg [1:0] CURRENT_MODE // Current mode of operation
);
    
    // Define states
    localparam MODE_IDLE = 2'b00,
               MODE_PLAY = 2'b11,
               MODE_WIN = 2'b10,
               MODE_FAIL = 2'b01;

    reg [31:0] timer; // 25-bit timer for counting (adjust based on your clock frequency)

    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            CURRENT_MODE <= MODE_IDLE; // Reset to Idle mode
            timer <= 0;                // Reset timer
        end else begin
            case (CURRENT_MODE)
                MODE_IDLE: begin
                    if (BTNC) 
                        CURRENT_MODE <= MODE_PLAY; 
                    // Increment timer only in idle state
                    timer <= timer + 1; 
                    
                    // Check if timer reaches the limit (set to 30 seconds)
                    if (timer >= 32'd3_000_000_000) // Example: Adjust based on your clock frequency
                        CURRENT_MODE <= MODE_FAIL; // Transition to FAIL state after timeout
                end
                
                MODE_PLAY: begin
                    if (SCORE_LIMIT) 
                        CURRENT_MODE <= MODE_WIN; // Switch to VGA when LED is finished
                    
                    timer <= 0; // Reset timer when transitioning from LED
                end
                
                MODE_WIN: begin
                    
                    timer <= 0; // Reset timer when transitioning from VGA
                end
                
               
                
                MODE_FAIL: begin
                    // In FAIL state, we could potentially have other logic or reset behavior
                    if (timer >= 32'd500_000_000) // Stay in FAIL state for 5 seconds before going back to IDLE
                        CURRENT_MODE <= MODE_IDLE;
                    else 
                        timer <= timer + 1; // Keep incrementing timer
                end
                
                default: begin
                    CURRENT_MODE <= MODE_PLAY; // Default to Idle
                    timer <= 0; // Reset timer if in an unknown state
                end
            endcase
        end
    end

endmodule
