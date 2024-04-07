`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.04.2024 10:22:30
// Design Name: 
// Module Name: Mouse_Tx
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


module Mouse_Tx(
    input clk,
    input enable,
    input [11:0] input_data,
    output reg JA = 1,
    output reg check_tx = 0
    );

    //Clock for making it more stable
    wire clock_1khz;
    flexible_clock clocker_625khz (clk, 100000, clock_1khz);
    
    
    
    //Data Packet {1,1,12,1}
    reg [11:0] tx_data;
    //Counter for transmission
    reg [3:0] Tx_Counter = 0;
    
    always @ (posedge clock_1khz)
    begin
    Tx_Counter <= Tx_Counter + 1; // Tx_Counter goes from 0 --> 15 --> 0 --> 15
    if (enable)
        begin
            if (Tx_Counter == 0)
            begin
            JA <= 1;
            check_tx <= 0;
            end
            
            if (Tx_Counter == 1) //Start Bit which is set to low
            begin
            JA <= 0;
            tx_data <= input_data;
            check_tx <= 1;
            end
            
            if (Tx_Counter >= 2 && Tx_Counter <= 13)
            begin
            JA <= tx_data[0]; //takes the least significant bits' value
            tx_data <= tx_data >> 1;
            check_tx <= 1;
            end
            
            if (Tx_Counter >= 14)
            begin
            JA <= 1;
            check_tx <= 0;
            end
            
        end
    end 
    
endmodule
