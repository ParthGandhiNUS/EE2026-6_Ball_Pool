`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.04.2024 10:45:42
// Design Name: 
// Module Name: mouse_receive
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mouse_receive(
    input clk,
    input JB,
    output reg [11:0] output_data = 0,
    output reg checker = 0
    );

    //Clock for making it more stable
    wire clock_1khz;
    flexible_clock clocker_625khz (clk, 100000, clock_1khz);
    
    
    
    //Clock for making it more stable
    wire clock_30hz;
    flexible_clock clocker_30hz (clk, 3333333, clock_30hz);
    
    
    reg [11:0] building_output = 0;
    reg [11:0] built_output = 0;
    reg [4:0] Rx_Counter = 0;
    
    always @ (posedge clock_1khz)
    begin    
        //Poll for the start bit
        if (Rx_Counter == 0 && JB == 0)
        begin
        Rx_Counter <= Rx_Counter + 1;
        checker <= 0;
        end
        //Bit by bit reception
        if (Rx_Counter > 0 && Rx_Counter <=12)
        begin
        Rx_Counter <= Rx_Counter + 1;
        building_output [11:0] <= {JB, building_output[11:1]}; // Concatenation
        end
        
        if (Rx_Counter > 12 && JB == 1)
        begin
        built_output[11:0]  <= building_output[11:0];
        Rx_Counter <= 0;
        checker <= 1; //Can use to debug if we are not receiving data
        end
    end
    
    always @ (posedge clock_30hz)
    begin
    output_data [11:0] <= built_output [11:0];
    end 
endmodule
