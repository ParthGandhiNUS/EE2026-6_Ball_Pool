`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.04.2024 09:54:44
// Design Name: 
// Module Name: Tx_Upcount
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


module Tx_Upcount(
    input clock,
    input [31:0] max_value,
    output reg [31:0] tx_counter = 0
    );
    
always @ (posedge clock)
    begin
      tx_counter <= (tx_counter == max_value) ? 0 : tx_counter + 1;
    end
endmodule
