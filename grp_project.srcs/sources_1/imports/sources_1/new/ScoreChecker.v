`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.04.2024 19:57:07
// Design Name: 
// Module Name: ScoreChecker
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


module ScoreChecker(
		input clk,
		input [7:0] xPos,
		input [6:0] yPos,
		input [5:0] ball,
		input reset,
		output reg isScored = 0,
		output reg [7:0] newXPos ,
		output reg [6:0] newYPos
    );
    
    always @ (posedge clk) 
    	begin
    		isScored <= (reset) ? 0 :
    		            (ball == 6'b100000 && xPos == 50 && yPos == 60 && isScored == 1) ? 0 :
    					((xPos >= 4 && xPos <= 9) && ((yPos >= 4 && yPos <= 9 )||(yPos >= 43 && yPos <= 48))) ? 1 :
    					((xPos >= 43 && xPos <= 48) && ((yPos >= 4 && yPos <= 9 )||(yPos >= 43 && yPos <= 48))) ? 1 :
    					((xPos >= 83 && xPos <= 88) && ((yPos >= 4 && yPos <= 9 )||(yPos >= 43 && yPos <= 48))) ? 1 : isScored;
			
			newXPos <= (isScored && ball == 6'b100000) ? 50 :
					   (isScored && ball == 6'b010000) ? 55 :
					   (isScored && ball == 6'b001000) ? 60 :
					   (isScored && ball == 6'b000100) ? 65 :
					   (isScored && ball == 6'b000010) ? 70 :
					   (isScored && ball == 6'b000001) ? 75 : 0;
			
			newYPos <=  (isScored && ball == 6'b100000) ? 60 :
						(isScored && ball == 6'b010000) ? 60 :
						(isScored && ball == 6'b001000) ? 60 :
						(isScored && ball == 6'b000100) ? 60 :
						(isScored && ball == 6'b000010) ? 60 :
						(isScored && ball == 6'b000001) ? 60 : 0;
		end
    
endmodule
