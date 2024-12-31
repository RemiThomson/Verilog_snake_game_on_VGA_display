`timescale 1ns / 1ps

module Generic_counter (
    CLK,
    RESET,
    ENABLE,
    COUNT,
    TRIG_OUT
);
    parameter COUNTER_WIDTH = 4;
    parameter COUNTER_MAX = 9;

    input CLK;
    input RESET;
    input ENABLE;
    output [COUNTER_WIDTH-1:0] COUNT;
    output TRIG_OUT;

    reg Trigger_out;
    reg [COUNTER_WIDTH-1:0] count_value;

    //logic for value of count_value
    always@(posedge CLK) begin
        if (RESET) 
            count_value <= 0;
        else begin
            if (ENABLE) begin
                if (count_value == COUNTER_MAX)
                    count_value <= 0;
            else
                count_value <= count_value + 1;
            end
        end
    end
    
    // Logic for Trigger_out
    always @(posedge CLK) begin
        if (RESET)
            Trigger_out <= 0;
        else begin
            if (ENABLE && (count_value == COUNTER_MAX))
                Trigger_out <= 1;
            else
                Trigger_out <= 0;
        end
    end
    
    //assignment that tie count_value and Trigger_out to COUNT and
    //TRIG_OUT respectively
    assign COUNT = count_value;
    assign TRIG_OUT = Trigger_out;
    
endmodule
