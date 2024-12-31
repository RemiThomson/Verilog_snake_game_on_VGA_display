`timescale 1ns / 1ps

module InvertCorners(
   input CLK,
   input [9:0] X, // Horizontal Counter  
   input [8:0] Y, // Vertical Counter  
   input [11:0] COLOUR_IN, // Input Colour  
   input [1:0] CURRENT_MODE, // Input mode (2 bits)  
   output reg [11:0] COLOUR_OUT // Output Colour  
);

	parameter SWITCH_INTERVAL = 100_000_000; // 1 second at 100 MHz
	parameter GROWTH_INTERVAL = 2_000_000; // Change this value to control growth speed (10 million clock cycles)
	reg [31:0] counter; // Counter for timing
	reg [31:0] growth_counter; // Counter for size growth
	reg SWITCH_ENABLE;   // Signal to switch colors  
	reg [2:0] current_color; // Counter for current color
	reg [7:0] size;

	parameter COLOUR_1 = 12'hF00; // Red
	parameter COLOUR_2 = 12'h0F0; // Green
	parameter COLOUR_3 = 12'h00F; // Blue

	// Always block for counting and size control
	always @(posedge CLK) begin
    	if (CURRENT_MODE == 2'b10) begin // Only execute logic if CURRENT_MODE is 2'b10
        	counter <= counter + 1; // Increment main counter

        	// Toggle the switch enable every second
        	if (counter >= SWITCH_INTERVAL) begin
            	SWITCH_ENABLE <= ~SWITCH_ENABLE; // Toggle color switch
            	counter <= 0; // Reset the counter
             
            	// Cycle through the colors when SWITCH_ENABLE is high
            	if (SWITCH_ENABLE) begin
                	current_color <= current_color + 1; // Move to the next color
                	if (current_color >= 2) begin // If it exceeds the last color, wrap around
                    	current_color <= 0;
                	end
            	end
        	end
         
        	// Increment growth_counter and control the size of the square
        	growth_counter <= growth_counter + 1; // Increment growth counter
        	if (growth_counter >= GROWTH_INTERVAL) begin
            	if (size < 120) begin
                	size <= size + 1; // Increment size until it reaches 240
            	end else begin
                	size <= 0; // Reset size to 0 once it reaches 240
            	end
            	growth_counter <= 0; // Reset growth counter after size increment
        	end
    	end
	end

	// Logic for inverting the corners and drawing the square
	always @(*) begin   
    	if (CURRENT_MODE == 2'b10) begin // Only work if CURRENT_MODE is 2'b10
        	// Check if the count is in either of the corners and invert color
        	if ((X < 30 && Y < 30) || // Top left corner    
            	(X > 610 && Y < 30) || // Top right corner	 
            	(X < 30 && Y > 450) || // Bottom left corner    
            	(X > 610 && Y > 450)   // Bottom right corner
        	) begin
            	COLOUR_OUT = COLOUR_IN; // Invert color for corners
        	end else if (X >= (320 - size) && X <= (320 + size) && Y >= (240 - size) && Y <= (240 + size)) begin
            	COLOUR_OUT = 12'hFFF; // Color for the growing square
        	end else begin
            	case (current_color)
                	3'd0: COLOUR_OUT = COLOUR_1; // Red
                	3'd1: COLOUR_OUT = COLOUR_2; // Green
                	3'd2: COLOUR_OUT = COLOUR_3; // Blue
                	default: COLOUR_OUT = COLOUR_1; // Fallback to Red
            	endcase
        	end  
    	end else begin
        	COLOUR_OUT = 12'h000; // Output black if CURRENT_MODE is not 2'b10
    	end
	end  

endmodule

