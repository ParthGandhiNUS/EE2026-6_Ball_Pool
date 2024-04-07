`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.04.2024 10:25:32
// Design Name: 
// Module Name: UART_RX
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


module UART_RX(
    input clk,
    input JB,
    output reg [15:0] Data_Rx = 0,
    output reg checker = 0
    );
    
    //Clock
    wire clock_6p25MHz_Rx;
    flexible_clock UART_6p25Mhz_rx (clk, 7, clock_6p25MHz_Rx);
    
    reg [15:0] data1 = 0;
    
    reg [31:0] count_up = 0;
    reg [4:0] counter_1;
    reg [4:0] counter_2;
    
    always @ (posedge clock_6p25MHz_Rx)
    begin
        
        //Poll for the start bit
        if (count_up == 0 && JB == 0)
        begin
        count_up <= count_up + 1;
        checker <= 0;
        end
        
        //Begin the reception
        if (count_up > 0 && count_up <=16)
        begin
        count_up <= count_up + 1;
        data1[15:0] <= {JB, data1[15:1] };
        end
        
        //Putting the received data into the proper format for passing out of this function
        if (count_up > 16 && JB == 1)
        begin
        Data_Rx[15:0] <= data1 [15:0];
        count_up <= 0;
        checker <= 1; //Can use to debug if we are not receiving data
        end
        
    end

endmodule
