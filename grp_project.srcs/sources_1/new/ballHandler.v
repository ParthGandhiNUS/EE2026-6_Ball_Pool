`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.03.2024 22:36:54
// Design Name: 
// Module Name: ballHandler
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


module ballHandler(
    
    input btnC,
    input reset,
    input btnL,
    input btnR,
    input btnU,
    input leftClick,
    input btnD,
    input sysClk,
    input movementClk,
    input collisionClk,
    input placerClk,
    output [6:0] seg,
    output dp,
    input [7:0] wallLeft,
    input [7:0] wallRight,
    input [6:0] wallUp,
    input [6:0] wallDown,
    input [7:0] x,
    output [4:0] led,
    input [6:0] y,
    input [11:0] mouseXpos,
    input [11:0] mouseYpos,
    output [15:0] pixelData,
    output [3:0] an
    );

    localparam leftCol = 7'd58;
    localparam rightCol = 7'd62;
    localparam row1 = 7'd20;
    localparam row2 = 7'd24;
    localparam row3 = 7'd26;
    localparam row4 = 7'd28;
    localparam row5 = 7'd32;
    
    reg [3:0] commandWhite = 4'b0001;
    reg [7:0] newXSpeedWhite = 1;
    reg [7:0] newYSpeedWhite = 1;
    reg newMoveRightWhite = 0;
    reg newMoveUpWhite = 0;
    wire [7:0] ySpeedWhite;
    wire [7:0] xSpeedWhite;
    wire whiteRight;
    wire whiteUp;    
    wire [7:0] xPosWhite;
    wire [6:0] yPosWhite;    
    reg [7:0] newXPosWhite = 20;
    reg [6:0] newYPosWhite = 40;
    wire isWhiteBallMoving;
    
    reg [3:0] commandBlack = 4'b0001;
    reg [7:0] newXSpeedBlack = 1;
    reg [7:0] newYSpeedBlack = 2;
    reg [7:0]newXPosBlack = 30;
    reg [6:0]newYPosBlack = 30;
    reg newMoveRightBlack = 1;
    reg newMoveUpBlack = 0;
    wire [7:0] ySpeedBlack;
    wire [7:0] xSpeedBlack;
    wire blackRight;
    wire blackUp;
    wire [7:0] xPosBlack;
    wire [6:0] yPosBlack;
    wire isBlackBallMoving;
    
    ball whiteBall(
    
        .command(commandWhite),
        .newXSpeed(newXSpeedWhite),
        .newYSpeed(newYSpeedWhite),
        .newXPos(newXPosWhite),
        .newYPos(newYPosWhite),
        .moveRight(newMoveRightWhite),
        .moveUp(newMoveUpWhite),
        .movementClk(movementClk),
        .collisionClk(collisionClk),
        .xPos(xPosWhite),
        .yPos(yPosWhite),
        .ySpeed(ySpeedWhite),
        .xSpeed(xSpeedWhite),
        .movingRight(whiteRight),
        .movingUp(whiteUp),
        .wallLeft(wallLeft),
        .wallRight(wallRight),
        .wallUp(wallUp),
        .wallDown(wallDown),
        .isMoving(isWhiteBallMoving)
        );    
        
    ball blackBall(
    
        .command(commandBlack),
        .newXSpeed(newXSpeedBlack),
        .newYSpeed(newYSpeedBlack),
        .newXPos(newXPosBlack),
        .newYPos(newYPosBlack),
        .moveRight(newMoveRightBlack),
        .moveUp(newMoveUpBlack),
        .movementClk(movementClk),
        .collisionClk(collisionClk),
        .xPos(xPosBlack),
        .yPos(yPosBlack),
        .ySpeed(ySpeedBlack),
        .xSpeed(xSpeedBlack),
        .movingRight(blackRight),
        .movingUp(blackUp),
        .wallLeft(wallLeft),
        .wallRight(wallRight),
        .wallUp(wallUp),
        .wallDown(wallDown),
        .isMoving(isBlackBallMoving)
        );    
    
    reg [3:0] commandSolA = 4'b0001;
    reg [7:0] newXSpeedSolA = 0;
    reg [7:0] newYSpeedSolA = 0;
    reg newMoveRightSolA = 0;
    reg newMoveUpSolA = 0;
    wire [7:0] ySpeedSolA;
    wire [7:0] xSpeedSolA;
    wire SolARight;
    wire SolAUp;    
    wire [7:0] xPosSolA;
    wire [6:0] yPosSolA;    
    reg [7:0] newXPosSolA = 11;
    reg [6:0] newYPosSolA = 11;
    wire isSolAMoving;
    
    reg [3:0] commandSolB = 4'b0001;
    reg [7:0] newXSpeedSolB = 0;
    reg [7:0] newYSpeedSolB = 0;
    reg [7:0]newXPosSolB = 60;
    reg [6:0]newYPosSolB = 60;
    reg newMoveRightSolB = 1;
    reg newMoveUpSolB = 0;
    wire [7:0] ySpeedSolB;
    wire [7:0] xSpeedSolB;
    wire SolBRight;
    wire SolBUp;
    wire [7:0] xPosSolB;
    wire [6:0] yPosSolB;
    wire isSolBMoving;
    
    ball SolidA(
    
        .command(commandSolA),
        .newXSpeed(newXSpeedSolA),
        .newYSpeed(newYSpeedSolA),
        .newXPos(newXPosSolA),
        .newYPos(newYPosSolA),
        .moveRight(newMoveRightSolA),
        .moveUp(newMoveUpSolA),
        .movementClk(movementClk),
        .collisionClk(collisionClk),
        .xPos(xPosSolA),
        .yPos(yPosSolA),
        .ySpeed(ySpeedSolA),
        .xSpeed(xSpeedSolA),
        .movingRight(SolARight),
        .movingUp(SolAUp),
        .wallLeft(wallLeft),
        .wallRight(wallRight),
        .wallUp(wallUp),
        .wallDown(wallDown),
        .isMoving(isSolAMoving)
        );    
        
    ball SolidB(
    
        .command(commandSolB),
        .newXSpeed(newXSpeedSolB),
        .newYSpeed(newYSpeedSolB),
        .newXPos(newXPosSolB),
        .newYPos(newYPosSolB),
        .moveRight(newMoveRightSolB),
        .moveUp(newMoveUpSolB),
        .movementClk(movementClk),
        .collisionClk(collisionClk),
        .xPos(xPosSolB),
        .yPos(yPosSolB),
        .ySpeed(ySpeedSolB),
        .xSpeed(xSpeedSolB),
        .movingRight(SolBRight),
        .movingUp(SolBUp),
        .wallLeft(wallLeft),
        .wallRight(wallRight),
        .wallUp(wallUp),
        .wallDown(wallDown),
        .isMoving(isSolBMoving)
        );    
        
    reg [3:0] commandStrA = 4'b0001;
    reg [7:0] newXSpeedStrA = 0;
    reg [7:0] newYSpeedStrA = 0;
    reg newMoveRightStrA = 0;
    reg newMoveUpStrA = 0;
    wire [7:0] ySpeedStrA;
    wire [7:0] xSpeedStrA;
    wire StrARight;
    wire StrAUp;    
    wire [7:0] xPosStrA;
    wire [6:0] yPosStrA;    
    reg [7:0] newXPosStrA = 11;
    reg [6:0] newYPosStrA = 11;
    wire isStrAMoving;
    
    reg [3:0] commandStrB = 4'b0001;
    reg [7:0] newXSpeedStrB = 0;
    reg [7:0] newYSpeedStrB = 0;
    reg [7:0]newXPosStrB = 60;
    reg [6:0]newYPosStrB = 60;
    reg newMoveRightStrB = 1;
    reg newMoveUpStrB = 0;
    wire [7:0] ySpeedStrB;
    wire [7:0] xSpeedStrB;
    wire StrBRight;
    wire StrBUp;
    wire [7:0] xPosStrB;
    wire [6:0] yPosStrB;
    wire isStrBMoving;
    
    ball StripeA(
    
        .command(commandStrA),
        .newXSpeed(newXSpeedStrA),
        .newYSpeed(newYSpeedStrA),
        .newXPos(newXPosStrA),
        .newYPos(newYPosStrA),
        .moveRight(newMoveRightStrA),
        .moveUp(newMoveUpStrA),
        .movementClk(movementClk),
        .collisionClk(collisionClk),
        .xPos(xPosStrA),
        .yPos(yPosStrA),
        .ySpeed(ySpeedStrA),
        .xSpeed(xSpeedStrA),
        .movingRight(StrARight),
        .movingUp(StrAUp),
        .wallLeft(wallLeft),
        .wallRight(wallRight),
        .wallUp(wallUp),
        .wallDown(wallDown),
        .isMoving(isStrAMoving)
        );    
        
    ball StripeB(
    
        .command(commandStrB),
        .newXSpeed(newXSpeedStrB),
        .newYSpeed(newYSpeedStrB),
        .newXPos(newXPosStrB),
        .newYPos(newYPosStrB),
        .moveRight(newMoveRightStrB),
        .moveUp(newMoveUpStrB),
        .movementClk(movementClk),
        .collisionClk(collisionClk),
        .xPos(xPosStrB),
        .yPos(yPosStrB),
        .ySpeed(ySpeedStrB),
        .xSpeed(xSpeedStrB),
        .movingRight(StrBRight),
        .movingUp(StrBUp),
        .wallLeft(wallLeft),
        .wallRight(wallRight),
        .wallUp(wallUp),
        .wallDown(wallDown),
        .isMoving(isStrBMoving)
        );
        
    wire [7:0] newWhiteXShotSpeed;
    wire [7:0] newWhiteYShotSpeed;   
//    wire isAnyBallMoving;
//    assign isAnyBallMoving = isWhiteBallMoving || isBlackBallMoving || isSolAMoving || isSolBMoving || isStrAMoving || isStrBMoving;
    displayManager dsp (
        .clk(sysClk),
        .x_oled(x),
        .y_oled(y),
        .pixel_data(pixelData),
        .xPosWhite(xPosWhite),
        .yPosWhite(yPosWhite),
        .xPosBlack(xPosBlack),
        .yPosBlack(yPosBlack),     
        .xPosSolA(xPosSolA),
        .yPosSolA(yPosSolA),
        .xPosSolB(xPosSolB),
        .yPosSolB(yPosSolB),     
        .xPosStrA(xPosStrA),
        .yPosStrA(yPosStrA),
        .xPosStrB(xPosStrB),
        .yPosStrB(yPosStrB),
        .inputx1(mouseXpos[6:0]),
        .inputx0(xPosWhite),
        .inputy1(mouseYpos[6:0]),
        .inputy0(yPosWhite),
        .mouse_1(leftClick), 
        .start(1), 
        .enable(1),
        .xSpeed(newWhiteXShotSpeed),
        .ySpeed(newWhiteYShotSpeed)
        );
        
    
    wire BWColliding;
    wire [3:0] BWwhiteNewCommand;
    wire [3:0] BWblackNewCommand;
    wire [7:0] BWwhiteNewX;
    wire [7:0] BWwhiteNewXpos;    
    wire [6:0] BWwhiteNewYpos;    
    wire [7:0] BWblackNewXpos;    
    wire [6:0] BWblackNewYpos;
    wire BWwhiteNewRight;
    wire [7:0] BWwhiteNewY;
    wire BWwhiteNewUp;
    wire [7:0] BWblackNewX;
    wire BWblackNewRight;
    wire [7:0] BWblackNewY;
    wire BWblackNewUp;
    
    collision WhiteBlackColl(
    
        .collisionClk(collisionClk),
        .ballAXpos(xPosWhite),
        .ballAYpos(yPosWhite),
        .ballAXSpeed(xSpeedWhite),
        .ballAYSpeed(ySpeedWhite),
        .ballARight(whiteRight),
        .ballAUp(whiteUp),
        .ballAMoving(isWhiteBallMoving),
        
        .ballBXpos(xPosBlack),
        .ballBYpos(yPosBlack),
        .ballBXSpeed(xSpeedBlack),
        .ballBYSpeed(ySpeedBlack),
        .ballBRight(blackRight),
        .ballBUp(blackUp),
        .ballBMoving(isBlackBallMoving),
        
        .isColliding(BWColliding),
        .ballACommand(BWwhiteNewCommand),
        .ballBCommand(BWblackNewCommand),
        .ballANewXSpd(BWwhiteNewX),
        .ballANewX(BWwhiteNewXpos),
        .ballANewY(BWwhiteNewYpos),        
        .ballBNewX(BWblackNewXpos),
        .ballBNewY(BWblackNewYpos),
        .ballAMoveRight(BWwhiteNewRight),
        .ballANewYSpd(BWwhiteNewY),
        .ballAMoveUp(BWwhiteNewUp),
        .ballBNewXSpd(BWblackNewX),
        .ballBMoveRight(BWblackNewRight),
        .ballBNewYSpd(BWblackNewY),
        .ballBMoveUp(BWblackNewUp)
    );    
    
    wire SolAWColliding;
    wire [3:0] SolAWwhiteNewCommand;
    wire [3:0] SolAWsolANewCommand;
    wire [7:0] SolAWwhiteNewX;
    wire [7:0] SolAWwhiteNewXpos;    
    wire [6:0] SolAWwhiteNewYpos;    
    wire [7:0] SolAWsolANewXpos;    
    wire [6:0] SolAWsolANewYpos;
    wire SolAWwhiteNewRight;
    wire [7:0] SolAWwhiteNewY;
    wire SolAWwhiteNewUp;
    wire [7:0] SolAWsolANewX;
    wire SolAWsolANewRight;
    wire [7:0] SolAWsolANewY;
    wire SolAWsolANewUp;
    
    collision WhiteSolAColl(
    
        .collisionClk(collisionClk),
        .ballAXpos(xPosWhite),
        .ballAYpos(yPosWhite),
        .ballAXSpeed(xSpeedWhite),
        .ballAYSpeed(ySpeedWhite),
        .ballARight(whiteRight),
        .ballAUp(whiteUp),
        .ballAMoving(isWhiteBallMoving),
        
        .ballBXpos(xPosSolA),
        .ballBYpos(yPosSolA),
        .ballBXSpeed(xSpeedSolA),
        .ballBYSpeed(ySpeedSolA),
        .ballBRight(SolARight),
        .ballBUp(SolAUp),
        .ballBMoving(isSolAMoving),
        
        .isColliding(SolAWColliding),
        .ballACommand(SolAWwhiteNewCommand),
        .ballBCommand(SolAWsolANewCommand),
        .ballANewXSpd(SolAWwhiteNewX),
        .ballANewX(SolAWwhiteNewXpos),
        .ballANewY(SolAWwhiteNewYpos),        
        .ballBNewX(SolAWsolANewXpos),
        .ballBNewY(SolAWsolANewYpos),
        .ballAMoveRight(SolAWwhiteNewRight),
        .ballANewYSpd(SolAWwhiteNewY),
        .ballAMoveUp(SolAWwhiteNewUp),
        .ballBNewXSpd(SolAWsolANewX),
        .ballBMoveRight(SolAWsolANewRight),
        .ballBNewYSpd(SolAWsolANewY),
        .ballBMoveUp(SolAWsolANewUp)
    );
        
    	wire SolBWColliding;
        wire [3:0] SolBWwhiteNewCommand;
        wire [3:0] SolBWsolBNewCommand;
        wire [7:0] SolBWwhiteNewX;
        wire [7:0] SolBWwhiteNewXpos;    
        wire [6:0] SolBWwhiteNewYpos;    
        wire [7:0] SolBWsolBNewXpos;    
        wire [6:0] SolBWsolBNewYpos;
        wire SolBWwhiteNewRight;
        wire [7:0] SolBWwhiteNewY;
        wire SolBWwhiteNewUp;
        wire [7:0] SolBWsolBNewX;
        wire SolBWsolBNewRight;
        wire [7:0] SolBWsolBNewY;
        wire SolBWsolBNewUp;
        
	collision WhiteSolBColl(
        
		.collisionClk(collisionClk),
		.ballAXpos(xPosWhite),
		.ballAYpos(yPosWhite),
		.ballAXSpeed(xSpeedWhite),
		.ballAYSpeed(ySpeedWhite),
		.ballARight(whiteRight),
		.ballAUp(whiteUp),
		.ballAMoving(isWhiteBallMoving),
		
		.ballBXpos(xPosSolB),
		.ballBYpos(yPosSolB),
		.ballBXSpeed(xSpeedSolB),
		.ballBYSpeed(ySpeedSolB),
		.ballBRight(SolBRight),
		.ballBUp(SolBUp),
		.ballBMoving(isSolBMoving),
		
		.isColliding(SolBWColliding),
		.ballACommand(SolBWwhiteNewCommand),
		.ballBCommand(SolBWsolBNewCommand),
		.ballANewXSpd(SolBWwhiteNewX),
		.ballANewX(SolBWwhiteNewXpos),
		.ballANewY(SolBWwhiteNewYpos),        
		.ballBNewX(SolBWsolBNewXpos),
		.ballBNewY(SolBWsolBNewYpos),
		.ballAMoveRight(SolBWwhiteNewRight),
		.ballANewYSpd(SolBWwhiteNewY),
		.ballAMoveUp(SolBWwhiteNewUp),
		.ballBNewXSpd(SolBWsolBNewX),
		.ballBMoveRight(SolBWsolBNewRight),
		.ballBNewYSpd(SolBWsolBNewY),
		.ballBMoveUp(SolBWsolBNewUp)
	);    
	
		wire StrAWColliding;
	    wire [3:0] StrAWwhiteNewCommand;
	    wire [3:0] StrAWstrANewCommand;
	    wire [7:0] StrAWwhiteNewX;
	    wire [7:0] StrAWwhiteNewXpos;    
	    wire [6:0] StrAWwhiteNewYpos;    
	    wire [7:0] StrAWstrANewXpos;    
	    wire [6:0] StrAWstrANewYpos;
	    wire StrAWwhiteNewRight;
	    wire [7:0] StrAWwhiteNewY;
	    wire StrAWwhiteNewUp;
	    wire [7:0] StrAWstrANewX;
	    wire StrAWstrANewRight;
	    wire [7:0] StrAWstrANewY;
	    wire StrAWstrANewUp;
	    
	    collision WhiteStrAColl(
	    
	        .collisionClk(collisionClk),
	        .ballAXpos(xPosWhite),
	        .ballAYpos(yPosWhite),
	        .ballAXSpeed(xSpeedWhite),
	        .ballAYSpeed(ySpeedWhite),
	        .ballARight(whiteRight),
	        .ballAUp(whiteUp),
	        .ballAMoving(isWhiteBallMoving),
	        
	        .ballBXpos(xPosStrA),
	        .ballBYpos(yPosStrA),
	        .ballBXSpeed(xSpeedStrA),
	        .ballBYSpeed(ySpeedStrA),
	        .ballBRight(StrARight),
	        .ballBUp(StrAUp),
	        .ballBMoving(isStrAMoving),
	        
	        .isColliding(StrAWColliding),
	        .ballACommand(StrAWwhiteNewCommand),
	        .ballBCommand(StrAWstrANewCommand),
	        .ballANewXSpd(StrAWwhiteNewX),
	        .ballANewX(StrAWwhiteNewXpos),
	        .ballANewY(StrAWwhiteNewYpos),        
	        .ballBNewX(StrAWstrANewXpos),
	        .ballBNewY(StrAWstrANewYpos),
	        .ballAMoveRight(StrAWwhiteNewRight),
	        .ballANewYSpd(StrAWwhiteNewY),
	        .ballAMoveUp(StrAWwhiteNewUp),
	        .ballBNewXSpd(StrAWstrANewX),
	        .ballBMoveRight(StrAWstrANewRight),
	        .ballBNewYSpd(StrAWstrANewY),
	        .ballBMoveUp(StrAWstrANewUp)
	    );
	    
	    wire StrBWColliding;
		wire [3:0] StrBWwhiteNewCommand;
		wire [3:0] StrBWstrBNewCommand;
		wire [7:0] StrBWwhiteNewX;
		wire [7:0] StrBWwhiteNewXpos;    
		wire [6:0] StrBWwhiteNewYpos;    
		wire [7:0] StrBWstrBNewXpos;    
		wire [6:0] StrBWstrBNewYpos;
		wire StrBWwhiteNewRight;
		wire [7:0] StrBWwhiteNewY;
		wire StrBWwhiteNewUp;
		wire [7:0] StrBWstrBNewX;
		wire StrBWstrBNewRight;
		wire [7:0] StrBWstrBNewY;
		wire StrBWstrBNewUp;
		
		collision WhiteStrBColl(
		
			.collisionClk(collisionClk),
			.ballAXpos(xPosWhite),
			.ballAYpos(yPosWhite),
			.ballAXSpeed(xSpeedWhite),
			.ballAYSpeed(ySpeedWhite),
			.ballARight(whiteRight),
			.ballAUp(whiteUp),
			.ballAMoving(isWhiteBallMoving),
			
			.ballBXpos(xPosStrB),
			.ballBYpos(yPosStrB),
			.ballBXSpeed(xSpeedStrB),
			.ballBYSpeed(ySpeedStrB),
			.ballBRight(StrBRight),
			.ballBUp(StrBUp),
			.ballBMoving(isStrBMoving),
			
			.isColliding(StrBWColliding),
			.ballACommand(StrBWwhiteNewCommand),
			.ballBCommand(StrBWstrBNewCommand),
			.ballANewXSpd(StrBWwhiteNewX),
			.ballANewX(StrBWwhiteNewXpos),
			.ballANewY(StrBWwhiteNewYpos),        
			.ballBNewX(StrBWstrBNewXpos),
			.ballBNewY(StrBWstrBNewYpos),
			.ballAMoveRight(StrBWwhiteNewRight),
			.ballANewYSpd(StrBWwhiteNewY),
			.ballAMoveUp(StrBWwhiteNewUp),
			.ballBNewXSpd(StrBWstrBNewX),
			.ballBMoveRight(StrBWstrBNewRight),
			.ballBNewYSpd(StrBWstrBNewY),
			.ballBMoveUp(StrBWstrBNewUp)
		);
	    
	    wire StrBBColliding;
		wire [3:0] StrBBblackNewCommand;
		wire [3:0] StrBBstrBNewCommand;
		wire [7:0] StrBBblackNewX;
		wire [7:0] StrBBblackNewXpos;    
		wire [6:0] StrBBblackNewYpos;    
		wire [7:0] StrBBstrBNewXpos;    
		wire [6:0] StrBBstrBNewYpos;
		wire StrBBblackNewRight;
		wire [7:0] StrBBblackNewY;
		wire StrBBblackNewUp;
		wire [7:0] StrBBstrBNewX;
		wire StrBBstrBNewRight;
		wire [7:0] StrBBstrBNewY;
		wire StrBBstrBNewUp;
		
		collision BlackStrBColl(
		
			.collisionClk(collisionClk),
			.ballAXpos(xPosBlack),
			.ballAYpos(yPosBlack),
			.ballAXSpeed(xSpeedBlack),
			.ballAYSpeed(ySpeedBlack),
			.ballARight(blackRight),
			.ballAUp(blackUp),
			.ballAMoving(isBlackBallMoving),
			
			.ballBXpos(xPosStrB),
			.ballBYpos(yPosStrB),
			.ballBXSpeed(xSpeedStrB),
			.ballBYSpeed(ySpeedStrB),
			.ballBRight(StrBRight),
			.ballBUp(StrBUp),
			.ballBMoving(isStrBMoving),
			
			.isColliding(StrBBColliding),
			.ballACommand(StrBBblackNewCommand),
			.ballBCommand(StrBBstrBNewCommand),
			.ballANewXSpd(StrBBblackNewX),
			.ballANewX(StrBBblackNewXpos),
			.ballANewY(StrBBblackNewYpos),        
			.ballBNewX(StrBBstrBNewXpos),
			.ballBNewY(StrBBstrBNewYpos),
			.ballAMoveRight(StrBBblackNewRight),
			.ballANewYSpd(StrBBblackNewY),
			.ballAMoveUp(StrBBblackNewUp),
			.ballBNewXSpd(StrBBstrBNewX),
			.ballBMoveRight(StrBBstrBNewRight),
			.ballBNewYSpd(StrBBstrBNewY),
			.ballBMoveUp(StrBBstrBNewUp)
		);
	    
		wire StrABColliding;
		wire [3:0] StrABblackNewCommand;
		wire [3:0] StrABstrANewCommand;
		wire [7:0] StrABblackNewX;
		wire [7:0] StrABblackNewXpos;    
		wire [6:0] StrABblackNewYpos;    
		wire [7:0] StrABstrANewXpos;    
		wire [6:0] StrABstrANewYpos;
		wire StrABblackNewRight;
		wire [7:0] StrABblackNewY;
		wire StrABblackNewUp;
		wire [7:0] StrABstrANewX;
		wire StrABstrANewRight;
		wire [7:0] StrABstrANewY;
		wire StrABstrANewUp;
		
		collision BlackStrAColl(
		
		    .collisionClk(collisionClk),
		    .ballAXpos(xPosBlack),
		    .ballAYpos(yPosBlack),
		    .ballAXSpeed(xSpeedBlack),
		    .ballAYSpeed(ySpeedBlack),
		    .ballARight(blackRight),
		    .ballAUp(blackUp),
		    .ballAMoving(isBlackBallMoving),
		    
		    .ballBXpos(xPosStrA),
		    .ballBYpos(yPosStrA),
		    .ballBXSpeed(xSpeedStrA),
		    .ballBYSpeed(ySpeedStrA),
		    .ballBRight(StrARight),
		    .ballBUp(StrAUp),
		    .ballBMoving(isStrAMoving),
		    
		    .isColliding(StrABColliding),
		    .ballACommand(StrABblackNewCommand),
		    .ballBCommand(StrABstrANewCommand),
		    .ballANewXSpd(StrABblackNewX),
		    .ballANewX(StrABblackNewXpos),
		    .ballANewY(StrABblackNewYpos),        
		    .ballBNewX(StrABstrANewXpos),
		    .ballBNewY(StrABstrANewYpos),
		    .ballAMoveRight(StrABblackNewRight),
		    .ballANewYSpd(StrABblackNewY),
		    .ballAMoveUp(StrABblackNewUp),
		    .ballBNewXSpd(StrABstrANewX),
		    .ballBMoveRight(StrABstrANewRight),
		    .ballBNewYSpd(StrABstrANewY),
		    .ballBMoveUp(StrABstrANewUp)
		);
		
		wire SolBBColliding;
		wire [3:0] SolBBblackNewCommand;
		wire [3:0] SolBBsolBNewCommand;
		wire [7:0] SolBBblackNewX;
		wire [7:0] SolBBblackNewXpos;    
		wire [6:0] SolBBblackNewYpos;    
		wire [7:0] SolBBsolBNewXpos;    
		wire [6:0] SolBBsolBNewYpos;
		wire SolBBblackNewRight;
		wire [7:0] SolBBblackNewY;
		wire SolBBblackNewUp;
		wire [7:0] SolBBsolBNewX;
		wire SolBBsolBNewRight;
		wire [7:0] SolBBsolBNewY;
		wire SolBBsolBNewUp;
		
		collision BlackSolBColl(
		
		    .collisionClk(collisionClk),
		    .ballAXpos(xPosBlack),
		    .ballAYpos(yPosBlack),
		    .ballAXSpeed(xSpeedBlack),
		    .ballAYSpeed(ySpeedBlack),
		    .ballARight(blackRight),
		    .ballAUp(blackUp),
		    .ballAMoving(isBlackBallMoving),
		    
		    .ballBXpos(xPosSolB),
		    .ballBYpos(yPosSolB),
		    .ballBXSpeed(xSpeedSolB),
		    .ballBYSpeed(ySpeedSolB),
		    .ballBRight(SolBRight),
		    .ballBUp(SolBUp),
		    .ballBMoving(isSolBMoving),
		    
		    .isColliding(SolBBColliding),
		    .ballACommand(SolBBblackNewCommand),
		    .ballBCommand(SolBBsolBNewCommand),
		    .ballANewXSpd(SolBBblackNewX),
		    .ballANewX(SolBBblackNewXpos),
		    .ballANewY(SolBBblackNewYpos),        
		    .ballBNewX(SolBBsolBNewXpos),
		    .ballBNewY(SolBBsolBNewYpos),
		    .ballAMoveRight(SolBBblackNewRight),
		    .ballANewYSpd(SolBBblackNewY),
		    .ballAMoveUp(SolBBblackNewUp),
		    .ballBNewXSpd(SolBBsolBNewX),
		    .ballBMoveRight(SolBBsolBNewRight),
		    .ballBNewYSpd(SolBBsolBNewY),
		    .ballBMoveUp(SolBBsolBNewUp)
		);
	    
		wire SolABColliding;
		wire [3:0] SolABblackNewCommand;
		wire [3:0] SolABsolANewCommand;
		wire [7:0] SolABblackNewX;
		wire [7:0] SolABblackNewXpos;    
		wire [6:0] SolABblackNewYpos;    
		wire [7:0] SolABsolANewXpos;    
		wire [6:0] SolABsolANewYpos;
		wire SolABblackNewRight;
		wire [7:0] SolABblackNewY;
		wire SolABblackNewUp;
		wire [7:0] SolABsolANewX;
		wire SolABsolANewRight;
		wire [7:0] SolABsolANewY;
		wire SolABsolANewUp;
		
		collision BlackSolAColl(
		
		    .collisionClk(collisionClk),
		    .ballAXpos(xPosBlack),
		    .ballAYpos(yPosBlack),
		    .ballAXSpeed(xSpeedBlack),
		    .ballAYSpeed(ySpeedBlack),
		    .ballARight(blackRight),
		    .ballAUp(blackUp),
		    .ballAMoving(isBlackBallMoving),
		    
		    .ballBXpos(xPosSolA),
		    .ballBYpos(yPosSolA),
		    .ballBXSpeed(xSpeedSolA),
		    .ballBYSpeed(ySpeedSolA),
		    .ballBRight(SolARight),
		    .ballBUp(SolAUp),
		    .ballBMoving(isSolAMoving),
		    
		    .isColliding(SolABColliding),
		    .ballACommand(SolABblackNewCommand),
		    .ballBCommand(SolABsolANewCommand),
		    .ballANewXSpd(SolABblackNewX),
		    .ballANewX(SolABblackNewXpos),
		    .ballANewY(SolABblackNewYpos),        
		    .ballBNewX(SolABsolANewXpos),
		    .ballBNewY(SolABsolANewYpos),
		    .ballAMoveRight(SolABblackNewRight),
		    .ballANewYSpd(SolABblackNewY),
		    .ballAMoveUp(SolABblackNewUp),
		    .ballBNewXSpd(SolABsolANewX),
		    .ballBMoveRight(SolABsolANewRight),
		    .ballBNewYSpd(SolABsolANewY),
		    .ballBMoveUp(SolABsolANewUp)
		);
		
		wire SolBSolAColliding;
		wire [3:0] SolBSolAsolANewCommand;
		wire [3:0] SolBSolAsolBNewCommand;
		wire [7:0] SolBSolAsolANewX;
		wire [7:0] SolBSolAsolANewXpos;    
		wire [6:0] SolBSolAsolANewYpos;    
		wire [7:0] SolBSolAsolBNewXpos;    
		wire [6:0] SolBSolAsolBNewYpos;
		wire SolBSolAsolANewRight;
		wire [7:0] SolBSolAsolANewY;
		wire SolBSolAsolANewUp;
		wire [7:0] SolBSolAsolBNewX;
		wire SolBSolAsolBNewRight;
		wire [7:0] SolBSolAsolBNewY;
		wire SolBSolAsolBNewUp;
		
		collision SolASolBColl(
		
		    .collisionClk(collisionClk),
		    .ballAXpos(xPosSolA),
		    .ballAYpos(yPosSolA),
		    .ballAXSpeed(xSpeedSolA),
		    .ballAYSpeed(ySpeedSolA),
		    .ballARight(SolARight),
		    .ballAUp(SolAUp),
		    .ballAMoving(isSolAMoving),
		    
		    .ballBXpos(xPosSolB),
		    .ballBYpos(yPosSolB),
		    .ballBXSpeed(xSpeedSolB),
		    .ballBYSpeed(ySpeedSolB),
		    .ballBRight(SolBRight),
		    .ballBUp(SolBUp),
		    .ballBMoving(isSolBMoving),
		    
		    .isColliding(SolBSolAColliding),
		    .ballACommand(SolBSolAsolANewCommand),
		    .ballBCommand(SolBSolAsolBNewCommand),
		    .ballANewXSpd(SolBSolAsolANewX),
		    .ballANewX(SolBSolAsolANewXpos),
		    .ballANewY(SolBSolAsolANewYpos),        
		    .ballBNewX(SolBSolAsolBNewXpos),
		    .ballBNewY(SolBSolAsolBNewYpos),
		    .ballAMoveRight(SolBSolAsolANewRight),
		    .ballANewYSpd(SolBSolAsolANewY),
		    .ballAMoveUp(SolBSolAsolANewUp),
		    .ballBNewXSpd(SolBSolAsolBNewX),
		    .ballBMoveRight(SolBSolAsolBNewRight),
		    .ballBNewYSpd(SolBSolAsolBNewY),
		    .ballBMoveUp(SolBSolAsolBNewUp)
		);
		
		wire StrASolAColliding;
		wire [3:0] StrASolAsolANewCommand;
		wire [3:0] StrASolAstrANewCommand;
		wire [7:0] StrASolAsolANewX;
		wire [7:0] StrASolAsolANewXpos;    
		wire [6:0] StrASolAsolANewYpos;    
		wire [7:0] StrASolAstrANewXpos;    
		wire [6:0] StrASolAstrANewYpos;
		wire StrASolAsolANewRight;
		wire [7:0] StrASolAsolANewY;
		wire StrASolAsolANewUp;
		wire [7:0] StrASolAstrANewX;
		wire StrASolAstrANewRight;
		wire [7:0] StrASolAstrANewY;
		wire StrASolAstrANewUp;
		
		collision SolAStrAColl(
		
		    .collisionClk(collisionClk),
		    .ballAXpos(xPosSolA),
		    .ballAYpos(yPosSolA),
		    .ballAXSpeed(xSpeedSolA),
		    .ballAYSpeed(ySpeedSolA),
		    .ballARight(SolARight),
		    .ballAUp(SolAUp),
		    .ballAMoving(isSolAMoving),
		    
		    .ballBXpos(xPosStrA),
		    .ballBYpos(yPosStrA),
		    .ballBXSpeed(xSpeedStrA),
		    .ballBYSpeed(ySpeedStrA),
		    .ballBRight(StrARight),
		    .ballBUp(StrAUp),
		    .ballBMoving(isStrAMoving),
		    
		    .isColliding(StrASolAColliding),
		    .ballACommand(StrASolAsolANewCommand),
		    .ballBCommand(StrASolAstrANewCommand),
		    .ballANewXSpd(StrASolAsolANewX),
		    .ballANewX(StrASolAsolANewXpos),
		    .ballANewY(StrASolAsolANewYpos),        
		    .ballBNewX(StrASolAstrANewXpos),
		    .ballBNewY(StrASolAstrANewYpos),
		    .ballAMoveRight(StrASolAsolANewRight),
		    .ballANewYSpd(StrASolAsolANewY),
		    .ballAMoveUp(StrASolAsolANewUp),
		    .ballBNewXSpd(StrASolAstrANewX),
		    .ballBMoveRight(StrASolAstrANewRight),
		    .ballBNewYSpd(StrASolAstrANewY),
		    .ballBMoveUp(StrASolAstrANewUp)
		);
		
		wire StrBSolAColliding;
		wire [3:0] StrBSolAsolANewCommand;
		wire [3:0] StrBSolAstrBNewCommand;
		wire [7:0] StrBSolAsolANewX;
		wire [7:0] StrBSolAsolANewXpos;    
		wire [6:0] StrBSolAsolANewYpos;    
		wire [7:0] StrBSolAstrBNewXpos;    
		wire [6:0] StrBSolAstrBNewYpos;
		wire StrBSolAsolANewRight;
		wire [7:0] StrBSolAsolANewY;
		wire StrBSolAsolANewUp;
		wire [7:0] StrBSolAstrBNewX;
		wire StrBSolAstrBNewRight;
		wire [7:0] StrBSolAstrBNewY;
		wire StrBSolAstrBNewUp;
		
		collision SolAStrBColl(
		
		    .collisionClk(collisionClk),
		    .ballAXpos(xPosSolA),
		    .ballAYpos(yPosSolA),
		    .ballAXSpeed(xSpeedSolA),
		    .ballAYSpeed(ySpeedSolA),
		    .ballARight(SolARight),
		    .ballAUp(SolAUp),
		    .ballAMoving(isSolAMoving),
		    
		    .ballBXpos(xPosStrB),
		    .ballBYpos(yPosStrB),
		    .ballBXSpeed(xSpeedStrB),
		    .ballBYSpeed(ySpeedStrB),
		    .ballBRight(StrBRight),
		    .ballBUp(StrBUp),
		    .ballBMoving(isStrBMoving),
		    
		    .isColliding(StrBSolAColliding),
		    .ballACommand(StrBSolAsolANewCommand),
		    .ballBCommand(StrBSolAstrBNewCommand),
		    .ballANewXSpd(StrBSolAsolANewX),
		    .ballANewX(StrBSolAsolANewXpos),
		    .ballANewY(StrBSolAsolANewYpos),        
		    .ballBNewX(StrBSolAstrBNewXpos),
		    .ballBNewY(StrBSolAstrBNewYpos),
		    .ballAMoveRight(StrBSolAsolANewRight),
		    .ballANewYSpd(StrBSolAsolANewY),
		    .ballAMoveUp(StrBSolAsolANewUp),
		    .ballBNewXSpd(StrBSolAstrBNewX),
		    .ballBMoveRight(StrBSolAstrBNewRight),
		    .ballBNewYSpd(StrBSolAstrBNewY),
		    .ballBMoveUp(StrBSolAstrBNewUp)
		);
		
		wire StrBSolBColliding;
		wire [3:0] StrBSolBsolBNewCommand;
		wire [3:0] StrBSolBstrBNewCommand;
		wire [7:0] StrBSolBsolBNewX;
		wire [7:0] StrBSolBsolBNewXpos;    
		wire [6:0] StrBSolBsolBNewYpos;    
		wire [7:0] StrBSolBstrBNewXpos;    
		wire [6:0] StrBSolBstrBNewYpos;
		wire StrBSolBsolBNewRight;
		wire [7:0] StrBSolBsolBNewY;
		wire StrBSolBsolBNewUp;
		wire [7:0] StrBSolBstrBNewX;
		wire StrBSolBstrBNewRight;
		wire [7:0] StrBSolBstrBNewY;
		wire StrBSolBstrBNewUp;
		
		collision SolBStrBColl(
		
		    .collisionClk(collisionClk),
		    .ballAXpos(xPosSolB),
		    .ballAYpos(yPosSolB),
		    .ballAXSpeed(xSpeedSolB),
		    .ballAYSpeed(ySpeedSolB),
		    .ballARight(SolBRight),
		    .ballAUp(SolBUp),
		    .ballAMoving(isSolBMoving),
		    
		    .ballBXpos(xPosStrB),
		    .ballBYpos(yPosStrB),
		    .ballBXSpeed(xSpeedStrB),
		    .ballBYSpeed(ySpeedStrB),
		    .ballBRight(StrBRight),
		    .ballBUp(StrBUp),
		    .ballBMoving(isStrBMoving),
		    
		    .isColliding(StrBSolBColliding),
		    .ballACommand(StrBSolBsolBNewCommand),
		    .ballBCommand(StrBSolBstrBNewCommand),
		    .ballANewXSpd(StrBSolBsolBNewX),
		    .ballANewX(StrBSolBsolBNewXpos),
		    .ballANewY(StrBSolBsolBNewYpos),        
		    .ballBNewX(StrBSolBstrBNewXpos),
		    .ballBNewY(StrBSolBstrBNewYpos),
		    .ballAMoveRight(StrBSolBsolBNewRight),
		    .ballANewYSpd(StrBSolBsolBNewY),
		    .ballAMoveUp(StrBSolBsolBNewUp),
		    .ballBNewXSpd(StrBSolBstrBNewX),
		    .ballBMoveRight(StrBSolBstrBNewRight),
		    .ballBNewYSpd(StrBSolBstrBNewY),
		    .ballBMoveUp(StrBSolBstrBNewUp)
		);
		
		wire StrASolBColliding;
		wire [3:0] StrASolBsolBNewCommand;
		wire [3:0] StrASolBstrANewCommand;
		wire [7:0] StrASolBsolBNewX;
		wire [7:0] StrASolBsolBNewXpos;    
		wire [6:0] StrASolBsolBNewYpos;    
		wire [7:0] StrASolBstrANewXpos;    
		wire [6:0] StrASolBstrANewYpos;
		wire StrASolBsolBNewRight;
		wire [7:0] StrASolBsolBNewY;
		wire StrASolBsolBNewUp;
		wire [7:0] StrASolBstrANewX;
		wire StrASolBstrANewRight;
		wire [7:0] StrASolBstrANewY;
		wire StrASolBstrANewUp;
		
		collision SolBStrAColl(
		
		    .collisionClk(collisionClk),
		    .ballAXpos(xPosSolB),
		    .ballAYpos(yPosSolB),
		    .ballAXSpeed(xSpeedSolB),
		    .ballAYSpeed(ySpeedSolB),
		    .ballARight(SolBRight),
		    .ballAUp(SolBUp),
		    .ballAMoving(isSolBMoving),
		    
		    .ballBXpos(xPosStrA),
		    .ballBYpos(yPosStrA),
		    .ballBXSpeed(xSpeedStrA),
		    .ballBYSpeed(ySpeedStrA),
		    .ballBRight(StrARight),
		    .ballBUp(StrAUp),
		    .ballBMoving(isStrAMoving),
		    
		    .isColliding(StrASolBColliding),
		    .ballACommand(StrASolBsolBNewCommand),
		    .ballBCommand(StrASolBstrANewCommand),
		    .ballANewXSpd(StrASolBsolBNewX),
		    .ballANewX(StrASolBsolBNewXpos),
		    .ballANewY(StrASolBsolBNewYpos),        
		    .ballBNewX(StrASolBstrANewXpos),
		    .ballBNewY(StrASolBstrANewYpos),
		    .ballAMoveRight(StrASolBsolBNewRight),
		    .ballANewYSpd(StrASolBsolBNewY),
		    .ballAMoveUp(StrASolBsolBNewUp),
		    .ballBNewXSpd(StrASolBstrANewX),
		    .ballBMoveRight(StrASolBstrANewRight),
		    .ballBNewYSpd(StrASolBstrANewY),
		    .ballBMoveUp(StrASolBstrANewUp)
		);
		
		wire StrBStrAColliding;
		wire [3:0] StrBStrAstrANewCommand;
		wire [3:0] StrBStrAstrBNewCommand;
		wire [7:0] StrBStrAstrANewX;
		wire [7:0] StrBStrAstrANewXpos;    
		wire [6:0] StrBStrAstrANewYpos;    
		wire [7:0] StrBStrAstrBNewXpos;    
		wire [6:0] StrBStrAstrBNewYpos;
		wire StrBStrAstrANewRight;
		wire [7:0] StrBStrAstrANewY;
		wire StrBStrAstrANewUp;
		wire [7:0] StrBStrAstrBNewX;
		wire StrBStrAstrBNewRight;
		wire [7:0] StrBStrAstrBNewY;
		wire StrBStrAstrBNewUp;
		
		collision StrAStrBColl(
		
		    .collisionClk(collisionClk),
		    .ballAXpos(xPosStrA),
		    .ballAYpos(yPosStrA),
		    .ballAXSpeed(xSpeedStrA),
		    .ballAYSpeed(ySpeedStrA),
		    .ballARight(StrARight),
		    .ballAUp(StrAUp),
		    .ballAMoving(isStrAMoving),
		    
		    .ballBXpos(xPosStrB),
		    .ballBYpos(yPosStrB),
		    .ballBXSpeed(xSpeedStrB),
		    .ballBYSpeed(ySpeedStrB),
		    .ballBRight(StrBRight),
		    .ballBUp(StrBUp),
		    .ballBMoving(isStrBMoving),
		    
		    .isColliding(StrBStrAColliding),
		    .ballACommand(StrBStrAstrANewCommand),
		    .ballBCommand(StrBStrAstrBNewCommand),
		    .ballANewXSpd(StrBStrAstrANewX),
		    .ballANewX(StrBStrAstrANewXpos),
		    .ballANewY(StrBStrAstrANewYpos),        
		    .ballBNewX(StrBStrAstrBNewXpos),
		    .ballBNewY(StrBStrAstrBNewYpos),
		    .ballAMoveRight(StrBStrAstrANewRight),
		    .ballANewYSpd(StrBStrAstrANewY),
		    .ballAMoveUp(StrBStrAstrANewUp),
		    .ballBNewXSpd(StrBStrAstrBNewX),
		    .ballBMoveRight(StrBStrAstrBNewRight),
		    .ballBNewYSpd(StrBStrAstrBNewY),
		    .ballBMoveUp(StrBStrAstrBNewUp)
		);
		
		
		wire [7:0] newXPosWhiteShift;
		wire [6:0] newYPosWhiteShift;
		WhiteBallPlacer shiftW(
			.clk(placerClk),
			.wallLeft(wallLeft),
			.wallRight(wallRight),
			.wallUp(wallUp),
			.wallDown(wallDown), 
			.btnU(btnU),
			.btnD(btnD),
			.btnL(btnL),
			.btnR(btnR),
			.commandWhite(commandWhite),
			.xPos(xPosWhite),
			.yPos(yPosWhite),
			.newXPos(newXPosWhiteShift),
			.newYPos(newYPosWhiteShift)
			);	
			
		wire wShotNewMoveRight;
		wire wShotNewMoveUp;
		WhiteBallShooter shootW(
			.clk(sysClk),
			.isWhiteBallMoving(isWhiteBallMoving),
			.xPosWhite(xPosWhite),
			.yPosWhite(yPosWhite),
			.xPosCursor(mouseXpos),
			.yPosCursor(mouseYpos),
			.newXSpeed(newWhiteXShotSpeed),
			.newYSpeed(newWhiteYShotSpeed),
			.moveRight(wShotNewMoveRight),
			.moveUp(wShotNewMoveUp)
			);
			
		
		
			wire [5:0] allScore; //in order: [5] == white [4] == black [3] == StrA [2] == StrB [1] == SolA [2] == SolB
			wire [7:0] newXPosWhiteScore;
			wire [6:0] newYPosWhiteScore;
			ScoreChecker WScore(
				.clk(sysClk),
				.xPos(xPosWhite),
				.yPos(yPosWhite),
                .reset(reset),
				.ball(6'b100000),
				.isScored(allScore[5]),
				.newXPos(newXPosWhiteScore),
				.newYPos(newYPosWhiteScore)
				);
				
			wire [7:0] newXPosBlackScore;
			wire [6:0] newYPosBlackScore;
			ScoreChecker BScore(
			.clk(sysClk),
			.xPos(xPosBlack),
			.yPos(yPosBlack),
            .reset(reset),
			.ball(6'b010000),
			.isScored(allScore[4]),
			.newXPos(newXPosBlackScore),
			.newYPos(newYPosBlackScore)
			);
	
			wire [7:0] newXPosStrAScore;
			wire [6:0] newYPosStrAScore;
			ScoreChecker StrAScore(
			.clk(sysClk),
			.xPos(xPosStrA),
			.yPos(yPosStrA),
            .reset(reset),
			.ball(6'b001000),
			.isScored(allScore[3]),
			.newXPos(newXPosStrAScore),
			.newYPos(newYPosStrAScore)
			);
			
			wire [7:0] newXPosStrBScore;
			wire [6:0] newYPosStrBScore;
			ScoreChecker StrBScore(
			.clk(sysClk),
			.xPos(xPosStrB),
			.yPos(yPosStrB),
            .reset(reset),
			.ball(6'b000100),
			.isScored(allScore[2]),
			.newXPos(newXPosStrBScore),
			.newYPos(newYPosStrBScore)
			);
			
			wire [7:0] newXPosSolAScore;
			wire [6:0] newYPosSolAScore;
			ScoreChecker SolAScore(
			.clk(sysClk),
			.xPos(xPosSolA),
			.yPos(yPosSolA),
			.reset(reset),
			.ball(6'b000010),
			.isScored(allScore[1]),
			.newXPos(newXPosSolAScore),
			.newYPos(newYPosSolAScore)
			);
			
			wire [7:0] newXPosSolBScore;
			wire [6:0] newYPosSolBScore;
			ScoreChecker SolBScore(
			.clk(sysClk),
			.xPos(xPosSolB),
			.yPos(yPosSolB),
			.reset(reset),
			.ball(6'b000001),
			.isScored(allScore[0]),
			.newXPos(newXPosSolBScore),
			.newYPos(newYPosSolBScore)
			);


reg [1:0] startingState = 0;
reg whiteBallPotted = 0;
reg placedWhiteBall;
wire calculationDone;		
wire placeWhiteBall;
gameLogic game(

    .anClk(movementClk),
    .clk(sysClk),
    .allScore(allScore[4:0]), 
    .BWColliding(BWColliding),
    .SolAWColliding(SolAWColliding),
    .SolBWColliding(SolBWColliding),
    .StrAWColliding(StrAWColliding),
    .StrBWColliding(StrBWColliding),
    .isWhiteBallMoving(isWhiteBallMoving),
    .isBlackBallMoving(isBlackBallMoving),
    .isStrAMoving(isStrAMoving),
    .isStrBMoving(isStrBMoving),
    .isSolAMoving(isSolAMoving),
    .isSolBMoving(isSolBMoving),
    .reset(reset),
    .seg(seg),
    .dp(dp),
    .whiteBallPotted(whiteBallPotted),
    .an(an),
    .calculationDone(calculationDone)
    );

always @ (posedge placerClk) begin
    startingState <= startingState + 1;
end

always @ (posedge sysClk) begin
//collisions for white
//need to set all variables back to their default/current values
    commandWhite <= 0;
    
    if (!whiteBallPotted && BWColliding) begin
        newMoveRightWhite <= BWwhiteNewRight;
        newMoveUpWhite <= BWwhiteNewUp;
        newXSpeedWhite <= BWwhiteNewX;
        newYSpeedWhite <= BWwhiteNewY;
        newXPosWhite <= BWwhiteNewXpos;
        newYPosWhite <= BWwhiteNewYpos;
        commandWhite <= 4'b0011;  
    
    end
    
    else if (SolAWColliding) begin
    
        newMoveRightWhite <= SolAWwhiteNewRight;
        newMoveUpWhite <= SolAWwhiteNewUp;
        newXSpeedWhite <= SolAWwhiteNewX;
        newYSpeedWhite <= SolAWwhiteNewY;   
        newXPosWhite <= SolAWwhiteNewXpos;
        newYPosWhite <= SolAWwhiteNewYpos; 
        commandWhite <= 4'b0011;   
    
    end 
    
    else if (SolBWColliding) begin
    
        newMoveRightWhite <= SolBWwhiteNewRight;
        newMoveUpWhite <= SolBWwhiteNewUp;
        newXSpeedWhite <= SolBWwhiteNewX;
        newYSpeedWhite <= SolBWwhiteNewY;   
        newXPosWhite <= SolBWwhiteNewXpos;
        newYPosWhite <= SolBWwhiteNewYpos; 
        commandWhite <= 4'b0011;  
    end
    
    else if (StrAWColliding) begin
    
        newMoveRightWhite <= StrAWwhiteNewRight;
        newMoveUpWhite <= StrAWwhiteNewUp;
        newXSpeedWhite <= StrAWwhiteNewX;
        newYSpeedWhite <= StrAWwhiteNewY;   
        newXPosWhite <= StrAWwhiteNewXpos;
        newYPosWhite <= StrAWwhiteNewYpos; 
        commandWhite <= 4'b0011;  
    end
    
    else if (StrBWColliding) begin
    
        newMoveRightWhite <= StrBWwhiteNewRight;
        newMoveUpWhite <= StrBWwhiteNewUp;
        newXSpeedWhite <= StrBWwhiteNewX;
        newYSpeedWhite <= StrBWwhiteNewY;   
        newXPosWhite <= StrBWwhiteNewXpos;
        newYPosWhite <= StrBWwhiteNewYpos; 
        commandWhite <= 4'b0011;  
    end

//collisions for black

//need to set all variables back to their default/current values
    commandBlack <= 0;
    
    if (!whiteBallPotted && BWColliding) begin
        newMoveRightBlack <= BWblackNewRight;
        newMoveUpBlack <= BWblackNewUp;
        newXSpeedBlack <= BWblackNewX;
        newYSpeedBlack <= BWblackNewY;
        newXPosBlack <= BWblackNewXpos;
        newYPosBlack <= BWblackNewYpos;
        commandBlack <= 4'b0011;  
    
    end
    
    else if (SolABColliding) begin
    
        newMoveRightBlack <= SolABblackNewRight;
        newMoveUpBlack <= SolABblackNewUp;
        newXSpeedBlack <= SolABblackNewX;
        newYSpeedBlack <= SolABblackNewY;   
        newXPosBlack <= SolABblackNewXpos;
        newYPosBlack <= SolABblackNewYpos; 
        commandBlack <= 4'b0011;   
    
    end 
    
    else if (SolBBColliding) begin
    
        newMoveRightBlack <= SolBBblackNewRight;
        newMoveUpBlack <= SolBBblackNewUp;
        newXSpeedBlack <= SolBBblackNewX;
        newYSpeedBlack <= SolBBblackNewY;   
        newXPosBlack <= SolBBblackNewXpos;
        newYPosBlack <= SolBBblackNewYpos; 
        commandBlack <= 4'b0011;  
    end
    
    else if (StrABColliding) begin
    
        newMoveRightBlack <= StrABblackNewRight;
        newMoveUpBlack <= StrABblackNewUp;
        newXSpeedBlack <= StrABblackNewX;
        newYSpeedBlack <= StrABblackNewY;   
        newXPosBlack <= StrABblackNewXpos;
        newYPosBlack <= StrABblackNewYpos; 
        commandBlack <= 4'b0011;  
    end
    
    else if (StrBBColliding) begin
    
        newMoveRightBlack <= StrBBblackNewRight;
        newMoveUpBlack <= StrBBblackNewUp;
        newXSpeedBlack <= StrBBblackNewX;
        newYSpeedBlack <= StrBBblackNewY;   
        newXPosBlack <= StrBBblackNewXpos;
        newYPosBlack <= StrBBblackNewYpos; 
        commandBlack <= 4'b0011;  
    end

//collisions for SolA

//need to set all variables back to their default/current values
    commandSolA <= 0;
    
    if (!whiteBallPotted && SolAWColliding) begin
        newMoveRightSolA <= SolAWsolANewRight;
        newMoveUpSolA <= SolAWsolANewUp;
        newXSpeedSolA <= SolAWsolANewX;
        newYSpeedSolA <= SolAWsolANewY;
        newXPosSolA <= SolAWsolANewXpos;
        newYPosSolA <= SolAWsolANewYpos;
        commandSolA <= 4'b0011;  
    
    end
    
    else if (SolABColliding) begin
    
        newMoveRightSolA <= SolABsolANewRight;
        newMoveUpSolA <= SolABsolANewUp;
        newXSpeedSolA <= SolABsolANewX;
        newYSpeedSolA <= SolABsolANewY;   
        newXPosSolA <= SolABsolANewXpos;
        newYPosSolA <= SolABsolANewYpos; 
        commandSolA <= 4'b0011;   
    
    end 
    
    else if (SolBSolAColliding) begin
    
        newMoveRightSolA <= SolBSolAsolANewRight;
        newMoveUpSolA <= SolBSolAsolANewUp;
        newXSpeedSolA <= SolBSolAsolANewX;
        newYSpeedSolA <= SolBSolAsolANewY;   
        newXPosSolA <= SolBSolAsolANewXpos;
        newYPosSolA <= SolBSolAsolANewYpos; 
        commandSolA <= 4'b0011;  
    end
    
    else if (StrASolAColliding) begin
    
        newMoveRightSolA <= StrASolAsolANewRight;
        newMoveUpSolA <= StrASolAsolANewUp;
        newXSpeedSolA <= StrASolAsolANewX;
        newYSpeedSolA <= StrASolAsolANewY;   
        newXPosSolA <= StrASolAsolANewXpos;
        newYPosSolA <= StrASolAsolANewYpos; 
        commandSolA <= 4'b0011;  
    end
    
    else if (StrBSolAColliding) begin
    
        newMoveRightSolA <= StrBSolAsolANewRight;
        newMoveUpSolA <= StrBSolAsolANewUp;
        newXSpeedSolA <= StrBSolAsolANewX;
        newYSpeedSolA <= StrBSolAsolANewY;   
        newXPosSolA <= StrBSolAsolANewXpos;
        newYPosSolA <= StrBSolAsolANewYpos; 
        commandSolA <= 4'b0011;  
    end

//collisions for SolB

//need to set all variables back to their default/current values
    commandSolB <= 0;

    if (!whiteBallPotted && SolBWColliding) begin
        newMoveRightSolB <= SolBWsolBNewRight;
        newMoveUpSolB <= SolBWsolBNewUp;
        newXSpeedSolB <= SolBWsolBNewX;
        newYSpeedSolB <= SolBWsolBNewY;
        newXPosSolB <= SolBWsolBNewXpos;
        newYPosSolB <= SolBWsolBNewYpos;
        commandSolB <= 4'b0011;  
    
    end
    
    else if (SolBBColliding) begin
    
        newMoveRightSolB <= SolBBsolBNewRight;
        newMoveUpSolB <= SolBBsolBNewUp;
        newXSpeedSolB <= SolBBsolBNewX;
        newYSpeedSolB <= SolBBsolBNewY;   
        newXPosSolB <= SolBBsolBNewXpos;
        newYPosSolB <= SolBBsolBNewYpos; 
        commandSolB <= 4'b0011;   
    
    end 
    
    else if (SolBSolAColliding) begin
    
        newMoveRightSolB <= SolBSolAsolBNewRight;
        newMoveUpSolB <= SolBSolAsolBNewUp;
        newXSpeedSolB <= SolBSolAsolBNewX;
        newYSpeedSolB <= SolBSolAsolBNewY;   
        newXPosSolB <= SolBSolAsolBNewXpos;
        newYPosSolB <= SolBSolAsolBNewYpos; 
        commandSolB <= 4'b0011;  
    end
    
    else if (StrASolBColliding) begin
    
        newMoveRightSolB <= StrASolBsolBNewRight;
        newMoveUpSolB <= StrASolBsolBNewUp;
        newXSpeedSolB <= StrASolBsolBNewX;
        newYSpeedSolB <= StrASolBsolBNewY;   
        newXPosSolB <= StrASolBsolBNewXpos;
        newYPosSolB <= StrASolBsolBNewYpos; 
        commandSolB <= 4'b0011;  
    end
    
    else if (StrBSolBColliding) begin
    
        newMoveRightSolB <= StrBSolBsolBNewRight;
        newMoveUpSolB <= StrBSolBsolBNewUp;
        newXSpeedSolB <= StrBSolBsolBNewX;
        newYSpeedSolB <= StrBSolBsolBNewY;   
        newXPosSolB <= StrBSolBsolBNewXpos;
        newYPosSolB <= StrBSolBsolBNewYpos; 
        commandSolB <= 4'b0011;  
    end 

//collisions for StrA

//need to set all variables back to their default/current values
    commandStrA <= 0;

    if (!whiteBallPotted && StrAWColliding) begin
        newMoveRightStrA <= StrAWstrANewRight;
        newMoveUpStrA <= StrAWstrANewUp;
        newXSpeedStrA <= StrAWstrANewX;
        newYSpeedStrA <= StrAWstrANewY;
        newXPosStrA <= StrAWstrANewXpos;
        newYPosStrA <= StrAWstrANewYpos;
        commandStrA <= 4'b0011;  
    
    end
    
    else if (StrABColliding) begin
    
        newMoveRightStrA <= StrABstrANewRight;
        newMoveUpStrA <= StrABstrANewUp;
        newXSpeedStrA <= StrABstrANewX;
        newYSpeedStrA <= StrABstrANewY;   
        newXPosStrA <= StrABstrANewXpos;
        newYPosStrA <= StrABstrANewYpos; 
        commandStrA <= 4'b0011;   
    
    end
    
    else if (StrBStrAColliding) begin
    
        newMoveRightStrA <= StrBStrAstrANewRight;
        newMoveUpStrA <= StrBStrAstrANewUp;
        newXSpeedStrA <= StrBStrAstrANewX;
        newYSpeedStrA <= StrBStrAstrANewY;   
        newXPosStrA <= StrBStrAstrANewXpos;
        newYPosStrA <= StrBStrAstrANewYpos; 
        commandStrA <= 4'b0011;  
    end 
    
    else if (StrASolBColliding) begin
    
        newMoveRightStrA <= StrASolBstrANewRight;
        newMoveUpStrA <= StrASolBstrANewUp;
        newXSpeedStrA <= StrASolBstrANewX;
        newYSpeedStrA <= StrASolBstrANewY;   
        newXPosStrA <= StrASolBstrANewXpos;
        newYPosStrA <= StrASolBstrANewYpos;
        commandStrA <= 4'b0011;  
    end
    
    else if (StrASolAColliding) begin
    
        newMoveRightStrA <= StrASolAstrANewRight;
        newMoveUpStrA <= StrASolAstrANewUp;
        newXSpeedStrA <= StrASolAstrANewX;
        newYSpeedStrA <= StrASolAstrANewY;   
        newXPosStrA <= StrASolAstrANewXpos;
        newYPosStrA <= StrASolAstrANewYpos; 
        commandStrA <= 4'b0011;  
    end

//collisions for StrB

//need to set all variables back to their default/current values
    commandStrB <= 0;
    
    if (!whiteBallPotted && StrBWColliding) begin
    
        newMoveRightStrB <= StrBWstrBNewRight;
        newMoveUpStrB <= StrBWstrBNewUp;
        newXSpeedStrB <= StrBWstrBNewX;
        newYSpeedStrB <= StrBWstrBNewY;
        newXPosStrB <= StrBWstrBNewXpos;
        newYPosStrB <= StrBWstrBNewYpos;
        commandStrB <= 4'b0011;  
    
    end
    
    else if (StrBBColliding) begin
    
        newMoveRightStrB <= StrBBstrBNewRight;
        newMoveUpStrB <= StrBBstrBNewUp;
        newXSpeedStrB <= StrBBstrBNewX;
        newYSpeedStrB <= StrBBstrBNewY;   
        newXPosStrB <= StrBBstrBNewXpos;
        newYPosStrB <= StrBBstrBNewYpos; 
        commandStrB <= 4'b0011;   
    
    end
    
    else if (StrBStrAColliding) begin
    
        newMoveRightStrB <= StrBStrAstrBNewRight;
        newMoveUpStrB <= StrBStrAstrBNewUp;
        newXSpeedStrB <= StrBStrAstrBNewX;
        newYSpeedStrB <= StrBStrAstrBNewY;   
        newXPosStrB <= StrBStrAstrBNewXpos;
        newYPosStrB <= StrBStrAstrBNewYpos; 
        commandStrB <= 4'b0011;  
    end 
    
    else if (StrBSolBColliding) begin
    
        newMoveRightStrB <= StrBSolBstrBNewRight;
        newMoveUpStrB <= StrBSolBstrBNewUp;
        newXSpeedStrB <= StrBSolBstrBNewX;
        newYSpeedStrB <= StrBSolBstrBNewY;   
        newXPosStrB <= StrBSolBstrBNewXpos;
        newYPosStrB <= StrBSolBstrBNewYpos; 
        commandStrB <= 4'b0011;  
    end
    
    else if (StrBSolBColliding) begin
    
        newMoveRightStrB <= StrBSolBstrBNewRight;
        newMoveUpStrB <= StrBSolBstrBNewUp;
        newXSpeedStrB <= StrBSolBstrBNewX;
        newYSpeedStrB <= StrBSolBstrBNewY;   
        newXPosStrB <= StrBSolBstrBNewXpos;
        newYPosStrB <= StrBSolBstrBNewYpos; 
        commandStrB <= 4'b0011;  
    end

	if (allScore[5])  begin
		commandWhite <= 4'b0010;
		newYPosWhite <= newYPosWhiteScore;
		newXPosWhite <= newXPosWhiteScore;

	end
	
	//if white was potted and hence placed outside of the field, reset to somewhere on the table when all balls stop moving
	if (xPosWhite == 50 && yPosWhite == 60 && !isBlackBallMoving && !isStrAMoving && !isStrBMoving && !isSolAMoving && !isSolBMoving) begin
		commandWhite <= 4'b0010;
		newYPosWhite <= 27;
		newXPosWhite <= 50;
        whiteBallPotted <= 1;
        placedWhiteBall <= 0;
		//probably include a new wire
		//isWhiteReset <= 1; for future where there are multiple scenarios that a white place is warranted. As of now, still use switch to move after white is reset to (27,50)
		end
				
	if (allScore[4])  begin
		commandBlack <= 4'b0010;
		newYPosBlack <= newYPosBlackScore;
		newXPosBlack <= newXPosBlackScore;
	end
	
	if (allScore[3])  begin
		commandStrA <= 4'b0010;
		newYPosStrA <= newYPosStrAScore;
		newXPosStrA <= newXPosStrAScore;
	end
	
	if (allScore[2])  begin
		commandStrB <= 4'b0010;
		newYPosStrB <= newYPosStrBScore;
		newXPosStrB <= newXPosStrBScore;
	end
		
	if (allScore[1])  begin
		commandSolA <= 4'b0010;
		newYPosSolA <= newYPosSolAScore;
		newXPosSolA <= newXPosSolAScore;
	end
	
	if (allScore[0])  begin
		commandSolB <= 4'b0010;
		newYPosSolB <= newYPosSolBScore;
		newXPosSolB <= newXPosSolBScore;
	end
	
	if ((whiteBallPotted && !placedWhiteBall) && !isBlackBallMoving && !isStrAMoving && !isStrBMoving && !isSolAMoving && !isSolBMoving) begin
		commandWhite <= 4'b0010;
		newXPosWhite <= newXPosWhiteShift;
		newYPosWhite <= newYPosWhiteShift;
		
		if (btnC && !BWColliding && !SolAWColliding && !SolBWColliding && !StrAWColliding && !StrBWColliding
		      && newXPosWhiteShift > wallLeft && newXPosWhiteShift < wallRight
		      && newYPosWhiteShift > wallUp && newYPosWhiteShift < wallDown) begin
		      
		  placedWhiteBall <= 1;
		  whiteBallPotted <= 0;
		end
	end	
	
    if (leftClick && !whiteBallPotted && !isWhiteBallMoving && 
    !isBlackBallMoving && !isStrAMoving && !isStrBMoving && !isSolAMoving && !isSolBMoving) begin
    
    	commandWhite <= 4'b0011;
    	newMoveRightWhite <= wShotNewMoveRight;
    	newMoveUpWhite <= wShotNewMoveUp;
    	newXSpeedWhite <= newWhiteXShotSpeed;
    	newYSpeedWhite <= newWhiteYShotSpeed;
    	
    end   
    	
    if (reset) begin

        placedWhiteBall <= 0;
		whiteBallPotted <= 0;
		
        case (startingState)

            2'b00: begin
                newXPosWhite <= 24;
                newYPosWhite <= 26;
                commandWhite <= 4'b0010;
                
                newXPosBlack <= rightCol;
                newYPosBlack <= row3;  
                commandBlack <= 4'b0010;     
                
                newXPosSolA <= rightCol;
                newYPosSolA <= row1;
                commandSolA <= 4'b0010;
                
                newXPosSolB <= rightCol;
                newYPosSolB <= row5;
                commandSolB <= 4'b0010;        
                
                newXPosStrA <= leftCol;
                newYPosStrA <= row2;
                commandStrA <= 4'b0010;
                
                newXPosStrB <= leftCol;
                newYPosStrB <= row4;
                commandStrB <= 4'b0010;
            end

            2'b01: begin
                newXPosWhite <= 24;
                newYPosWhite <= 26;
                commandWhite <= 4'b0010;
                
                newXPosBlack <= rightCol;
                newYPosBlack <= row3;  
                commandBlack <= 4'b0010;     
                
                newXPosStrA <= rightCol;
                newYPosStrA <= row1;
                commandStrA <= 4'b0010;
                
                newXPosSolB <= rightCol;
                newYPosSolB <= row5;
                commandSolB <= 4'b0010;        
                
                newXPosSolA <= leftCol;
                newYPosSolA <= row2;
                commandSolA <= 4'b0010;
                
                newXPosStrB <= leftCol;
                newYPosStrB <= row4;
                commandStrB <= 4'b0010;
            end

            2'b10: begin
                newXPosWhite <= 24;
                newYPosWhite <= 25;
                commandWhite <= 4'b0010;
                
                newXPosBlack <= rightCol;
                newYPosBlack <= row3;  
                commandBlack <= 4'b0010;     
                
                newXPosSolA <= rightCol;
                newYPosSolA <= row1;
                commandSolA <= 4'b0010;
                
                newXPosSolB <= rightCol;
                newYPosSolB <= row5;
                commandSolB <= 4'b0010;        
                
                newXPosStrA <= leftCol;
                newYPosStrA <= row2;
                commandStrA <= 4'b0010;
                
                newXPosStrB <= leftCol;
                newYPosStrB <= row4;
                commandStrB <= 4'b0010;
            end

            2'b11: begin
                newXPosWhite <= 24;
                newYPosWhite <= 25;
                commandWhite <= 4'b0010;
                
                newXPosBlack <= rightCol;
                newYPosBlack <= row3;  
                commandBlack <= 4'b0010;     
                
                newXPosStrA <= rightCol;
                newYPosStrA <= row1;
                commandStrA <= 4'b0010;
                
                newXPosSolB <= rightCol;
                newYPosSolB <= row5;
                commandSolB <= 4'b0010;        
                
                newXPosSolA <= leftCol;
                newYPosSolA <= row2;
                commandSolA <= 4'b0010;
                
                newXPosStrB <= leftCol;
                newYPosStrB <= row4;
                commandStrB <= 4'b0010;
            end

        endcase
    
    end
    
//    if (btnR && !usedShot) begin
//        newMoveRightWhite <= 1;
//        newMoveUpWhite <= 0;
//        newXSpeedWhite <= 1;
//        newYSpeedWhite <= 0;
//        commandWhite <= 4'b0011; 
    
//    end
    

end
    
        
endmodule
