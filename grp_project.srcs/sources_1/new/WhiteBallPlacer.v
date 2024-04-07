`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.04.2024 15:36:24
// Design Name: 
// Module Name: WhiteBallPlacer
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


module WhiteBallPlacer(
		input clk,
	    input [7:0] wallLeft,
		input [7:0] wallRight,
		input [6:0] wallUp,
		input [6:0] wallDown, 
		input [3:0] commandWhite,
		input btnD, btnU, btnL, btnR,
		input [7:0] xPos,
	    input [6:0] yPos,
		output reg [7:0] newXPos = 0,
		output reg [6:0] newYPos = 0		
    );
    
    
    always @ (posedge clk)
    	begin
    	    		
			newXPos <=  (btnL && (xPos > wallLeft + 2)) ? xPos - 1 :
						(btnR && (xPos < wallRight - 2)) ? xPos + 1 : xPos;
				 
			newYPos <=  (btnU && (yPos > wallUp + 2)) ? yPos - 1 :
						(btnD && (yPos < wallDown - 2)) ? yPos + 1 : yPos;
				 			
    	end
    			
    			
    				 
endmodule
