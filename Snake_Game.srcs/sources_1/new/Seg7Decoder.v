`timescale 1ns / 1ps



module Seg7Decoder (
    input [1:0] SEG_SELECT_IN,
    input [3:0] BIN_IN,
    input DOT_IN,
    output reg [3:0] SEG_SELECT_OUT,
    output reg [7:0] HEX_OUT
);
    
    always @(SEG_SELECT_IN) begin
        case (SEG_SELECT_IN)
            2'b00 : SEG_SELECT_OUT = 4'b1110;
            2'b01 : SEG_SELECT_OUT = 4'b1101;
            2'b10 : SEG_SELECT_OUT = 4'b1111;
            2'b11 : SEG_SELECT_OUT = 4'b1111;
            default: SEG_SELECT_OUT = 4'b1111;
        endcase
    end

    always @(BIN_IN or DOT_IN) begin
        case (BIN_IN)
            4'h0: HEX_OUT[6:0] = 7'b1000000; // '0'
            4'h1: HEX_OUT[6:0] = 7'b1111001; // '1'
            4'h2: HEX_OUT[6:0] = 7'b0100100; // '2'
            4'h3: HEX_OUT[6:0] = 7'b0110000; // '3'
            4'h4: HEX_OUT[6:0] = 7'b0011001; // '4'
            4'h5: HEX_OUT[6:0] = 7'b0010010; // '5'
            4'h6: HEX_OUT[6:0] = 7'b0000010; // '6'
            4'h7: HEX_OUT[6:0] = 7'b1111000; // '7'
            4'h8: HEX_OUT[6:0] = 7'b0000000; // '8'
            4'h9: HEX_OUT[6:0] = 7'b0010000; // '9'
            4'hA: HEX_OUT[6:0] = 7'b0001000; // 'A'
            4'hB: HEX_OUT[6:0] = 7'b0000011; // 'B'
            4'hC: HEX_OUT[6:0] = 7'b1000110; // 'C'
            4'hD: HEX_OUT[6:0] = 7'b0100001; // 'D'
            4'hE: HEX_OUT[6:0] = 7'b0000110; // 'E'
            4'hF: HEX_OUT[6:0] = 7'b0001110; // 'F'
            default: HEX_OUT[6:0] = 7'b1111111; // blank or invalid input
        endcase
        
        HEX_OUT[7] <=~DOT_IN; // DOT control
    end

endmodule

