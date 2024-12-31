`timescale 1ns / 1ps

module Navigation_SM(
    input CLK,
    input RESET,
    input BTNL,    // Left button
    input BTNR,    // Right button
    input BTNC,    // Center button
    input BTNU,    // Up button
    input BTND,    // Down button
    output reg [1:0] DIRECTION // 2-bit direction encoding
);

    // State encoding
    parameter UP = 2'b00;
    parameter RIGHT = 2'b01;
    parameter DOWN = 2'b10;
    parameter LEFT = 2'b11;

    // Register to hold the current state
    reg [1:0] current_state, next_state;

    // State transition based on input
    always @(posedge CLK or posedge RESET) begin
        if (RESET)
            current_state <= UP; // Initial state
        else
            current_state <= next_state;
    end

    // Next state logic
    always @(*) begin
        next_state = current_state; // Default to maintain current state
        case (current_state)
            UP: begin
                if (BTNL) next_state = LEFT;
                else if (BTNR) next_state = RIGHT;
            end
            RIGHT: begin
                if (BTNU) next_state = UP;
                else if (BTND) next_state = DOWN;
            end
            DOWN: begin
                if (BTNL) next_state = LEFT;
                else if (BTNR) next_state = RIGHT;
            end
            LEFT: begin
                if (BTNU) next_state = UP;
                else if (BTND) next_state = DOWN;
            end
        endcase
    end

    // Output assignment
    always @(*) begin
        DIRECTION = current_state;
    end

endmodule

