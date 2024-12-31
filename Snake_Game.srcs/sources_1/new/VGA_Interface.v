module VGA_Interface(
    input CLK,
    input [11:0] COLOUR_IN,  // Input color from SnakeControl
    input [1:0] CURRENT_MODE,
    output reg [9:0] ADDRH,
    output reg [8:0] ADDRV,
    output reg [11:0] COLOUR_OUT,
    output reg HS,
    output reg VS,
    output [9:0] X,   // Add X as an output
    output [8:0] Y    // Add Y as an output
);

    // Timing parameters for vertical and horizontal lines
    parameter VertTimeToPulseWidthEnd = 10'd2;
    parameter VertTimeToBackPorchEnd = 10'd31;
    parameter VertTimeToDisplayTimeEnd = 10'd511;
    parameter VertTimeToFrontPorchEnd = 10'd521;
    parameter HorzTimeToPulseWidthEnd = 10'd96;
    parameter HorzTimeToBackPorchEnd = 10'd144;
    parameter HorzTimeToDisplayTimeEnd = 10'd784;
    parameter HorzTimeToFrontPorchEnd = 10'd800;

    // Master state parameters
    parameter IDLE = 2'b00;
    parameter PLAY = 2'b01;
    parameter WIN = 2'b10;

    wire link1, link2;
    wire [9:0] count_h;
    wire [8:0] count_v;
    reg [11:0] ColourDisplay; // New register to hold the display color

    // Adjusted pixel coordinates (remove sync and blanking intervals)
    assign X = (count_h >= HorzTimeToBackPorchEnd && count_h < HorzTimeToDisplayTimeEnd) ? (count_h - HorzTimeToBackPorchEnd) : 10'd0;
    assign Y = (count_v >= VertTimeToBackPorchEnd && count_v < VertTimeToDisplayTimeEnd) ? (count_v - VertTimeToBackPorchEnd) : 9'd0;

    GenericCounter # (.COUNTER_MAX(3), .COUNTER_WIDTH(2)) Counter1 (.CLK(CLK), .ENABLE(1'b1), .RESET(1'b0), .TRIG_OUT(link1));
    GenericCounter # (.COUNTER_MAX(799), .COUNTER_WIDTH(10)) Counter2 (.CLK(CLK), .ENABLE(link1), .RESET(1'b0), .COUNT(count_h), .TRIG_OUT(link2));
    GenericCounter # (.COUNTER_MAX(520), .COUNTER_WIDTH(9)) Counter3 (.CLK(CLK), .ENABLE(link2), .RESET(1'b0), .COUNT(count_v));

    // Color Display Logic
    always @(*) begin
        case (CURRENT_MODE)
            2'b00: ColourDisplay = 12'b000000001111; // Blue screen for IDLE state
            2'b11: ColourDisplay = COLOUR_IN;   // Display SnakeColor from SnakeControl in PLAY state
            2'b10:  ColourDisplay = 12'b111100000000; // Example colorful pattern for WIN state (Red here for simplicity)
            default: ColourDisplay = 12'b000000000000; // Black screen as fallback
        endcase
    end

    // COLOUR_OUT Signal Logic
    always @(posedge CLK) begin
        if ((count_v >= VertTimeToBackPorchEnd) && (count_v < VertTimeToDisplayTimeEnd) && (count_h >= HorzTimeToBackPorchEnd) && (count_h < HorzTimeToDisplayTimeEnd))
            COLOUR_OUT <= ColourDisplay;  // Output based on MASTER_STATE
        else
            COLOUR_OUT <= 12'b0;  // Black outside the displayable region
    end

    // Horizontal Sync Signal Logic
    always @(posedge CLK) begin
        if (count_h < HorzTimeToPulseWidthEnd)
            HS <= 0;
        else
            HS <= 1;
    end

    // Vertical Sync Signal Logic
    always @(posedge CLK) begin
        if (count_v < VertTimeToPulseWidthEnd)
            VS <= 0;
        else
            VS <= 1;
    end

    // Horizontal and Vertical Address Update Logic
    always @(posedge CLK) begin
        if ((count_v >= VertTimeToBackPorchEnd) && (count_v < VertTimeToDisplayTimeEnd) && (count_h >= HorzTimeToBackPorchEnd) && (count_h < HorzTimeToDisplayTimeEnd)) begin
            if (ADDRH == 639)
                ADDRH <= 0;
            else
                ADDRH <= ADDRH + 1;

            if (ADDRH == 0) begin
                if (ADDRV == 439)
                    ADDRV <= 0;
                else
                    ADDRV <= ADDRV + 1;
            end
        end else begin
            ADDRH <= 0;
            ADDRV <= 0;
        end
    end

endmodule
