`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.04.2024 19:05:44
// Design Name: 
// Module Name: border_color_change
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


module border_color_change(
    input CLOCK,
    input button,
    input [31:0] timetosustain,
    output reg changeColor = 0
    );
    reg [31:0] count = 0;
    
    always @ (posedge CLOCK)
        begin
        changeColor <= (button) ? 1 : changeColor;
        if (changeColor)
        begin
            count <= (count == timetosustain) ? timetosustain : count + 1;
        end
        
        if (count == timetosustain)
        begin
            changeColor <= 0;
        end
      end
endmodule
