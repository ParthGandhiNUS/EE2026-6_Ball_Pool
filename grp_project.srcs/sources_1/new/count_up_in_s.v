`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.04.2024 18:40:51
// Design Name: 
// Module Name: count_up_in_s
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


module count_up_in_s(
    input CLOCK,
    input switch,
    input [31:0] timeinseconds,
    output reg [31:0] count = 0
    );
    
  always @ (posedge CLOCK)
    begin
    if (switch)
    begin
        count <= (count == timeinseconds) ? timeinseconds : count + 1;
    end
    
    else
    begin
        count <= 0;
    end 
  end
endmodule
