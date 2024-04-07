`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.04.2024 09:46:36
// Design Name: 
// Module Name: UART_TX
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


module UART_TX(
    input clk,
    input switch,
    input [15:0] data,
    output reg JA = 1, 
    output reg check_tx = 0
    );
    
    // Data Packet == (5, 1, 16,8)
    //Clock
    wire clock_6p25MHz_Tx;
    flexible_clock UART_6p25Mhz_tx (clk, 7, clock_6p25MHz_Tx);
    //Data
    reg [15:0] data_Tx;
    //Transmitter Count
    reg [31:0] Tx_Counter = 0;
    
    always @ (posedge clock_6p25MHz_Tx)
    begin
    //Upcount till 25
    Tx_Counter <= (Tx_Counter == 25) ? 0 : Tx_Counter + 1;
        
        if (switch)
        begin
            if (Tx_Counter <= 5)
            begin
            JA <= 1;
            check_tx <= 0;
            end
            
            if (Tx_Counter == 6)
            begin
            JA <= 0;
            data_Tx <= data;
            check_tx <= 1;
            end
            
            if (Tx_Counter >= 7 && Tx_Counter <= 22)
            begin
            JA <= data_Tx[0]; //takes the least significant bits' value
            data_Tx <= data_Tx >> 1; // Right shift by 1    
            check_tx <= 1;
            end
            
            if (Tx_Counter >=23)
            begin
            JA <= 1;
            check_tx <= 0;
            end 
         end
    end 
    
endmodule