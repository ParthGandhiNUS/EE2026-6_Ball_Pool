`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.04.2024 13:57:46
// Design Name: 
// Module Name: gameLogic
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


module gameLogic(

    input anClk,
    input clk,
    input [4:0] allScore, 
    input BWColliding,
    input SolAWColliding,
    input SolBWColliding,
    input StrAWColliding,
    input StrBWColliding,
    input isWhiteBallMoving,
    input isBlackBallMoving,
    input isStrAMoving,
    input isStrBMoving,
    input isSolAMoving,
    input isSolBMoving,
    input whiteBallPotted,
    input reset,
    output [6:0] seg,
    output dp,
    output [3:0] an,
    output reg calculationDone = 0

    );
    //in order: [5] == white [4] == black [3] == StrA [2] == StrB [1] == SolA [0] == SolB

    //gamestatus 0 running, 1 Stripes won, 2 Solids won
    reg currentIsSolids = 0;
    reg currentIsStripes = 0;
    reg instantLose = 0;
    reg stripesWin = 0;
    reg solidsWin = 0;
    reg [4:0] prevScore = 0;
    wire isAnyBallMoving;
    
    wire [6:0] printr;
    wire [6:0] printE;
    wire [6:0] printd;
    wire [6:0] printb;
    wire [6:0] printL;
    wire [6:0] printu;
    wire [6:0] printP;
    wire [6:0] printc;
    assign printr = 7'b0101111;
    assign printE = 7'b0000110;
    assign printd = 7'b0100001;
    assign printL = 7'b1000111;
    assign printb = 7'b0000011;
    assign printu = 7'b1100011;
    assign printP = 7'b0001100;
    assign printc = 7'b0100111;
    
    assign dp = 1;
    //assign led = allScore;
    assign isAnyBallMoving = (isWhiteBallMoving || isBlackBallMoving || isStrAMoving || isStrBMoving || isSolAMoving || isSolBMoving);

    always @ (posedge anClk)
        begin
        
            if (reset) begin
                currentIsStripes = 0;
                currentIsSolids = 0;
                prevScore = 0;
                stripesWin = 0;
                solidsWin = 0;
                instantLose = 0;
            
            end

			else if (!isAnyBallMoving && !calculationDone && prevScore == 0 && allScore != 0) begin
				currentIsStripes = ((allScore == 5'b01000 || allScore == 5'b00100 || allScore == 5'b01100)) ? !whiteBallPotted : 0;
				currentIsSolids = ~currentIsStripes;
				//currentIsSolids = ((allScore == 6'b000010) || allScore == 6'b000001 || allScore == 6'b000011) ? 1 : currentIsSolids;
				instantLose = (allScore[4] == 1) ? 1 : 0;
				prevScore = allScore;
			end
			
			else if (!solidsWin && !stripesWin && currentIsStripes && !isAnyBallMoving && !calculationDone && !instantLose) begin
				stripesWin = (allScore[3] && allScore[2] && allScore[4] == 1 && !whiteBallPotted) ? 1 : 0;
				solidsWin = (allScore[4] && !stripesWin) ? 1 : 0;
				currentIsStripes = ((prevScore[2] ^ allScore[2]) || (prevScore[3] ^ allScore[3])) && !whiteBallPotted;
				prevScore = allScore;
				currentIsSolids = ~currentIsStripes;
			end
			
			else if (!solidsWin && !stripesWin && currentIsSolids && !isAnyBallMoving && !calculationDone && !instantLose) begin
				solidsWin = (allScore[1] && allScore[0] && allScore[4] == 1 && !whiteBallPotted) ? 1 : 0;
				stripesWin = (allScore[4] && !solidsWin) ? 1 : 0;
				currentIsSolids = ((prevScore[1] ^ allScore[1]) || (prevScore[0] ^ allScore[0])) && !whiteBallPotted;
				prevScore = allScore;
				currentIsStripes = ~currentIsSolids;
			end
			
			else if (solidsWin || stripesWin) begin
			    currentIsSolids = 0;
			    currentIsStripes = 0;
			
			end
			
			calculationDone <= !isAnyBallMoving;
		end
				
			reg [1:0] anshift = 0;
			
			//solids red stripes blue
			assign seg = (reset || instantLose || (currentIsStripes == currentIsSolids && solidsWin == stripesWin && !whiteBallPotted)) ? 7'b1111111 :
			             (whiteBallPotted && anshift == 3 && solidsWin == stripesWin) ? printP :
						 (whiteBallPotted && anshift == 2 && solidsWin == stripesWin) ? printL :
						 (whiteBallPotted && anshift == 1 && solidsWin == stripesWin) ? printc :
						 (whiteBallPotted && anshift == 0 && solidsWin == stripesWin) ?
						 (currentIsSolids) ? printr : (currentIsStripes) ? printb : printE :
						 ((currentIsSolids || solidsWin) && anshift == 3) ? printr :
						 ((currentIsSolids || solidsWin) && anshift == 2) ? printE :
						 ((currentIsSolids || solidsWin) && anshift == 1) ? printd :
						 ((currentIsSolids || solidsWin) && anshift == 0) ? 7'b1111111 :
						 ((currentIsStripes || stripesWin) && anshift == 3) ? printb :
						 ((currentIsStripes || stripesWin) && anshift == 2 ) ? printL :
						 ((currentIsStripes || stripesWin) && anshift == 1) ? printu :
						 ((currentIsStripes || stripesWin) && anshift == 0) ? printE :
						  7'b1111111;
						 
			assign an[3] = anshift != 3;
			assign an[2] = anshift != 2;
			assign an[1] = anshift != 1;
			assign an[0] = anshift != 0;
						
			reg [8:0] slowAn = 0;
		always @ (posedge anClk)
			begin
				slowAn <= slowAn + 1;
				
				if (!(stripesWin || solidsWin)) begin				
					anshift <= anshift - 1;
				end
				
				else begin
					anshift <= (slowAn == 0) ? anshift - 1 : anshift;
				end
				
			end
				
   endmodule