`timescale 1ns / 1ps

module Wrapper(
    input wire CLK,                    // Clock input
    input wire RESET,                  // Reset input
    input wire BTNL,
    input wire BTNC,
    input wire BTNR, 
    input wire BTNU,
    input wire BTND,
    output [7:0] LED_OUT,              // Output for LED display
    output wire [3:0] SEG_SELECT,      // Output for the segment select (for 7-segment)
    output wire [7:0] DEC_OUT,         // Output for the 7-segment display
    input [11:0] SWITCHES,
    output [11:0] COLOUR_OUT,          // Output for VGA color
    output HS,                         // Horizontal sync
    output VS                          // Vertical sync
);

    // Internal wires and registers
    wire [1:0] CURRENT_MODE;           // Mode of the game (play or paused)
    wire ScoreOf10;                    // Signal indicating score limit reached
    wire [1:0] DIRECTION;              // Direction the snake is moving (up, down, left, right)
    wire [9:0] X;                      // Horizontal address (ADDRH)
    wire [8:0] Y;                      // Vertical address (ADDRV)
    wire [9:0] TargetX;                   
    wire [8:0] TargetY; 
    wire [14:0] RandomTargetAddress;   // Target position address
    wire ReachedTarget;                // Signal asserted when snake reaches the target
    wire [11:0] COLOUR_IN;             // Color input from SnakeControl to VGA_Interface

    // Instantiate Master State Machine
    Master_SM Master_SM (
        .CLK(CLK),
        .RESET(RESET),
        .BTNC(BTNC),
        .SCORE_LIMIT(ScoreOf10),
        .CURRENT_MODE(CURRENT_MODE)     // Output to control game mode
    );

    // Instantiate Navigation State Machine for Direction control
    Navigation_SM Navigation_SM (
        .CLK(CLK),
        .RESET(RESET),
        .BTNL(BTNL),
        .BTNR(BTNR),
        .BTNU(BTNU),
        .BTNC(BTNC),
        .BTND(BTND),
        .DIRECTION(DIRECTION)           // Output direction for snake movement
    );

    // Instantiate VGA Interface
    VGA_Interface uut (
        .CLK(CLK),                      // 100 MHz clock input
        .COLOUR_IN(COLOUR_IN),          // Color input from SnakeControl
        .CURRENT_MODE(CURRENT_MODE),    // Game mode (play or paused)
        .COLOUR_OUT(COLOUR_OUT),        // Output color to VGA
        .HS(HS),                        // Horizontal sync
        .VS(VS),                        // Vertical sync
        .X(X),
        .Y(Y),
        .ADDRH(ADDRH),                      // Output horizontal address
        .ADDRV(ADDRV)                       // Output vertical address
    );

    // Instantiate Target Generator
    TargetGenerator TargetGenerator (
        .CLK(CLK),
        .RESET(RESET),
        .ReachedTarget(ReachedTarget),
        .TargetX(TargetX),
        .TargetY(TargetY)
        
    );

    // Instantiate Score Counter
    ScoreCounter ScoreCounter (
        .CLK(CLK),
        .RESET(RESET),
        .ENABLE(ENABLE),
        .SEG_SELECT(SEG_SELECT),
        .DEC_OUT(DEC_OUT)
    );

    // Instantiate Snake Control
    SnakeControl SnakeControl (
        .CLK(CLK),
        .RESET(RESET),
        .ENABLE(ENABLE),
        .CURRENT_MODE(CURRENT_MODE),       // Game mode (play or paused)
        .ADDRH(ADDRH),                         // Horizontal address from VGA_Interface
        .ADDRV(ADDRV),                         // Vertical address from VGA_Interface
        .DIRECTION(DIRECTION),             // Direction from Navigation_SM
        .X(X),
        .Y(Y),
        .TargetX(TargetX),
        .TargetY(TargetY),
        .ReachedTarget(ReachedTarget),     // Output signal when target is reached
        .COLOUR_IN(COLOUR_IN)              // Color output to VGA_Interface
    );

endmodule

