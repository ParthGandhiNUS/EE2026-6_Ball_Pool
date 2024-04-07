`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.03.2024 20:40:52
// Design Name: 
// Module Name: Coin_Result
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


module Coin_Result(
    input clock,
    input result_check,
    output reg [15:0] oled_data
    );
    
    always @ (posedge clock)
    begin
    
    if (result_check)
        begin
        oled_data <= 16'b00000_111111_00000; //Green
        end
    
    else
        begin
        oled_data <= 16'b11111_000000_00000; //Red
        end   
      
    end
    
endmodule
