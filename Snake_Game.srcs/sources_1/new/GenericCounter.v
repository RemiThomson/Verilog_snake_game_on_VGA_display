`timescale 1ns / 1ps 

module GenericCounter( 
      CLK, 
      RESET, 
      ENABLE, 
      TRIG_OUT, 
      COUNT 
    ); 
         
    parameter COUNTER_WIDTH = 4; 
    parameter COUNTER_MAX = 9; 

    input CLK; 
    input RESET; 
    input ENABLE; 
    output TRIG_OUT; 
    output [COUNTER_WIDTH-1:0] COUNT;      

    reg [COUNTER_WIDTH-1:0] count_value; 
    reg Trigger_out; 
     
    always @(posedge CLK) begin   
             if (RESET)   
                count_value <= 0; // Reset count value to 0   
             else if (ENABLE) begin   
                if (count_value == COUNTER_MAX)   
                   count_value <= 0; // Reset count value when maximum is reached   
                else    
                   count_value <= count_value + 1; // Increment count value   
             end   
        end   

        always @(posedge CLK) begin   
              if (RESET)    
                Trigger_out <= 0; // Reset trigger output   
              else begin    
                  if (ENABLE && (count_value == COUNTER_MAX))   
                    Trigger_out <= 1; // Trigger output when maximum count is reached  
                  else   
                    Trigger_out <= 0; // Reset trigger output otherwise   
              end   
        end   
      
        assign COUNT = count_value; // Assign count value to output   
        assign TRIG_OUT = Trigger_out;      

endmodule 