`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.03.2024 16:17:25
// Design Name: 
// Module Name: rectangle
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


module rectangle_With_Alphabets(
    input Clk_Rect,
    input [7:0] x,
    input [6:0] y,
    input [15:0] borderColor,
    input [7:0] top_x,
    input [6:0] top_y,
    output reg [15:0] oled_data);
    
    always @ (posedge Clk_Rect)
    begin
    
    if ((x >= top_x && x <= (top_x + 33)) && (y >= top_y && y <= (top_y + 1))) 
            begin
                oled_data <= borderColor;
            end
            
    else if ((x >= top_x && x <= (top_x + 33)) && (y >= (top_y + 50) && y <= (top_y + 51))) 
           begin
               oled_data <= borderColor;
           end
               
    else if (( y >= (top_y + 2) && y <= (top_y + 49)) && (x >= top_x  && x <= (top_x + 1)))
            begin
                oled_data <= borderColor;
            end

    else if (( y >= (top_y + 2) && y <= (top_y + 49)) && (x >= (top_x + 32) && x <= (top_x + 33)))
            begin
                oled_data <= borderColor;
            end
    
     //Vertical Lines
    else if ((x == 10 || x == 11 || x == 34 || x == 35 || x == 70 || x == 71 ) && (y >= 5 && y <=50))
        begin
            oled_data <= 16'b0; // black
        end
               
               //Horizontal Lines for H
    else if ((y == 27 || y == 28 || y == 29 ) && (x >= 10 && x <=35))
        begin
            oled_data <= 16'b0; // black
        end
               
               //Horizontal lines for T
    else if ((y == 5 || y == 6 || y == 7 ) && (x >= 58 && x <=83))
        begin
            oled_data <= 16'b0; // black
        end
        
    else
        begin
            oled_data <= 16'b11111_111111_11111;
        end
    
    end
endmodule
