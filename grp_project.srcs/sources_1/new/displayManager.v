`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.03.2024 20:55:32
// Design Name: 
// Module Name: displayManager
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


module displayManager(
    input clk,
    input [7:0] x_oled, //96
    input [6:0] y_oled, //64
    output reg [15:0] pixel_data = 0,
    
    input [7:0] xPosWhite,
    input [6:0] yPosWhite,
    
    input [7:0] xPosBlack,
    input [6:0] yPosBlack,  
    
    input [7:0] xPosSolA,
    input [6:0] yPosSolA,
    
    input [7:0] xPosSolB,
    input [6:0] yPosSolB ,   
    
    input [7:0] xPosStrA,
    input [6:0] yPosStrA,
    
    input [7:0] xPosStrB,
    input [6:0] yPosStrB,
    input [6:0] inputx0, [6:0] inputx1, [6:0] inputy0, [6:0] inputy1,
    input mouse_1, start, enable,
    
    // [I CHANGED THIS]
    input [7:0] xSpeed,
    input [7:0] ySpeed
    );
    
    wire clk_1Hz, clk_5Hz, clk_10Hz, clk_1KHz;
    flexible_clock unit1 (.CLOCK(clk), .divider(9_999_999), .SLOW_CLOCK(clk_5Hz));
    flexible_clock unit2 (.CLOCK(clk), .divider(49_999), .SLOW_CLOCK(clk_1KHz));
    flexible_clock unit3 (.CLOCK(clk), .divider(4_999_999), .SLOW_CLOCK(clk_10Hz));
    flexible_clock unit4 (.CLOCK(clk), .divider(49_999_999), .SLOW_CLOCK(clk_1Hz));
    
    wire signed [7:0] x0, x1, y0, y1;
    reg signed [7:0] old_x0,old_x1, old_y0, old_y1;
    wire signed [7:0] x_larger, x_smaller, y_larger, y_smaller;
        
    wire signed [7:0] dx, dy, diff;
    wire signed [7:0] raw_dx, raw_dy;
    wire signed [8:0] two_dx, two_dy; 
    reg signed [8:0] p;
    
    wire is_right, is_down, is_negative_gradient, is_x_longer; 
    reg old_is_x_longer;  
    
    reg [6:0] x_line_array = 0;
    reg [6:0] y_line_array = 0;
    
    assign x0 = (!is_negative_gradient && !is_x_longer) ? x_larger : x_smaller;
    assign x1 = (!is_negative_gradient && !is_x_longer) ? x_smaller : x_larger;
    assign y0 = (!is_negative_gradient && is_x_longer) ? y_larger : y_smaller;
    assign y1 = (!is_negative_gradient && is_x_longer) ? y_smaller : y_larger;
    
    assign x_larger = (inputx1 > inputx0) ? inputx1 : inputx0;
    assign x_smaller = (inputx1 > inputx0) ? inputx0 : inputx1;
    assign y_larger = (inputy1 > inputy0) ? inputy1 : inputy0;
    assign y_smaller = (inputy1 > inputy0) ? inputy0 : inputy1; 
    
    assign dx = x_larger - x_smaller;
    assign dy = y_larger - y_smaller;
    assign diff = dy - dx;
    assign is_x_longer = (diff < 0) ? 1 : 0;
    
    assign raw_dx = {1'b0, inputx1} - {1'b0, inputx0};
    assign raw_dy = {1'b0, inputy1} - {1'b0, inputy0};
    assign is_negative_gradient = (raw_dx[7] == raw_dy[7]) ? 1 : 0;
    
    assign two_dx = dx << 1;
    assign two_dy = dy << 1;
    
    reg is_start = 0;
    reg is_done = 0;
    reg is_reset = 0;
    reg is_cleaning = 0;
    
    reg [6:0] y_if_x_is [95:0];
    reg [6:0] x_if_y_is [63:0];
    reg [6:0] new_y_if_x_is [95:0];
    reg [6:0] new_x_if_y_is [63:0];
    reg [6:0] x = 0;
    reg [6:0] y = 0;
    
    wire [15:0] line_colour = 16'b11011_111000_11101;
    wire [15:0] background_colour = 16'b00000_001111_00000;
    wire [15:0] cursor_colour, ball_colour;
    
    localparam white = 16'b11111_111111_11111;
    localparam green = 16'b00000_111111_00000;
    localparam lightGreen = 16'b00000_011000_00000;
    localparam black = 16'b0;
    localparam sol = 16'b11111_000000_00000;
    localparam str = 16'b00000_000000_11111;
    localparam brownBorder = 16'b01001_001000_00000;
    localparam tableColor = 16'b00010_010110_01000;
    
    // [I CHANGED THIS]
    localparam backgroundColor = 16'b00000_000111_00011;
    localparam edgeColor = 16'b11011_111000_11101; // edgeColor same as line_colour
    
    // get average power distance
    wire [9:0] power_distance_calc;
    wire [7:0] power_distance;
    wire [7:0] inv_xSpeed; 
    wire [7:0] inv_ySpeed;
    assign inv_xSpeed = 8'b1111_1111 - xSpeed;
    assign inv_ySpeed = 8'b1111_1111 - ySpeed; 
    assign power_distance_calc = (inv_xSpeed == 0) ? 
                                 (!inv_ySpeed[7]) ? inv_ySpeed << 1 : inv_ySpeed :
                                 (inv_ySpeed == 0) ? 
                                 (!inv_xSpeed[7]) ? inv_xSpeed << 1 : inv_xSpeed :
                                 (inv_xSpeed + inv_ySpeed) >> 1;
    assign power_distance = power_distance_calc[7:0];
    
    // power_modulated
    // value is 0 - 31, power is 0 - 255
    wire [4:0] power_modulated;
    assign power_modulated = power_distance[7:3] << 2; // [I CHANGED THIS]
    
    // Power bar position
    wire [15:0] gold_border;
    wire [15:0] black_border;
    wire [15:0] power_bar_fill_colour;
    wire within_gold_border, within_black_border, within_power_bar;
    
    parameter GOLD = 16'b10110_100101_00000;
    parameter BLACK = 16'b00000_000000_00000;
    parameter RED = 16'b10101_000000_00000; 
    
    assign within_gold_border = ((y_oled == 51 && x_oled >= 2 && x_oled <= 36) ||
                                 (y_oled == 61 && x_oled >= 2 && x_oled <= 36) ||
                                 (x_oled == 2 && y_oled >= 51 && y_oled <= 61) ||
                                 (x_oled == 36 && y_oled >= 51 && y_oled <= 61));
    assign within_black_border = ((y_oled == 52 && x_oled >= 3 && x_oled <= 35) ||
                                 (y_oled == 60 && x_oled >= 3 && x_oled <= 35) ||
                                 (x_oled == 3 && y_oled >= 52 && y_oled <= 60) ||
                                 (x_oled == 35 && y_oled >= 52 && y_oled <= 60));
    assign within_power_bar = ((x_oled >= 4 && x_oled <= 4 + power_modulated) &&
                               (y_oled >= 53 && y_oled <= 59));
    assign gold_border = within_gold_border ? GOLD : 0;
    assign black_border = within_black_border ? BLACK : 0;
    assign power_bar_fill_colour = within_power_bar ? RED : 0;
    
    
    always @ (posedge clk) begin
    
        if (old_is_x_longer == 0) begin
            if (y_oled == 0 && x_oled == x_if_y_is[0]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 1 && x_oled == x_if_y_is[1]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 2 && x_oled == x_if_y_is[2]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 3 && x_oled == x_if_y_is[3]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 4 && x_oled == x_if_y_is[4]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 5 && x_oled == x_if_y_is[5]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 6 && x_oled == x_if_y_is[6]) begin
                pixel_data <= line_colour;            
            end else if (y_oled == 7 && x_oled == x_if_y_is[7]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 8 && x_oled == x_if_y_is[8]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 9 && x_oled == x_if_y_is[9]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 10 && x_oled == x_if_y_is[10]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 11 && x_oled == x_if_y_is[11]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 12 && x_oled == x_if_y_is[12]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 13 && x_oled == x_if_y_is[13]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 14 && x_oled == x_if_y_is[14]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 15 && x_oled == x_if_y_is[15]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 16 && x_oled == x_if_y_is[16]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 17 && x_oled == x_if_y_is[17]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 18 && x_oled == x_if_y_is[18]) begin
                pixel_data <= line_colour;            
            end else if (y_oled == 19 && x_oled == x_if_y_is[19]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 20 && x_oled == x_if_y_is[20]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 21 && x_oled == x_if_y_is[21]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 22 && x_oled == x_if_y_is[22]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 23 && x_oled == x_if_y_is[23]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 24 && x_oled == x_if_y_is[24]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 25 && x_oled == x_if_y_is[25]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 26 && x_oled == x_if_y_is[26]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 27 && x_oled == x_if_y_is[27]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 28 && x_oled == x_if_y_is[28]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 29 && x_oled == x_if_y_is[29]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 30 && x_oled == x_if_y_is[30]) begin
                pixel_data <= line_colour;            
            end else if (y_oled == 31 && x_oled == x_if_y_is[31]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 32 && x_oled == x_if_y_is[32]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 33 && x_oled == x_if_y_is[33]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 34 && x_oled == x_if_y_is[34]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 35 && x_oled == x_if_y_is[35]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 36 && x_oled == x_if_y_is[36]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 37 && x_oled == x_if_y_is[37]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 38 && x_oled == x_if_y_is[38]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 39 && x_oled == x_if_y_is[39]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 40 && x_oled == x_if_y_is[40]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 41 && x_oled == x_if_y_is[41]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 42 && x_oled == x_if_y_is[42]) begin
                pixel_data <= line_colour;            
            end else if (y_oled == 43 && x_oled == x_if_y_is[43]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 44 && x_oled == x_if_y_is[44]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 45 && x_oled == x_if_y_is[45]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 46 && x_oled == x_if_y_is[46]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 47 && x_oled == x_if_y_is[47]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 48 && x_oled == x_if_y_is[48]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 49 && x_oled == x_if_y_is[49]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 50 && x_oled == x_if_y_is[50]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 51 && x_oled == x_if_y_is[51]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 52 && x_oled == x_if_y_is[52]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 53 && x_oled == x_if_y_is[53]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 54 && x_oled == x_if_y_is[54]) begin
                pixel_data <= line_colour;            
            end else if (y_oled == 55 && x_oled == x_if_y_is[55]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 56 && x_oled == x_if_y_is[56]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 57 && x_oled == x_if_y_is[57]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 58 && x_oled == x_if_y_is[58]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 59 && x_oled == x_if_y_is[59]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 60 && x_oled == x_if_y_is[60]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 61 && x_oled == x_if_y_is[61]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 62 && x_oled == x_if_y_is[62]) begin
                pixel_data <= line_colour;
            end else if (y_oled == 63 && x_oled == x_if_y_is[63]) begin
                pixel_data <= line_colour;
            end else begin
                pixel_data <= (x_oled == inputx1 && y_oled == inputy1) ? white :
                                 (x_oled >= xPosWhite - 1 && x_oled <= xPosWhite + 1 && y_oled >= yPosWhite - 1 && y_oled <= yPosWhite + 1) ? white :
                                 (x_oled >= xPosBlack - 1 && x_oled <= xPosBlack + 1 && y_oled >= yPosBlack - 1 && y_oled <= yPosBlack + 1) ? black :
                                 (x_oled >= xPosSolA - 1 && x_oled <= xPosSolA + 1 && y_oled >= yPosSolA - 1 && y_oled <= yPosSolA + 1) ? sol :
                                 (x_oled >= xPosSolB - 1 && x_oled <= xPosSolB + 1 && y_oled >= yPosSolB - 1 && y_oled <= yPosSolB + 1) ? sol :                     
                                 (x_oled >= xPosStrA - 1 && x_oled <= xPosStrA + 1 && y_oled >= yPosStrA - 1 && y_oled <= yPosStrA + 1) ? str :
                                 (x_oled >= xPosStrB - 1 && x_oled <= xPosStrB + 1 && y_oled >= yPosStrB - 1 && y_oled <= yPosStrB + 1) ? str :
                                 //((x == 10 || x == 90) && (y >= 10 && y <= 50)) ? green : 
                                 //((y == 10 || y == 50) && (x >= 10 && x <= 90)) ? green : lightGreen;
                                 ((x_oled == 2 || x_oled == 3 || x_oled == 89 || x_oled == 90) && (y_oled >= 2 && y_oled <=50)) ? brownBorder :
                                 ((y_oled == 2 || y_oled == 3 || y_oled == 49 || y_oled == 50) && (x_oled >= 2 && x_oled <= 90)) ? brownBorder :
                                 //((x == 6 || x == 5 || x == 4 || x == 86|| x == 87 || x == 88) && (y >= 10 && y <=42)) ? green :
                                 //((y == 6|| y ==5||y ==4||y ==46||y ==47||y ==48) && ((x >= 10 && x <=42) || (x >= 49 && x <=82))) ? green :
                                 ((x_oled >= 4 && x_oled <= 9) && ((y_oled >= 4 && y_oled <= 9 )||(y_oled >= 43 && y_oled <= 48))) ? white : 
                                 ((x_oled >= 43 && x_oled <= 48) && ((y_oled >= 4 && y_oled <= 9 )||(y_oled >= 43 && y_oled <= 48))) ? white :
                                 ((x_oled >= 83 && x_oled <= 88) && ((y_oled >= 4 && y_oled <= 9 )||(y_oled >= 43 && y_oled <= 48))) ?  white : 
                                 ((x_oled >= 3 && x_oled <= 89) && (y_oled >= 3 && y_oled <= 49))? tableColor: 
                                 ((x_oled == 0 || x_oled == 95) || (y_oled == 0 || y_oled == 63))? edgeColor : backgroundColor;
            end 
        end else if (old_is_x_longer == 1) begin
            // Draw a power bar
            if (within_gold_border) pixel_data <= gold_border;
            if (within_black_border) pixel_data <= black_border;
            if (within_power_bar) pixel_data <= power_bar_fill_colour;
            
            if (x_oled == 0 && y_oled == y_if_x_is[0]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 1 && y_oled == y_if_x_is[1]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 2 && y_oled == y_if_x_is[2]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 3 && y_oled == y_if_x_is[3]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 4 && y_oled == y_if_x_is[4]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 5 && y_oled == y_if_x_is[5]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 6 && y_oled == y_if_x_is[6]) begin
                pixel_data <= line_colour;            
            end else if (x_oled == 7 && y_oled == y_if_x_is[7]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 8 && y_oled == y_if_x_is[8]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 9 && y_oled == y_if_x_is[9]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 10 && y_oled == y_if_x_is[10]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 11 && y_oled == y_if_x_is[11]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 12 && y_oled == y_if_x_is[12]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 13 && y_oled == y_if_x_is[13]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 14 && y_oled == y_if_x_is[14]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 15 && y_oled == y_if_x_is[15]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 16 && y_oled == y_if_x_is[16]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 17 && y_oled == y_if_x_is[17]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 18 && y_oled == y_if_x_is[18]) begin
                pixel_data <= line_colour;            
            end else if (x_oled == 19 && y_oled == y_if_x_is[19]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 20 && y_oled == y_if_x_is[20]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 21 && y_oled == y_if_x_is[21]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 22 && y_oled == y_if_x_is[22]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 23 && y_oled == y_if_x_is[23]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 24 && y_oled == y_if_x_is[24]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 25 && y_oled == y_if_x_is[25]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 26 && y_oled == y_if_x_is[26]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 27 && y_oled == y_if_x_is[27]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 28 && y_oled == y_if_x_is[28]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 29 && y_oled == y_if_x_is[29]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 30 && y_oled == y_if_x_is[30]) begin
                pixel_data <= line_colour;            
            end else if (x_oled == 31 && y_oled == y_if_x_is[31]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 32 && y_oled == y_if_x_is[32]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 33 && y_oled == y_if_x_is[33]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 34 && y_oled == y_if_x_is[34]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 35 && y_oled == y_if_x_is[35]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 36 && y_oled == y_if_x_is[36]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 37 && y_oled == y_if_x_is[37]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 38 && y_oled == y_if_x_is[38]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 39 && y_oled == y_if_x_is[39]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 40 && y_oled == y_if_x_is[40]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 41 && y_oled == y_if_x_is[41]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 42 && y_oled == y_if_x_is[42]) begin
                pixel_data <= line_colour;            
            end else if (x_oled == 43 && y_oled == y_if_x_is[43]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 44 && y_oled == y_if_x_is[44]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 45 && y_oled == y_if_x_is[45]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 46 && y_oled == y_if_x_is[46]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 47 && y_oled == y_if_x_is[47]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 48 && y_oled == y_if_x_is[48]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 49 && y_oled == y_if_x_is[49]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 50 && y_oled == y_if_x_is[50]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 51 && y_oled == y_if_x_is[51]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 52 && y_oled == y_if_x_is[52]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 53 && y_oled == y_if_x_is[53]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 54 && y_oled == y_if_x_is[54]) begin
                pixel_data <= line_colour;            
            end else if (x_oled == 55 && y_oled == y_if_x_is[55]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 56 && y_oled == y_if_x_is[56]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 57 && y_oled == y_if_x_is[57]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 58 && y_oled == y_if_x_is[58]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 59 && y_oled == y_if_x_is[59]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 60 && y_oled == y_if_x_is[60]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 61 && y_oled == y_if_x_is[61]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 62 && y_oled == y_if_x_is[62]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 63 && y_oled == y_if_x_is[63]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 64 && y_oled == y_if_x_is[64]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 65 && y_oled == y_if_x_is[65]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 66 && y_oled == y_if_x_is[66]) begin
                pixel_data <= line_colour;            
            end else if (x_oled == 67 && y_oled == y_if_x_is[67]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 68 && y_oled == y_if_x_is[68]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 69 && y_oled == y_if_x_is[69]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 70 && y_oled == y_if_x_is[70]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 71 && y_oled == y_if_x_is[71]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 72 && y_oled == y_if_x_is[72]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 73 && y_oled == y_if_x_is[73]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 74 && y_oled == y_if_x_is[74]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 75 && y_oled == y_if_x_is[75]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 76 && y_oled == y_if_x_is[76]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 77 && y_oled == y_if_x_is[77]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 78 && y_oled == y_if_x_is[78]) begin
                pixel_data <= line_colour;            
            end else if (x_oled == 79 && y_oled == y_if_x_is[79]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 80 && y_oled == y_if_x_is[80]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 81 && y_oled == y_if_x_is[81]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 82 && y_oled == y_if_x_is[82]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 83 && y_oled == y_if_x_is[83]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 84 && y_oled == y_if_x_is[84]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 85 && y_oled == y_if_x_is[85]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 86 && y_oled == y_if_x_is[86]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 87 && y_oled == y_if_x_is[87]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 88 && y_oled == y_if_x_is[88]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 89 && y_oled == y_if_x_is[89]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 90 && y_oled == y_if_x_is[90]) begin
                pixel_data <= line_colour;            
            end else if (x_oled == 91 && y_oled == y_if_x_is[91]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 92 && y_oled == y_if_x_is[92]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 93 && y_oled == y_if_x_is[93]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 94 && y_oled == y_if_x_is[94]) begin
                pixel_data <= line_colour;
            end else if (x_oled == 95 && y_oled == y_if_x_is[95]) begin
                pixel_data <= line_colour;
            end else begin
                pixel_data <= (x_oled == inputx1 && y_oled == inputy1) ? white :
                                 (x_oled >= xPosWhite - 1 && x_oled <= xPosWhite + 1 && y_oled >= yPosWhite - 1 && y_oled <= yPosWhite + 1) ? white :
                                 (x_oled >= xPosBlack - 1 && x_oled <= xPosBlack + 1 && y_oled >= yPosBlack - 1 && y_oled <= yPosBlack + 1) ? black :
                                 (x_oled >= xPosSolA - 1 && x_oled <= xPosSolA + 1 && y_oled >= yPosSolA - 1 && y_oled <= yPosSolA + 1) ? sol :
                                 (x_oled >= xPosSolB - 1 && x_oled <= xPosSolB + 1 && y_oled >= yPosSolB - 1 && y_oled <= yPosSolB + 1) ? sol :                     
                                 (x_oled >= xPosStrA - 1 && x_oled <= xPosStrA + 1 && y_oled >= yPosStrA - 1 && y_oled <= yPosStrA + 1) ? str :
                                 (x_oled >= xPosStrB - 1 && x_oled <= xPosStrB + 1 && y_oled >= yPosStrB - 1 && y_oled <= yPosStrB + 1) ? str :
                                 //((x == 10 || x == 90) && (y >= 10 && y <= 50)) ? green : 
                                 //((y == 10 || y == 50) && (x >= 10 && x <= 90)) ? green : lightGreen;
                                 ((x_oled == 2 || x_oled == 3 || x_oled == 89 || x_oled == 90) && (y_oled >= 2 && y_oled <=50)) ? brownBorder :
                                 ((y_oled == 2 || y_oled == 3 || y_oled == 49 || y_oled == 50) && (x_oled >= 2 && x_oled <= 90)) ? brownBorder :
                                 //((x == 6 || x == 5 || x == 4 || x == 86|| x == 87 || x == 88) && (y >= 10 && y <=42)) ? green :
                                 //((y == 6|| y ==5||y ==4||y ==46||y ==47||y ==48) && ((x >= 10 && x <=42) || (x >= 49 && x <=82))) ? green :
                                 ((x_oled >= 4 && x_oled <= 9) && ((y_oled >= 4 && y_oled <= 9 )||(y_oled >= 43 && y_oled <= 48))) ? white : 
                                 ((x_oled >= 43 && x_oled <= 48) && ((y_oled >= 4 && y_oled <= 9 )||(y_oled >= 43 && y_oled <= 48))) ? white :
                                 ((x_oled >= 83 && x_oled <= 88) && ((y_oled >= 4 && y_oled <= 9 )||(y_oled >= 43 && y_oled <= 48))) ?  white : 
                                 ((x_oled >= 3 && x_oled <= 89) && (y_oled >= 3 && y_oled <= 49))? tableColor: 
                                 ((x_oled == 0 || x_oled == 95) || (y_oled == 0 || y_oled == 63))? edgeColor : backgroundColor;
            end
        end         
        //can maybe do overriding statements if it gets too complicated.
        // Draw a power bar
        if (within_gold_border) pixel_data <= gold_border;
        if (within_black_border) pixel_data <= black_border;
        if (within_power_bar) pixel_data <= power_bar_fill_colour;

    end
    
    
    always @(posedge clk) begin
            if (start == 1) begin
                is_reset = 1;
                is_done = 0;
                old_is_x_longer = is_x_longer;
            end 
            
            if (is_done == 1) begin
                is_start = 0;
            end
            
            if (is_start == 0) begin
                if (is_x_longer == 1) begin
                    p <= two_dx - dy;
                end else begin
                    p <= two_dy - dx;
                end
            end
            
            // Reassigning new line values to old line values
            // NOTE: old line values will be adjusted as the line is being calculated while new line doesn't 
            if (is_reset == 1) begin 
                x_if_y_is[0] = new_x_if_y_is[0];
                x_if_y_is[1] = new_x_if_y_is[1];
                x_if_y_is[2] = new_x_if_y_is[2];
                x_if_y_is[3] = new_x_if_y_is[3];
                x_if_y_is[4] = new_x_if_y_is[4];
                x_if_y_is[5] = new_x_if_y_is[5];
                x_if_y_is[6] = new_x_if_y_is[6];
                x_if_y_is[7] = new_x_if_y_is[7];
                x_if_y_is[8] = new_x_if_y_is[8];
                x_if_y_is[9] = new_x_if_y_is[9];
                x_if_y_is[10] = new_x_if_y_is[10];
                x_if_y_is[11] = new_x_if_y_is[11];
                x_if_y_is[12] = new_x_if_y_is[12];
                x_if_y_is[13] = new_x_if_y_is[13];
                x_if_y_is[14] = new_x_if_y_is[14];
                x_if_y_is[15] = new_x_if_y_is[15];
                x_if_y_is[16] = new_x_if_y_is[16];
                x_if_y_is[17] = new_x_if_y_is[17];
                x_if_y_is[18] = new_x_if_y_is[18];
                x_if_y_is[19] = new_x_if_y_is[19];
                x_if_y_is[20] = new_x_if_y_is[20];
                x_if_y_is[21] = new_x_if_y_is[21];
                x_if_y_is[22] = new_x_if_y_is[22];
                x_if_y_is[23] = new_x_if_y_is[23];
                x_if_y_is[24] = new_x_if_y_is[24];
                x_if_y_is[25] = new_x_if_y_is[25];
                x_if_y_is[26] = new_x_if_y_is[26];
                x_if_y_is[27] = new_x_if_y_is[27];
                x_if_y_is[28] = new_x_if_y_is[28];
                x_if_y_is[29] = new_x_if_y_is[29];
                x_if_y_is[30] = new_x_if_y_is[30];
                x_if_y_is[31] = new_x_if_y_is[31];
                x_if_y_is[32] = new_x_if_y_is[32];
                x_if_y_is[33] = new_x_if_y_is[33];
                x_if_y_is[34] = new_x_if_y_is[34];
                x_if_y_is[35] = new_x_if_y_is[35];
                x_if_y_is[36] = new_x_if_y_is[36];
                x_if_y_is[37] = new_x_if_y_is[37];
                x_if_y_is[38] = new_x_if_y_is[38];
                x_if_y_is[39] = new_x_if_y_is[39];
                x_if_y_is[40] = new_x_if_y_is[40];
                x_if_y_is[41] = new_x_if_y_is[41];
                x_if_y_is[42] = new_x_if_y_is[42];
                x_if_y_is[43] = new_x_if_y_is[43];
                x_if_y_is[44] = new_x_if_y_is[44];
                x_if_y_is[45] = new_x_if_y_is[45];
                x_if_y_is[46] = new_x_if_y_is[46];
                x_if_y_is[47] = new_x_if_y_is[47];
                x_if_y_is[48] = new_x_if_y_is[48];
                x_if_y_is[49] = new_x_if_y_is[49];
                x_if_y_is[50] = new_x_if_y_is[50];
                x_if_y_is[51] = new_x_if_y_is[51];
                x_if_y_is[52] = new_x_if_y_is[52];
                x_if_y_is[53] = new_x_if_y_is[53];
                x_if_y_is[54] = new_x_if_y_is[54];
                x_if_y_is[55] = new_x_if_y_is[55];
                x_if_y_is[56] = new_x_if_y_is[56];
                x_if_y_is[57] = new_x_if_y_is[57];
                x_if_y_is[58] = new_x_if_y_is[58];
                x_if_y_is[59] = new_x_if_y_is[59];
                x_if_y_is[60] = new_x_if_y_is[60];
                x_if_y_is[61] = new_x_if_y_is[61];
                x_if_y_is[62] = new_x_if_y_is[62];
                x_if_y_is[63] = new_x_if_y_is[63];
            
                y_if_x_is[0] = new_y_if_x_is[0];
                y_if_x_is[1] = new_y_if_x_is[1];
                y_if_x_is[2] = new_y_if_x_is[2];
                y_if_x_is[3] = new_y_if_x_is[3];
                y_if_x_is[4] = new_y_if_x_is[4];
                y_if_x_is[5] = new_y_if_x_is[5];
                y_if_x_is[6] = new_y_if_x_is[6];
                y_if_x_is[7] = new_y_if_x_is[7];
                y_if_x_is[8] = new_y_if_x_is[8];
                y_if_x_is[9] = new_y_if_x_is[9];
                y_if_x_is[10] = new_y_if_x_is[10];
                y_if_x_is[11] = new_y_if_x_is[11];
                y_if_x_is[12] = new_y_if_x_is[12];
                y_if_x_is[13] = new_y_if_x_is[13];
                y_if_x_is[14] = new_y_if_x_is[14];
                y_if_x_is[15] = new_y_if_x_is[15];
                y_if_x_is[16] = new_y_if_x_is[16];
                y_if_x_is[17] = new_y_if_x_is[17];
                y_if_x_is[18] = new_y_if_x_is[18];
                y_if_x_is[19] = new_y_if_x_is[19];
                y_if_x_is[20] = new_y_if_x_is[20];
                y_if_x_is[21] = new_y_if_x_is[21];
                y_if_x_is[22] = new_y_if_x_is[22];
                y_if_x_is[23] = new_y_if_x_is[23];
                y_if_x_is[24] = new_y_if_x_is[24];
                y_if_x_is[25] = new_y_if_x_is[25];
                y_if_x_is[26] = new_y_if_x_is[26];
                y_if_x_is[27] = new_y_if_x_is[27];
                y_if_x_is[28] = new_y_if_x_is[28];
                y_if_x_is[29] = new_y_if_x_is[29];
                y_if_x_is[30] = new_y_if_x_is[30];
                y_if_x_is[31] = new_y_if_x_is[31];
                y_if_x_is[32] = new_y_if_x_is[32];
                y_if_x_is[33] = new_y_if_x_is[33];
                y_if_x_is[34] = new_y_if_x_is[34];
                y_if_x_is[35] = new_y_if_x_is[35];
                y_if_x_is[36] = new_y_if_x_is[36];
                y_if_x_is[37] = new_y_if_x_is[37];
                y_if_x_is[38] = new_y_if_x_is[38];
                y_if_x_is[39] = new_y_if_x_is[39];
                y_if_x_is[40] = new_y_if_x_is[40];
                y_if_x_is[41] = new_y_if_x_is[41];
                y_if_x_is[42] = new_y_if_x_is[42];
                y_if_x_is[43] = new_y_if_x_is[43];
                y_if_x_is[44] = new_y_if_x_is[44];
                y_if_x_is[45] = new_y_if_x_is[45];
                y_if_x_is[46] = new_y_if_x_is[46];
                y_if_x_is[47] = new_y_if_x_is[47];
                y_if_x_is[48] = new_y_if_x_is[48];
                y_if_x_is[49] = new_y_if_x_is[49];
                y_if_x_is[50] = new_y_if_x_is[50];
                y_if_x_is[51] = new_y_if_x_is[51];
                y_if_x_is[52] = new_y_if_x_is[52];
                y_if_x_is[53] = new_y_if_x_is[53];
                y_if_x_is[54] = new_y_if_x_is[54];
                y_if_x_is[55] = new_y_if_x_is[55];
                y_if_x_is[56] = new_y_if_x_is[56];
                y_if_x_is[57] = new_y_if_x_is[57];
                y_if_x_is[58] = new_y_if_x_is[58];
                y_if_x_is[59] = new_y_if_x_is[59];
                y_if_x_is[60] = new_y_if_x_is[60];
                y_if_x_is[61] = new_y_if_x_is[61];
                y_if_x_is[62] = new_y_if_x_is[62];
                y_if_x_is[63] = new_y_if_x_is[63];
                y_if_x_is[64] = new_y_if_x_is[64];
                y_if_x_is[65] = new_y_if_x_is[65];
                y_if_x_is[66] = new_y_if_x_is[66];
                y_if_x_is[67] = new_y_if_x_is[67];
                y_if_x_is[68] = new_y_if_x_is[68];
                y_if_x_is[69] = new_y_if_x_is[69];
                y_if_x_is[70] = new_y_if_x_is[70];
                y_if_x_is[71] = new_y_if_x_is[71];
                y_if_x_is[72] = new_y_if_x_is[72];
                y_if_x_is[73] = new_y_if_x_is[73];
                y_if_x_is[74] = new_y_if_x_is[74];
                y_if_x_is[75] = new_y_if_x_is[75];
                y_if_x_is[76] = new_y_if_x_is[76];
                y_if_x_is[77] = new_y_if_x_is[77];
                y_if_x_is[78] = new_y_if_x_is[78];
                y_if_x_is[79] = new_y_if_x_is[79];
                y_if_x_is[80] = new_y_if_x_is[80];
                y_if_x_is[81] = new_y_if_x_is[81];
                y_if_x_is[82] = new_y_if_x_is[82];
                y_if_x_is[83] = new_y_if_x_is[83];
                y_if_x_is[84] = new_y_if_x_is[84];
                y_if_x_is[85] = new_y_if_x_is[85];
                y_if_x_is[86] = new_y_if_x_is[86];
                y_if_x_is[87] = new_y_if_x_is[87];
                y_if_x_is[88] = new_y_if_x_is[88];
                y_if_x_is[89] = new_y_if_x_is[89];
                y_if_x_is[90] = new_y_if_x_is[90];
                y_if_x_is[91] = new_y_if_x_is[91];
                y_if_x_is[92] = new_y_if_x_is[92];
                y_if_x_is[93] = new_y_if_x_is[93];
                
                is_reset = 0;
                is_cleaning = 1;
            end 
            
            // Reset value to 0 if it is not part of new line
            if (is_cleaning == 1) begin
                if (old_is_x_longer == 0) begin
                    // line is at left side
                    // remove values outside y_range
                    x_if_y_is[0] = (0 < old_y0 || 0 > old_y1) ? 0 : x_if_y_is[0];
                    x_if_y_is[1] = (1 < old_y0 || 1 > old_y1) ? 0 : x_if_y_is[1];
                    x_if_y_is[2] = (2 < old_y0 || 2 > old_y1) ? 0 : x_if_y_is[2];
                    x_if_y_is[3] = (3 < old_y0 || 3 > old_y1) ? 0 : x_if_y_is[3];
                    x_if_y_is[4] = (4 < old_y0 || 4 > old_y1) ? 0 : x_if_y_is[4];
                    x_if_y_is[5] = (5 < old_y0 || 5 > old_y1) ? 0 : x_if_y_is[5];
                    x_if_y_is[6] = (6 < old_y0 || 6 > old_y1) ? 0 : x_if_y_is[6];
                    x_if_y_is[7] = (7 < old_y0 || 7 > old_y1) ? 0 : x_if_y_is[7];
                    x_if_y_is[8] = (8 < old_y0 || 8 > old_y1) ? 0 : x_if_y_is[8];
                    x_if_y_is[9] = (9 < old_y0 || 9 > old_y1) ? 0 : x_if_y_is[9];
                    x_if_y_is[10] = (10 < old_y0 || 10 > old_y1) ? 0 : x_if_y_is[10];
                    x_if_y_is[11] = (11 < old_y0 || 11 > old_y1) ? 0 : x_if_y_is[11];
                    x_if_y_is[12] = (12 < old_y0 || 12 > old_y1) ? 0 : x_if_y_is[12];
                    x_if_y_is[13] = (13 < old_y0 || 13 > old_y1) ? 0 : x_if_y_is[13];
                    x_if_y_is[14] = (14 < old_y0 || 14 > old_y1) ? 0 : x_if_y_is[14];
                    x_if_y_is[15] = (15 < old_y0 || 15 > old_y1) ? 0 : x_if_y_is[15];
                    x_if_y_is[16] = (16 < old_y0 || 16 > old_y1) ? 0 : x_if_y_is[16];
                    x_if_y_is[17] = (17 < old_y0 || 17 > old_y1) ? 0 : x_if_y_is[17];
                    x_if_y_is[18] = (18 < old_y0 || 18 > old_y1) ? 0 : x_if_y_is[18];
                    x_if_y_is[19] = (19 < old_y0 || 19 > old_y1) ? 0 : x_if_y_is[19];
                    x_if_y_is[20] = (20 < old_y0 || 20 > old_y1) ? 0 : x_if_y_is[20];
                    x_if_y_is[21] = (21 < old_y0 || 21 > old_y1) ? 0 : x_if_y_is[21];
                    x_if_y_is[22] = (22 < old_y0 || 22 > old_y1) ? 0 : x_if_y_is[22];
                    x_if_y_is[23] = (23 < old_y0 || 23 > old_y1) ? 0 : x_if_y_is[23];
                    x_if_y_is[24] = (24 < old_y0 || 24 > old_y1) ? 0 : x_if_y_is[24];
                    x_if_y_is[25] = (25 < old_y0 || 25 > old_y1) ? 0 : x_if_y_is[25];
                    x_if_y_is[26] = (26 < old_y0 || 26 > old_y1) ? 0 : x_if_y_is[26];
                    x_if_y_is[27] = (27 < old_y0 || 27 > old_y1) ? 0 : x_if_y_is[27];
                    x_if_y_is[28] = (28 < old_y0 || 28 > old_y1) ? 0 : x_if_y_is[28];
                    x_if_y_is[29] = (29 < old_y0 || 29 > old_y1) ? 0 : x_if_y_is[29];
                    x_if_y_is[30] = (30 < old_y0 || 30 > old_y1) ? 0 : x_if_y_is[30];
                    x_if_y_is[31] = (31 < old_y0 || 31 > old_y1) ? 0 : x_if_y_is[31];
                    x_if_y_is[32] = (32 < old_y0 || 32 > old_y1) ? 0 : x_if_y_is[32];
                    x_if_y_is[33] = (33 < old_y0 || 33 > old_y1) ? 0 : x_if_y_is[33];
                    x_if_y_is[34] = (34 < old_y0 || 34 > old_y1) ? 0 : x_if_y_is[34];
                    x_if_y_is[35] = (35 < old_y0 || 35 > old_y1) ? 0 : x_if_y_is[35];
                    x_if_y_is[36] = (36 < old_y0 || 36 > old_y1) ? 0 : x_if_y_is[36];
                    x_if_y_is[37] = (37 < old_y0 || 37 > old_y1) ? 0 : x_if_y_is[37];
                    x_if_y_is[38] = (38 < old_y0 || 38 > old_y1) ? 0 : x_if_y_is[38];
                    x_if_y_is[39] = (39 < old_y0 || 39 > old_y1) ? 0 : x_if_y_is[39];
                    x_if_y_is[40] = (40 < old_y0 || 40 > old_y1) ? 0 : x_if_y_is[40];
                    x_if_y_is[41] = (41 < old_y0 || 41 > old_y1) ? 0 : x_if_y_is[41];
                    x_if_y_is[42] = (42 < old_y0 || 42 > old_y1) ? 0 : x_if_y_is[42];
                    x_if_y_is[43] = (43 < old_y0 || 43 > old_y1) ? 0 : x_if_y_is[43];
                    x_if_y_is[44] = (44 < old_y0 || 44 > old_y1) ? 0 : x_if_y_is[44];
                    x_if_y_is[45] = (45 < old_y0 || 45 > old_y1) ? 0 : x_if_y_is[45];
                    x_if_y_is[46] = (46 < old_y0 || 46 > old_y1) ? 0 : x_if_y_is[46];
                    x_if_y_is[47] = (47 < old_y0 || 47 > old_y1) ? 0 : x_if_y_is[47];
                    x_if_y_is[48] = (48 < old_y0 || 48 > old_y1) ? 0 : x_if_y_is[48];
                    x_if_y_is[49] = (49 < old_y0 || 49 > old_y1) ? 0 : x_if_y_is[49];
                    x_if_y_is[50] = (50 < old_y0 || 50 > old_y1) ? 0 : x_if_y_is[50];
                    x_if_y_is[51] = (51 < old_y0 || 51 > old_y1) ? 0 : x_if_y_is[51];
                    x_if_y_is[52] = (52 < old_y0 || 52 > old_y1) ? 0 : x_if_y_is[52];
                    x_if_y_is[53] = (53 < old_y0 || 53 > old_y1) ? 0 : x_if_y_is[53];
                    x_if_y_is[54] = (54 < old_y0 || 54 > old_y1) ? 0 : x_if_y_is[54];
                    x_if_y_is[55] = (55 < old_y0 || 55 > old_y1) ? 0 : x_if_y_is[55];
                    x_if_y_is[56] = (56 < old_y0 || 56 > old_y1) ? 0 : x_if_y_is[56];
                    x_if_y_is[57] = (57 < old_y0 || 57 > old_y1) ? 0 : x_if_y_is[57];
                    x_if_y_is[58] = (58 < old_y0 || 58 > old_y1) ? 0 : x_if_y_is[58];
                    x_if_y_is[59] = (59 < old_y0 || 59 > old_y1) ? 0 : x_if_y_is[59];
                    x_if_y_is[60] = (60 < old_y0 || 60 > old_y1) ? 0 : x_if_y_is[60];
                    x_if_y_is[61] = (61 < old_y0 || 61 > old_y1) ? 0 : x_if_y_is[61];
                    x_if_y_is[62] = (62 < old_y0 || 62 > old_y1) ? 0 : x_if_y_is[62];
                    x_if_y_is[63] = (63 < old_y0 || 63 > old_y1) ? 0 : x_if_y_is[63];
                end else begin
                    // line is at top
                    y_if_x_is[0] = (0 < old_x0 || 0 > old_x1) ? 0 : y_if_x_is[0];
                    y_if_x_is[1] = (1 < old_x0 || 1 > old_x1) ? 0 : y_if_x_is[1];
                    y_if_x_is[2] = (2 < old_x0 || 2 > old_x1) ? 0 : y_if_x_is[2];
                    y_if_x_is[3] = (3 < old_x0 || 3 > old_x1) ? 0 : y_if_x_is[3];
                    y_if_x_is[4] = (4 < old_x0 || 4 > old_x1) ? 0 : y_if_x_is[4];
                    y_if_x_is[5] = (5 < old_x0 || 5 > old_x1) ? 0 : y_if_x_is[5];
                    y_if_x_is[6] = (6 < old_x0 || 6 > old_x1) ? 0 : y_if_x_is[6];
                    y_if_x_is[7] = (7 < old_x0 || 7 > old_x1) ? 0 : y_if_x_is[7];
                    y_if_x_is[8] = (8 < old_x0 || 8 > old_x1) ? 0 : y_if_x_is[8];
                    y_if_x_is[9] = (9 < old_x0 || 9 > old_x1) ? 0 : y_if_x_is[9];
                    y_if_x_is[10] = (10 < old_x0 || 10 > old_x1) ? 0 : y_if_x_is[10];
                    y_if_x_is[11] = (11 < old_x0 || 11 > old_x1) ? 0 : y_if_x_is[11];
                    y_if_x_is[12] = (12 < old_x0 || 12 > old_x1) ? 0 : y_if_x_is[12];
                    y_if_x_is[13] = (13 < old_x0 || 13 > old_x1) ? 0 : y_if_x_is[13];
                    y_if_x_is[14] = (14 < old_x0 || 14 > old_x1) ? 0 : y_if_x_is[14];
                    y_if_x_is[15] = (15 < old_x0 || 15 > old_x1) ? 0 : y_if_x_is[15];
                    y_if_x_is[16] = (16 < old_x0 || 16 > old_x1) ? 0 : y_if_x_is[16];
                    y_if_x_is[17] = (17 < old_x0 || 17 > old_x1) ? 0 : y_if_x_is[17];
                    y_if_x_is[18] = (18 < old_x0 || 18 > old_x1) ? 0 : y_if_x_is[18];
                    y_if_x_is[19] = (19 < old_x0 || 19 > old_x1) ? 0 : y_if_x_is[19];
                    y_if_x_is[20] = (20 < old_x0 || 20 > old_x1) ? 0 : y_if_x_is[20];
                    y_if_x_is[21] = (21 < old_x0 || 21 > old_x1) ? 0 : y_if_x_is[21];
                    y_if_x_is[22] = (22 < old_x0 || 22 > old_x1) ? 0 : y_if_x_is[22];
                    y_if_x_is[23] = (23 < old_x0 || 23 > old_x1) ? 0 : y_if_x_is[23];
                    y_if_x_is[24] = (24 < old_x0 || 24 > old_x1) ? 0 : y_if_x_is[24];
                    y_if_x_is[25] = (25 < old_x0 || 25 > old_x1) ? 0 : y_if_x_is[25];
                    y_if_x_is[26] = (26 < old_x0 || 26 > old_x1) ? 0 : y_if_x_is[26];
                    y_if_x_is[27] = (27 < old_x0 || 27 > old_x1) ? 0 : y_if_x_is[27];
                    y_if_x_is[28] = (28 < old_x0 || 28 > old_x1) ? 0 : y_if_x_is[28];
                    y_if_x_is[29] = (29 < old_x0 || 29 > old_x1) ? 0 : y_if_x_is[29];
                    y_if_x_is[30] = (30 < old_x0 || 30 > old_x1) ? 0 : y_if_x_is[30];
                    y_if_x_is[31] = (31 < old_x0 || 31 > old_x1) ? 0 : y_if_x_is[31];
                    y_if_x_is[32] = (32 < old_x0 || 32 > old_x1) ? 0 : y_if_x_is[32];
                    y_if_x_is[33] = (33 < old_x0 || 33 > old_x1) ? 0 : y_if_x_is[33];
                    y_if_x_is[34] = (34 < old_x0 || 34 > old_x1) ? 0 : y_if_x_is[34];
                    y_if_x_is[35] = (35 < old_x0 || 35 > old_x1) ? 0 : y_if_x_is[35];
                    y_if_x_is[36] = (36 < old_x0 || 36 > old_x1) ? 0 : y_if_x_is[36];
                    y_if_x_is[37] = (37 < old_x0 || 37 > old_x1) ? 0 : y_if_x_is[37];
                    y_if_x_is[38] = (38 < old_x0 || 38 > old_x1) ? 0 : y_if_x_is[38];
                    y_if_x_is[39] = (39 < old_x0 || 39 > old_x1) ? 0 : y_if_x_is[39];
                    y_if_x_is[40] = (40 < old_x0 || 40 > old_x1) ? 0 : y_if_x_is[40];
                    y_if_x_is[41] = (41 < old_x0 || 41 > old_x1) ? 0 : y_if_x_is[41];
                    y_if_x_is[42] = (42 < old_x0 || 42 > old_x1) ? 0 : y_if_x_is[42];
                    y_if_x_is[43] = (43 < old_x0 || 43 > old_x1) ? 0 : y_if_x_is[43];
                    y_if_x_is[44] = (44 < old_x0 || 44 > old_x1) ? 0 : y_if_x_is[44];
                    y_if_x_is[45] = (45 < old_x0 || 45 > old_x1) ? 0 : y_if_x_is[45];
                    y_if_x_is[46] = (46 < old_x0 || 46 > old_x1) ? 0 : y_if_x_is[46];
                    y_if_x_is[47] = (47 < old_x0 || 47 > old_x1) ? 0 : y_if_x_is[47];
                    y_if_x_is[48] = (48 < old_x0 || 48 > old_x1) ? 0 : y_if_x_is[48];
                    y_if_x_is[49] = (49 < old_x0 || 49 > old_x1) ? 0 : y_if_x_is[49];
                    y_if_x_is[50] = (50 < old_x0 || 50 > old_x1) ? 0 : y_if_x_is[50];
                    y_if_x_is[51] = (51 < old_x0 || 51 > old_x1) ? 0 : y_if_x_is[51];
                    y_if_x_is[52] = (52 < old_x0 || 52 > old_x1) ? 0 : y_if_x_is[52];
                    y_if_x_is[53] = (53 < old_x0 || 53 > old_x1) ? 0 : y_if_x_is[53];
                    y_if_x_is[54] = (54 < old_x0 || 54 > old_x1) ? 0 : y_if_x_is[54];
                    y_if_x_is[55] = (55 < old_x0 || 55 > old_x1) ? 0 : y_if_x_is[55];
                    y_if_x_is[56] = (56 < old_x0 || 56 > old_x1) ? 0 : y_if_x_is[56];
                    y_if_x_is[57] = (57 < old_x0 || 57 > old_x1) ? 0 : y_if_x_is[57];
                    y_if_x_is[58] = (58 < old_x0 || 58 > old_x1) ? 0 : y_if_x_is[58];
                    y_if_x_is[59] = (59 < old_x0 || 59 > old_x1) ? 0 : y_if_x_is[59];
                    y_if_x_is[60] = (60 < old_x0 || 60 > old_x1) ? 0 : y_if_x_is[60];
                    y_if_x_is[61] = (61 < old_x0 || 61 > old_x1) ? 0 : y_if_x_is[61];
                    y_if_x_is[62] = (62 < old_x0 || 62 > old_x1) ? 0 : y_if_x_is[62];
                    y_if_x_is[63] = (63 < old_x0 || 63 > old_x1) ? 0 : y_if_x_is[63];
                    y_if_x_is[64] = (64 < old_x0 || 64 > old_x1) ? 0 : y_if_x_is[64];
                    y_if_x_is[65] = (65 < old_x0 || 65 > old_x1) ? 0 : y_if_x_is[65];
                    y_if_x_is[66] = (66 < old_x0 || 66 > old_x1) ? 0 : y_if_x_is[66];
                    y_if_x_is[67] = (67 < old_x0 || 67 > old_x1) ? 0 : y_if_x_is[67];
                    y_if_x_is[68] = (68 < old_x0 || 68 > old_x1) ? 0 : y_if_x_is[68];
                    y_if_x_is[69] = (69 < old_x0 || 69 > old_x1) ? 0 : y_if_x_is[69];
                    y_if_x_is[70] = (70 < old_x0 || 70 > old_x1) ? 0 : y_if_x_is[70];
                    y_if_x_is[71] = (71 < old_x0 || 71 > old_x1) ? 0 : y_if_x_is[71];
                    y_if_x_is[72] = (72 < old_x0 || 72 > old_x1) ? 0 : y_if_x_is[72];
                    y_if_x_is[73] = (73 < old_x0 || 73 > old_x1) ? 0 : y_if_x_is[73];
                    y_if_x_is[74] = (74 < old_x0 || 74 > old_x1) ? 0 : y_if_x_is[74];
                    y_if_x_is[75] = (75 < old_x0 || 75 > old_x1) ? 0 : y_if_x_is[75];
                    y_if_x_is[76] = (76 < old_x0 || 76 > old_x1) ? 0 : y_if_x_is[76];
                    y_if_x_is[77] = (77 < old_x0 || 77 > old_x1) ? 0 : y_if_x_is[77];
                    y_if_x_is[78] = (78 < old_x0 || 78 > old_x1) ? 0 : y_if_x_is[78];
                    y_if_x_is[79] = (79 < old_x0 || 79 > old_x1) ? 0 : y_if_x_is[79];
                    y_if_x_is[80] = (80 < old_x0 || 80 > old_x1) ? 0 : y_if_x_is[80];
                    y_if_x_is[81] = (81 < old_x0 || 81 > old_x1) ? 0 : y_if_x_is[81];
                    y_if_x_is[82] = (82 < old_x0 || 82 > old_x1) ? 0 : y_if_x_is[82];
                    y_if_x_is[83] = (83 < old_x0 || 83 > old_x1) ? 0 : y_if_x_is[83];
                    y_if_x_is[84] = (84 < old_x0 || 84 > old_x1) ? 0 : y_if_x_is[84];
                    y_if_x_is[85] = (85 < old_x0 || 85 > old_x1) ? 0 : y_if_x_is[85];
                    y_if_x_is[86] = (86 < old_x0 || 86 > old_x1) ? 0 : y_if_x_is[86];
                    y_if_x_is[87] = (87 < old_x0 || 87 > old_x1) ? 0 : y_if_x_is[87];
                    y_if_x_is[88] = (88 < old_x0 || 88 > old_x1) ? 0 : y_if_x_is[88];
                    y_if_x_is[89] = (89 < old_x0 || 89 > old_x1) ? 0 : y_if_x_is[89];
                    y_if_x_is[90] = (90 < old_x0 || 90 > old_x1) ? 0 : y_if_x_is[90];
                    y_if_x_is[91] = (91 < old_x0 || 91 > old_x1) ? 0 : y_if_x_is[91];
                    y_if_x_is[92] = (92 < old_x0 || 92 > old_x1) ? 0 : y_if_x_is[92];
                    y_if_x_is[93] = (93 < old_x0 || 93 > old_x1) ? 0 : y_if_x_is[93];
                    y_if_x_is[94] = (94 < old_x0 || 94 > old_x1) ? 0 : y_if_x_is[94];
                    y_if_x_is[95] = (95 < old_x0 || 95 > old_x1) ? 0 : y_if_x_is[95];
                end
                
               
                is_cleaning = 0;
                is_start = 1;
            end
            
            // Algorithm fox longer than y
            if (is_start == 1 && is_reset == 0 && is_x_longer == 1) begin
                x <= (x != x1) ? x + 1 : x1;
                
                if (p < 0) begin
                    p <= p + two_dy;
                end else if (is_negative_gradient == 1) begin
                    // increment y as well
                    p <= p + two_dy - two_dx;
                    y <= (y != y1) ? y + 1 : y1;
                end else if (is_negative_gradient == 0) begin
                    p <= p + two_dy - two_dx;
                    y <= (y != y1) ? y - 1 : y1;
                end
                
                new_y_if_x_is[x] = y;
            end
            
            // Algorithm for x shorter than y
            if (is_start == 1 && is_reset == 0 && is_x_longer == 0) begin
                y <= (y != y1) ? y + 1 : y1;
                
                if (p < 0) begin
                    p <= p + two_dx;
                end else if (is_negative_gradient == 0) begin
                    p <= p + two_dx - two_dy;
                    x <= (x != x1) ? x - 1 : x1;
                end else if (is_negative_gradient == 1) begin
                    p <= p + two_dx - two_dy;
                    x <= (x != x1) ? x + 1 : x1;
                end
                
                new_x_if_y_is[y] = x;
            end
            
            if (x == x1 && y == y1) begin
                old_x1 = x1;
                old_x0 = x0;
                old_y1 = y1;
                old_y0 = y0;
                x <= x0;
                y <= y0;
                is_done <= 1;
            end
        end
endmodule
