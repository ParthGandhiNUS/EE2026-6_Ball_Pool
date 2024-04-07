`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.03.2024 20:51:46
// Design Name: 
// Module Name: toggler_function
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


module toggler_function(
    input clock,
    output reg randomOut = 0
    );
    always @ (posedge clock)
        begin
        randomOut = ~randomOut;
        end
endmodule
