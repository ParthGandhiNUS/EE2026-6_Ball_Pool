`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.04.2024 11:12:03
// Design Name: 
// Module Name: UART_Integrate
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


module UART_Integrate(
    input clk,
    //input [15:0] oled_data, --> used to parse in the oleddatainput
    input [7:0] JA, // JB is set to input currently
    input [15:0] sw,
    output [7:0] JB,
    output [7:0] JC,
    output [15:0] led
    );
    
    //This file will stay here to provide you with more details about using UART
    
    //Clock for Oled
    wire clock_6p25Mhz;
    flexible_clock clocker_6p25Mhz (clk, 7, clock_6p25Mhz);

    //Prerequisites for oled data
    wire fb;
    wire [12:0] pixel_index;
    
    //Wire and register to connect the Oled Module with the Receiver Module
    wire [15:0] datareceiver; 
    reg [15:0] data_to_send;
       
   //Module used to test the UART
    wire [15:0] pool_logo;
    pool_startpage new_pool(
     .clk(clk),
     .pixels(pixel_index),
     .oled_data(pool_logo)
      );
   
    
    //Transmit Module
    UART_TX transmit(
       .clk(clk),
       .switch(1), //Can also use a switch instead
       .data(pool_logo),
       .JA(JB[0]),
       .check_tx(led[0]) //Led to check that Tx works properly
        );
    
    
    //Receive Module
    UART_RX receive(
       .clk(clk),
       .JB(JA[0]),
       .Data_Rx(datareceiver),
       .checker(led[1]) //Led to check that Rx works properly
       );
    
    //Oled Module
    Oled_Display trial_Page_Oled (
               .clk(clock_6p25Mhz), 
               .reset(0), 
               .frame_begin(fb), 
               .sending_pixels(),
               .sample_pixel(), 
               .pixel_index(pixel_index), 
               .pixel_data(data_to_send), 
               .cs(JC[0]), 
               .sdin(JC[1]), 
               .sclk(JC[3]), 
               .d_cn(JC[4]), 
               .resn(JC[5]), 
               .vccen(JC[6]),
               .pmoden(JC[7])
               );
     
          
     always @ (posedge clk)
     begin
     data_to_send <= datareceiver;
     end  

endmodule