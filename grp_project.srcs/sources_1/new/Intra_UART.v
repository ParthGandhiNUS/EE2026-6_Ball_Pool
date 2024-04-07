`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.04.2024 16:04:54
// Design Name: 
// Module Name: Intra_UART
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


module Intra_UART(
    input clk,
    input receive,
    output transmit,
    output reg [15:0] pixel_data_received = 0
    );
    
        //Clock for Oled
    wire clock_6p25Mhz;
    flexible_clock clocker_6p25Mhz (clk, 7, clock_6p25Mhz);

    //Prerequisites for oled data
    wire fb;
    wire [12:0] pixel_index;
    
    //Wire and register to connect the Oled Module with the Receiver Module
    wire [15:0] datareceiver; 


   //Module used to test the UART
    wire [15:0] pool_logo;
    pool_startpage new_pool(
     .clk(clk),
     .pixels(pixel_index),
     .oled_data(pool_logo)
      );

    //Transmit Module
    UART_TX transmit_intra(
       .clk(clk),
       .switch(1), //Can also use a switch instead
       .data(pool_logo),
       .JA(transmit),
       .check_tx(0) //Led to check that Tx works properly
        );

    //Receive Module
    UART_RX receive_intra(
       .clk(clk),
       .JB(receive),
       .Data_Rx(datareceiver),
       .checker(0) //Led to check that Rx works properly
       );

     always @ (posedge clk)
     begin
         pixel_data_received <= datareceiver;
     end  

endmodule
