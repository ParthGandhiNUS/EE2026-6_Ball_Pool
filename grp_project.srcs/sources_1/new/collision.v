`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.03.2024 15:24:26
// Design Name: 
// Module Name: collision
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


module collision(

input collisionClk,
input [7:0] ballAXpos,
input [6:0] ballAYpos,
input [7:0] ballAXSpeed,
input [7:0] ballAYSpeed,
input ballARight,
input ballAUp,
input ballAMoving,

input [7:0] ballBXpos,
input [6:0] ballBYpos,
input [7:0] ballBXSpeed,
input [7:0] ballBYSpeed,
input ballBRight,
input ballBUp,
input ballBMoving,

output reg isColliding = 0,
output reg [3:0] ballACommand = 0,
output reg [3:0] ballBCommand = 0,
output reg [7:0] ballANewXSpd = 0,
output reg [7:0] ballANewX = 0,
output reg [6:0] ballANewY = 0,
output reg ballAMoveRight = 0,
output reg [7:0] ballANewYSpd = 0,
output reg ballAMoveUp = 0,
output reg [7:0] ballBNewXSpd = 0,
output reg [7:0] ballBNewX = 0,
output reg [6:0] ballBNewY = 0,
output reg ballBMoveRight = 0,
output reg [7:0] ballBNewYSpd = 0,
output reg ballBMoveUp = 0
);


reg [9:0] averageA = 0;
reg [9:0] averageB = 0;
reg [9:0] average = 0;

//maybe used signed reg for storing the intermittent velocity

    always @ (posedge collisionClk) begin
    
        if (!isColliding) begin
            ballACommand <= 0;
            ballBCommand <= 0;
        end
    
    
        ballANewX = ballAXpos;
        ballANewY = ballAYpos;
        ballBNewX = ballBXpos;
        ballBNewY = ballBYpos;
    
    //do a check for if the balls are stuck together
    //and if the balls are at the wall
        
        averageA = (!ballAMoving) ? 0 :
            (ballAXSpeed == 0) ? 
            (!ballAYSpeed[7]) ? ballAYSpeed << 1 : ballAYSpeed :
            (ballAYSpeed == 0) ? 
            (!ballAXSpeed[7]) ? ballAXSpeed << 1 : ballAXSpeed :
            (ballAXSpeed + ballAYSpeed) >> 1;       
        
        averageB = (!ballBMoving) ? 0 :
            (ballBXSpeed == 0) ? 
            (!ballBYSpeed[7]) ? ballBYSpeed << 1 : ballBYSpeed :
            (ballBYSpeed == 0) ? 
            (!ballBXSpeed[7]) ? ballBXSpeed << 1 : ballBXSpeed :
            (ballBXSpeed + ballBYSpeed) >> 1;
        
        average = (!ballAMoving && !ballBMoving) ? 0 :
            (averageA == 0) ? 
            (!averageB[7]) ? averageB << 1 : averageB : 
            (averageB == 0) ? 
            (!averageA[7]) ? averageA << 1 : averageA :
            (averageA + averageB) >> 1;
    
        if (!isColliding && (ballAXpos == ballBXpos) && 
           ((ballAYpos == (ballBYpos - 2)) || (ballAYpos == (ballBYpos + 2)) ||
           (ballAYpos == (ballBYpos - 1)) || (ballAYpos == (ballBYpos + 1)))) begin
    /*
            B        B        A       A
            \/       /\       /\      \/
            A        A        B       B
    */
            ballACommand <= 4'b0011;
            ballBCommand <= 4'b0011;
            ballANewXSpd <= ballAXSpeed;
            ballAMoveRight = ballARight;
            ballANewYSpd = ballBYSpeed;
            ballAMoveUp = ballBUp;
            ballBNewXSpd = ballBXSpeed;
            ballBMoveRight = ballBRight;
            ballBNewYSpd = ballAYSpeed;
            ballBMoveUp = ballAUp;
            ballANewX = ballAXpos;
            ballANewY = ballAYpos;
            ballBNewX = ballBXpos;
            ballBNewY = ballBYpos;
        end
    
        if (!isColliding && ballAYpos == ballBYpos && 
           ((ballAXpos == (ballBXpos - 2)) || (ballAXpos == (ballBXpos + 2)) ||
           (ballAXpos == (ballBXpos - 1)) || (ballAXpos == (ballBXpos + 1)))) begin
           
    //      A --> B or A <-- B or B <-- A or B --> A
            ballACommand <= 4'b0011;
            ballBCommand <= 4'b0011;
            ballANewXSpd = ballBXSpeed;
            ballAMoveRight = ballBRight;
            ballANewYSpd = ballAYSpeed;
            ballAMoveUp = ballAUp;
            ballBNewXSpd = ballAXSpeed;
            ballBMoveRight = ballARight;
            ballBNewYSpd = ballBYSpeed;
            ballBMoveUp = ballBUp;
            ballANewX = ballAXpos;
            ballANewY = ballAYpos;
            ballBNewX = ballBXpos;
            ballBNewY = ballBYpos;
        end
    
         if (!isColliding && (((ballAXpos + 2 == ballBXpos) && ((ballAYpos) == (ballBYpos - 2))) ||
           ((ballAXpos == ballBXpos - 1) && (ballAYpos == ballBYpos - 1))))
        begin
        //                left_2 = 1; A bottom right B top left
        
            if ((ballAXSpeed == ballAYSpeed && ballAXSpeed != 0) ||
                (ballBXSpeed == ballBYSpeed && ballBXSpeed != 0)) begin
                
                ballACommand <= 4'b0011;
                ballAMoveRight = ballBRight;
                ballAMoveUp = ballBUp;
                ballANewXSpd = ballBXSpeed;
                ballANewYSpd = ballBYSpeed;
                
                ballBCommand <= 4'b0011;
                ballBMoveRight = ballARight;
                ballBMoveUp = ballAUp;
                ballBNewXSpd = ballAXSpeed;
                ballBNewYSpd = ballAYSpeed;
                
            
            end 
            else begin
                ballACommand <= 4'b0011;
                ballAMoveRight = (ballARight && ballAXSpeed != 0) ?
                                 ((!ballBRight && ballBXSpeed > ballAXSpeed) || ballBXSpeed == 0) ? 1 : 0 :
                                 (ballBRight && ballBXSpeed != 0 && (ballBXSpeed < ballAXSpeed || ballAXSpeed == 0)) ? 1 : 0;
                                 
                ballAMoveUp = (!ballAUp && ballAYSpeed != 0) ?
                              (ballBYSpeed == 0 || (ballBUp && ballBYSpeed > ballAYSpeed)) ? 0 : 1 : 1;
                              
                ballANewXSpd = average;
                ballANewYSpd = average;
                
                ballBCommand <= 4'b0011;
                ballBMoveRight = (ballAMoveUp && !ballAMoveRight) ? ballBRight : 1; 
                ballBMoveUp = (ballAMoveUp == ballAMoveRight) ? 0 : ballBUp;
                ballBNewXSpd = average;
                ballBNewYSpd = average;
            
            end

//            //test code
//            ballACommand <= 4'b0011;
//            ballBCommand <= 4'b0011;
//            ballANewXSpd = average;
//            ballAMoveRight = average;
//            ballANewYSpd = ballAYSpeed;
//            ballAMoveUp = ballAUp;
//            ballBNewXSpd = ballAXSpeed;
//            ballBMoveRight = ballARight;
//            ballBNewYSpd = ballBYSpeed;
//            ballBMoveUp = ballBUp;
//            ballANewX = ballAXpos;
//            ballANewY = ballAYpos;
//            ballBNewX = ballBXpos;
//            ballBNewY = ballBYpos;

        end
        
         if (!isColliding && (ballAXpos + 1 == ballBXpos) && ((ballAYpos) == (ballBYpos - 2)))
        begin
//                left_1 = 1
            ballACommand <= 4'b0011;
            ballAMoveRight = ballARight;              
            ballAMoveUp = 1;                 
            ballANewXSpd = average;
            ballANewYSpd = average << 1;
            
            ballBCommand <= 4'b0011;
            ballBMoveRight = 1;
            ballBMoveUp = 0;
            ballBNewXSpd = average << 1;
            ballBNewYSpd = average;
        end
        
         if (!isColliding && (ballAXpos - 1 == ballBXpos) && ((ballAYpos) == (ballBYpos - 2)))
        begin
//                right_1 = 1
            ballACommand <= 4'b0011;
            ballAMoveRight = ballARight;              
            ballAMoveUp = 1;                 
            ballANewXSpd = average;
            ballANewYSpd = average << 1;
            
            ballBCommand <= 4'b0011;
            ballBMoveRight = 0;
            ballBMoveUp = 0;
            ballBNewXSpd = average << 1;
            ballBNewYSpd = average;
        end
        
         if (!isColliding && ((ballAXpos - 2 == ballBXpos) && (ballAYpos == ballBYpos - 2)) ||
           ((ballAXpos - 1 == ballBXpos) && (ballAYpos == ballBYpos - 1)))
        begin
//                right_2 = 1 (a bottom left with b top right)
        
            if ((ballAXSpeed == ballAYSpeed && ballAXSpeed != 0) ||
                (ballBXSpeed == ballBYSpeed && ballBXSpeed != 0)) begin
                
                ballACommand <= 4'b0011;
                ballAMoveRight = ballBRight;
                ballAMoveUp = ballBUp;
                ballANewXSpd = ballBXSpeed;
                ballANewYSpd = ballBYSpeed;
                
                ballBCommand <= 4'b0011;
                ballBMoveRight = ballARight;
                ballBMoveUp = ballAUp;
                ballBNewXSpd = ballAXSpeed;
                ballBNewYSpd = ballAYSpeed;
                
            
            end 
            else begin
                ballACommand <= 4'b0011;
                ballAMoveRight = (!ballARight && ballAXSpeed != 0) ?
                                 ((ballBRight && ballBXSpeed > ballAXSpeed) || ballBXSpeed == 0) ? 0 : 1 :
                                 (!ballBRight && ballBXSpeed != 0 && (ballBXSpeed < ballAXSpeed || ballAXSpeed == 0)) ? 0 : 1;
                                 
                ballAMoveUp = (!ballAUp && ballAYSpeed != 0) ?
                              (ballBYSpeed == 0 || (ballBUp && ballBYSpeed > ballAYSpeed)) ? 0 : 1 : 1;
                              
                ballANewXSpd = average;
                ballANewYSpd = average;
                
                ballBCommand <= 4'b0011;
                ballBMoveRight = (ballAMoveUp && ballAMoveRight) ? ballBRight : 0; 
                ballBMoveUp = (ballAMoveUp == ballAMoveRight) ? 0 : ballBUp;
                ballBNewXSpd = average;
                ballBNewYSpd = average;
            
            end
        end   
        
         if (!isColliding && (((ballAXpos - 2 == ballBXpos) && (ballAYpos - 2 == ballBYpos)) ||
           ((ballAXpos - 1 == ballBXpos) && (ballAYpos - 1 == ballBYpos))))
        begin
//                top_1 <= 1; B bottom right with A top left
            if ((ballAXSpeed == ballAYSpeed && ballAXSpeed != 0) ||
                (ballBXSpeed == ballBYSpeed && ballBXSpeed != 0)) begin
                
                ballACommand <= 4'b0011;
                ballAMoveRight = ballBRight;
                ballAMoveUp = ballBUp;
                ballANewXSpd = ballBXSpeed;
                ballANewYSpd = ballBYSpeed;
                
                ballBCommand <= 4'b0011;
                ballBMoveRight = ballARight;
                ballBMoveUp = ballAUp;
                ballBNewXSpd = ballAXSpeed;
                ballBNewYSpd = ballAYSpeed;
                
            
            end 
            else begin
                ballBCommand <= 4'b0011;
                ballBMoveRight = (ballBRight && ballBXSpeed != 0) ?
                                 ((!ballARight && ballAXSpeed > ballAXSpeed) || ballAXSpeed == 0) ? 1 : 0 :
                                 (ballARight && ballAXSpeed != 0 && (ballAXSpeed < ballBXSpeed || ballBXSpeed == 0)) ? 1 : 0;
                                 
                ballBMoveUp = (!ballBUp && ballBYSpeed != 0) ?
                              (ballAYSpeed == 0 || (ballAUp && ballAYSpeed > ballBYSpeed)) ? 0 : 1 : 1;
                              
                ballBNewXSpd = average;
                ballBNewYSpd = average;
                
                ballACommand <= 4'b0011;
                ballAMoveRight = (ballBMoveUp && !ballBMoveRight) ? ballARight : 1; 
                ballAMoveUp = (ballBMoveUp == ballBMoveRight) ? 0 : ballAUp;
                ballANewXSpd = average;
                ballANewYSpd = average;
            
            end
            
        end
        
         if (!isColliding && (ballAXpos + 1 == ballBXpos) && ((ballAYpos) == (ballBYpos + 2)))
        begin
//                top_2 <= 1;
            ballBCommand <= 4'b0011;
            ballBMoveRight = 1;              
            ballBMoveUp = 1;                 
            ballBNewXSpd = average;
            ballBNewYSpd = average << 1;
            
            ballACommand <= 4'b0011;
            ballAMoveRight = 0;
            ballAMoveUp = 0;
            ballANewXSpd = average << 1;
            ballANewYSpd = average;
        end
        
         if (!isColliding && (ballAXpos - 1 == ballBXpos) && ((ballAYpos) == (ballBYpos + 2)))
        begin
//                top_3 <= 1;
            ballBCommand <= 4'b0011;
            ballBMoveRight = ballBRight;              
            ballBMoveUp = 1;                 
            ballBNewXSpd = average;
            ballBNewYSpd = average << 1;
            
            ballACommand <= 4'b0011;
            ballAMoveRight = 1;
            ballAMoveUp = 0;
            ballANewXSpd = average << 1;
            ballANewYSpd = average;
        end
        
         if (!isColliding && (ballAXpos == ballBXpos - 2) && ((ballAYpos) == (ballBYpos + 2)))
        begin
//                top_4 <= 1; A top right with B bottom left
            if ((ballAXSpeed == ballAYSpeed && ballAXSpeed != 0) ||
                (ballBXSpeed == ballBYSpeed && ballBXSpeed != 0)) begin
                
                ballACommand <= 4'b0011;
                ballAMoveRight = ballBRight;
                ballAMoveUp = ballBUp;
                ballANewXSpd = ballBXSpeed;
                ballANewYSpd = ballBYSpeed;
                
                ballBCommand <= 4'b0011;
                ballBMoveRight = ballARight;
                ballBMoveUp = ballAUp;
                ballBNewXSpd = ballAXSpeed;
                ballBNewYSpd = ballAYSpeed;
                
            
            end 
            else begin
                ballBCommand <= 4'b0011;
                ballBMoveRight = (!ballBRight && ballBXSpeed != 0) ?
                                 ((ballARight && ballAXSpeed > ballBXSpeed) || ballAXSpeed == 0) ? 0 : 1 :
                                 (!ballARight && ballAXSpeed != 0 && (ballAXSpeed < ballBXSpeed || ballBXSpeed == 0)) ? 0 : 1;
                                 
                ballBMoveUp = (!ballBUp && ballBYSpeed != 0) ?
                              (ballAYSpeed == 0 || (ballAUp && ballAYSpeed > ballBYSpeed)) ? 0 : 1 : 1;
                              
                ballBNewXSpd = average;
                ballBNewYSpd = average;
                
                ballACommand <= 4'b0011;
                ballAMoveRight = (ballBMoveUp && ballBMoveRight) ? ballARight : 0; 
                ballAMoveUp = (ballBMoveUp == ballBMoveRight) ? 0 : ballAUp;
                ballANewXSpd = average;
                ballANewYSpd = average;
            
            end
        end 
        
         if (!isColliding && (ballAYpos + 1 == ballBYpos) && ((ballAXpos) == (ballBXpos - 2)))
        begin
//                left_2 <= 1;
            ballACommand <= 4'b0011;
            ballAMoveRight = 1;              
            ballAMoveUp = ballAUp;                 
            ballANewXSpd = average;
            ballANewYSpd = average << 1;
            
            ballBCommand <= 4'b0011;
            ballBMoveRight = 1;
            ballBMoveUp = 0;
            ballBNewXSpd = average << 1;
            ballBNewYSpd = average;
        end
        
         if (!isColliding && (ballAYpos - 1 == ballBYpos) && ((ballAXpos) == (ballBXpos - 2)))
        begin
//                left_3 <= 1;
            ballACommand <= 4'b0011;
            ballAMoveRight = 0;              
            ballAMoveUp = ballAUp;                 
            ballANewYSpd = average;
            ballANewXSpd = average << 1;
            
            ballBCommand <= 4'b0011;
            ballBMoveRight = 1;
            ballBMoveUp = 1;
            ballBNewYSpd = average << 1;
            ballBNewXSpd = average;
        end
        
         if (!isColliding && (ballAYpos + 1 == ballBYpos) && ((ballAXpos) == (ballBXpos + 2)))
        begin
//                right_2 <= 1;
            ballBCommand <= 4'b0011;
            ballBMoveRight = 1;              
            ballBMoveUp = ballBUp;                 
            ballBNewXSpd = average;
            ballBNewYSpd = average << 1;
            
            ballACommand <= 4'b0011;
            ballAMoveRight = 1;
            ballAMoveUp = 0;
            ballANewXSpd = average << 1;
            ballANewYSpd = average;
        end
        
         if (!isColliding && (ballAYpos - 1 == ballBYpos) && ((ballAXpos) == (ballBXpos + 2)))
        begin
        //                right_3 <= 1;
            ballBCommand <= 4'b0011;
            ballBMoveRight = 0;              
            ballBMoveUp = ballBUp;                 
            ballBNewYSpd = average;
            ballBNewXSpd = average << 1;
            
            ballACommand <= 4'b0011;
            ballAMoveRight = 1;
            ballAMoveUp = 1;
            ballANewYSpd = average << 1;
            ballANewXSpd = average;
        end
        
            if (isColliding && ballAUp == ballBUp && ballBRight == ballARight && ballAXSpeed == ballBXSpeed && ballAYSpeed == ballBYSpeed && (ballAXSpeed != 0 || ballAYSpeed != 0)) begin
          
				ballACommand <= 4'b0011;
				ballBCommand <= 4'b0011;
				ballAMoveUp = ballAYpos < ballBYpos;
				ballBMoveUp = ~ballAMoveUp;
				
				ballAMoveRight = ballAXpos > ballBXpos;
				ballBMoveRight = ~ballAMoveRight;
    
            end
    
        isColliding = (ballAXpos >= ballBXpos - 2 && ballAXpos <= ballBXpos + 2 && ballAYpos >= ballBYpos - 2 && ballAYpos <= ballBYpos + 2) ||
            (ballBXpos >= ballAXpos - 2 && ballBXpos <= ballAXpos + 2 && ballBYpos >= ballAYpos - 2 && ballBYpos <= ballAYpos + 2) ? 1 : 0; 
            
    end

endmodule
