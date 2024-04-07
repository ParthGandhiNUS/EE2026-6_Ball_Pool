`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.04.2024 17:59:54
// Design Name: 
// Module Name: WhiteBallShooter
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


module WhiteBallShooter(
	input clk,
	input isWhiteBallMoving,
	input [7:0] xPosWhite,
	input [6:0] yPosWhite,
	input [11:0] xPosCursor,
	input [11:0] yPosCursor,
	output reg [7:0] newXSpeed,
	output reg [7:0] newYSpeed,
	output reg moveRight,
	output reg moveUp
    );
    
    reg [7:0] deltaX = 0;
    reg [6:0] deltaY = 0;
    
    wire cursorYSmaller;
    wire cursorXSmaller;
    
    assign cursorYSmaller = yPosCursor < yPosWhite;
    assign cursorXSmaller = xPosCursor < xPosWhite;
    //[3] == up [2] == down [1] == left [0] == right, e.g. 1010 means moving to the top left AFTER IMPACT, AKA cursor is to the btm right of the ball
    always @ (posedge clk)
    	begin
    		
    		deltaX <= (cursorXSmaller) ? xPosWhite - xPosCursor : xPosCursor - xPosWhite ;
			deltaY <= (cursorYSmaller) ? yPosWhite - yPosCursor : yPosCursor - yPosWhite;
			
			moveRight <= cursorXSmaller;
			moveUp <= !cursorYSmaller;
				  
		    newXSpeed <= (deltaX == 0) ? 0 :
		                 (deltaY == 0) ? deltaX : deltaY; //to be changed
		    newYSpeed <= (deltaY == 0) ? 0 : 
		                 (deltaX == 0) ? deltaY : deltaX; //to be changed
    	end
endmodule
