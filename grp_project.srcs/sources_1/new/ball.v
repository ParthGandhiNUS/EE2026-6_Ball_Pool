`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.03.2024 12:11:08
// Design Name: 
// Module Name: ball
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


module ball(

    input [3:0] command,
    input [7:0] newXSpeed,
    input [7:0] newYSpeed,
    input [7:0] newXPos,
    input [6:0] newYPos,
    input moveRight,
    input moveUp,
    input movementClk,
    input collisionClk,
    input [7:0] wallLeft,
    input [7:0] wallRight,
    input [6:0] wallUp,
    input [6:0] wallDown, 
    output reg [7:0] xPos = 0,
    output reg [6:0] yPos = 0,
    output reg [7:0] ySpeed = 0,
    output reg [7:0] xSpeed = 0,
    output reg movingRight = 1,
    output reg movingUp = 1,
    output reg isMoving = 1

);

    localparam doNothing = 4'b0000;
    localparam replaceAllValues = 4'b0001;
    localparam changePosition = 4'b0010;
    localparam changeSpeed = 4'b0011;

    reg [7:0] xCount = 0;
    reg [7:0] yCount = 0; 
    wire [7:0] xNewSpeed;
    wire [7:0] yNewSpeed;
    
    reg [15:0] frictionCheck = 0;
    reg executedCommand = 0;
    reg [3:0] oldCmd = 0;
    reg [7:0] prevXCmd = 0;
    reg [7:0] prevYCmd = 0;
    reg [7:0] prevXPosCmd = 0;
    reg [6:0] prevYPosCmd = 0;
    reg prevRight = 0;
    reg prevUp = 0;
    reg [2:0] frictionCounter = 0;
    
    always @ (posedge movementClk) begin
        
        frictionCheck <= (frictionCheck <= 499) ? frictionCheck + 1 : 0;
    
        executedCommand <= ((oldCmd == command) &&
                   (prevXCmd == newXSpeed) &&
                   (prevYCmd == newYSpeed) &&
                   (prevXPosCmd == newXPos) &&
                   (prevYPosCmd == newYPos) &&
                   (prevRight == moveRight) &&
                   (prevUp == moveUp)) ||
                   (command == 0) ? 1 : 0;
                       
        
        oldCmd <= command;
        prevXCmd <= newXSpeed;
        prevYCmd <= newYSpeed;
        prevXPosCmd <= newXPos;
        prevYPosCmd <= newYPos;
        prevRight <= moveRight;
        prevUp <= moveUp;
        
        if (!executedCommand) begin
            case (oldCmd) 
            
                doNothing: begin
                
                end
                
                replaceAllValues: begin
                    xCount <= 0;
                    yCount <= 0;
                    movingRight <= prevRight;
                    movingUp <= prevUp;
                    xPos <= prevXPosCmd;
                    yPos <= prevYPosCmd;
                    xSpeed <= prevXCmd;
                    ySpeed <= prevYCmd;
                    frictionCounter <= 0;
                        
                end
                
                changePosition: begin
                    xCount <= 0;
                    yCount <= 0;
                    movingRight <= 0;
                    movingUp <= 0;
                    xPos <= newXPos;
                    yPos <= newYPos;
                    xSpeed <= 0;
                    ySpeed <= 0;
                
                end
                
                changeSpeed: begin
                    xCount <= 0;
                    yCount <= 0;
                    movingRight <= prevRight;
                    movingUp <= prevUp;
                    xSpeed <= prevXCmd;
                    ySpeed <= prevYCmd;
                    frictionCounter <= 0;
                
                end
                
                default : begin
                
                
                end
            
            endcase
        end
        
        if (executedCommand) begin
        
            xCount <= (xCount < xSpeed) ? xCount + 1 : 0;
            yCount <= (yCount < ySpeed) ? yCount + 1 : 0;
            
            movingRight <= (xPos + 2 >= wallRight && movingRight) ? 0 :
                           (xPos - 2 <= wallLeft && !movingRight) ? 1 : movingRight;
                           
            movingUp <= (yPos + 2 >= wallDown && !movingUp) ? 1 :
                        (yPos - 2 <= wallUp && movingUp) ? 0 : movingUp;
                        
            xPos <= (xCount == xSpeed && xCount != 0) ?
                    (movingRight) ? xPos + 1 : xPos - 1 : xPos;
                    
            yPos <= (yCount == ySpeed && yCount != 0) ?
                    (movingUp) ? yPos - 1 : yPos + 1 : yPos;
                    
			frictionCounter <= (frictionCounter > 3) ? 4 :
							   (frictionCheck == 500) ? frictionCounter + 1 :
							   frictionCounter;
                    
            
            xSpeed <= (frictionCheck == 500) ?
                         //true
                         (xSpeed == 0) ? 0 :
                         (frictionCounter == 4) ? 0 :
                         (xPos >= wallLeft + 2 && xPos <= wallRight - 2) ? 
                         (xSpeed [6:0] == 0) ? 0 : 
                         (xSpeed[7]) ? {xSpeed[7], xSpeed[5:0], 1'b0} : 
                         xSpeed << 1 
                         : xSpeed 
                         //false
                         : xSpeed;            
                                 
            ySpeed <= (frictionCheck == 500) ?
                         //true
                         (ySpeed == 0) ? 0 :
                         (frictionCounter == 4) ? 0 :
                         (yPos >= wallUp + 2 && yPos <= wallDown - 2) ? 
                         (ySpeed [6:0] == 0) ? 0 : 
                         (ySpeed[7]) ? {ySpeed[7], ySpeed[5:0], 1'b0} : 
                         ySpeed << 1 
                         : ySpeed 
                         //false
                         : ySpeed;
        
        end
        isMoving <= (ySpeed == 0 && xSpeed == 0) ? 0 : 1;
        
    end

endmodule
