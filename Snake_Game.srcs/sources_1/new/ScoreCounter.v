`timescale 1ns / 1ps

module ScoreCounter(
    input wire CLK,
    input wire RESET,
    input wire ENABLE,
    output wire [1:0] SEG_SELECT,
    output wire [7:0] DEC_OUT
    
    
    );    
    
    // Declare wires for the counters and strobe
    wire Bit17TriggOut;
    wire Bit4TrigOut1;
    wire Bit4TrigOut2;
    wire Bit4TrigOut3;
    wire Bit4TrigOut4;
    wire [3:0] DecCount0, DecCount1, DecCount2, DecCount3;
    wire [1:0] StrobeCount;
    
    // The 17-bit counter
    Generic_counter # (
        .COUNTER_WIDTH(17),
        .COUNTER_MAX(99999)
    ) Bit17Counter (
        .CLK(CLK),
        .RESET(1'b0),
        .ENABLE(1'b1),
        .TRIG_OUT(Bit17TriggOut)
    );
    // 4-bit counter_0
    Generic_counter # (
        .COUNTER_WIDTH(4),
        .COUNTER_MAX(9)
    ) Counter0 (
        .CLK(CLK),
        .RESET(RESET),
        .ENABLE(Bit17TriggOut && ENABLE),
        .TRIG_OUT(Bit4TrigOut1)
    );
    
    // 4-bit Counter1
    Generic_counter # (
        .COUNTER_WIDTH(4),
        .COUNTER_MAX(9)
    ) Counter1 (
        .CLK(CLK),
        .RESET(RESET),
        .ENABLE(Bit4TrigOut1),
        .TRIG_OUT(Bit4TrigOut2),
        .COUNT(DecCount0)
    );
    
    // 4-bit Counter2
    Generic_counter # (
        .COUNTER_WIDTH(4),
        .COUNTER_MAX(9)
    ) Counter2 (
        .CLK(CLK),
        .RESET(RESET),
        .ENABLE(Bit4TrigOut2),
        .TRIG_OUT(Bit4TrigOut3),
        .COUNT(DecCount1)
    );
    
    // 4-bit Counter3
    Generic_counter # (
        .COUNTER_WIDTH(4),
        .COUNTER_MAX(9)
    ) Counter3 (
        .CLK(CLK),
        .RESET(RESET),
        .ENABLE(Bit4TrigOut3),
        .TRIG_OUT(Bit4TrigOut4),
        .COUNT(DecCount2)
    );
    // 4-bit Counter4
    Generic_counter # (
        .COUNTER_WIDTH(4),
        .COUNTER_MAX(9)
    ) Counter4 (
        .CLK(CLK),
        .RESET(RESET),
        .ENABLE(Bit4TrigOut4),
        .TRIG_OUT(Bit4TrigOut5),
        .COUNT(DecCount3)
    );
    // 2-bit Strobe Counter
    Generic_counter # (
        .COUNTER_WIDTH(2),
        .COUNTER_MAX(3)
    ) StrobeCounter (
        .CLK(CLK),
        .RESET(1'b0),
        .ENABLE(Bit17TriggOut), 
        .COUNT(StrobeCount),
        .TRIG_OUT()
    );
    
    
    // Mux logic for selecting which counter to display on the 7-segment
    wire [4:0] DecCountAndDOT0, DecCountAndDOT1, DecCountAndDOT2, DecCountAndDOT3;
    wire [4:0] MuxOut;
    
    assign DecCountAndDOT0 = {1'b0, DecCount0};
    assign DecCountAndDOT1 = {1'b0, DecCount1};
    assign DecCountAndDOT2 = {1'b0, 4'b0000}; // Activating DOT for this segment
    assign DecCountAndDOT3 = {1'b0, 4'b0000};
    
    // Multiplexer to choose which digit to display on the 7-segment
    Multiplexer Mux4(
        .CONTROL(StrobeCount),
        .IN0(DecCountAndDOT0),
        .IN1(DecCountAndDOT1),
        .IN2(DecCountAndDOT2),
        .IN3(DecCountAndDOT3),
        .OUT(MuxOut)
    );
    
    // 7-segment display decoder
    Seg7Decoder Seg7(
        .SEG_SELECT_IN(StrobeCount),
        .BIN_IN(MuxOut[3:0]),
        .DOT_IN(MuxOut[4]),
        .SEG_SELECT_OUT(SEG_SELECT),
        .HEX_OUT(DEC_OUT)
    );
    
    endmodule
