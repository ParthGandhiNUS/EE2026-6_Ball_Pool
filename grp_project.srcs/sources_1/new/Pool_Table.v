`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.03.2024 17:53:58
// Design Name: 
// Module Name: Pool_Table
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


module Pool_Table(input clock_pool, input [7:0] curr_x, input [6:0] curr_y, output reg [15:0] oled_data = 16'b00010_010110_01000 );
        
        always @ (posedge clock_pool)
               begin
               
               // Vertical Border
               if ((curr_x == 2 || curr_x == 3 || curr_x == 89 || curr_x == 90) && (curr_y >= 2 && curr_y <=50))
                   begin
                    oled_data <= 16'b01001_001000_00000; // Supposed to be brown (black for now)
                   end
              
               //Horizontal Border
                else if ((curr_y == 2 || curr_y == 3 || curr_y == 49 || curr_y == 50) && (curr_x >= 2 && curr_x <= 90))
                 begin
                  oled_data <= 16'b01001_001000_00000;
                 end
               
               //Inner vertical dark green border
               else if ((curr_x == 6||curr_x == 5||curr_x == 4||curr_x == 86||curr_x == 87||curr_x == 88) && (curr_y >= 10 && curr_y <=42))
                begin
                  oled_data <= 16'b00000_111111_00000;
                end
               //Inner horizontal dark green border 
               else if ((curr_y == 6|| curr_y ==5||curr_y ==4||curr_y ==46||curr_y ==47||curr_y ==48) && ((curr_x >= 10 && curr_x <=42) || (curr_x >= 49 && curr_x <=82)))
                begin
                  oled_data <= 16'b00000_111111_00000;
                end 
                
                else if ( (curr_x >= 4 && curr_x <= 9) && ((curr_y >= 4 && curr_y <= 9 )|| (curr_y >= 43 && curr_y <= 48) ))
                    begin
                    oled_data <= 16'b11111_111111_11111;
                    end
                    
               else if ( (curr_x >= 43 && curr_x <= 48) && ((curr_y >= 4 && curr_y <= 9 )|| (curr_y >= 43 && curr_y <= 48) ))
                    begin
                    oled_data <= 16'b11111_111111_11111;
                    end  
               
               else if ( (curr_x >= 83 && curr_x <= 88) && ((curr_y >= 4 && curr_y <= 9 )|| (curr_y >= 43 && curr_y <= 48) ))
                    begin
                    oled_data <= 16'b11111_111111_11111;
                    end
//              // normal green  
//              else if ((curr_x == 4 || curr_x == 5 || curr_x == 87 || curr_x == 88) && (curr_y >= 10 && curr_y <=42))
//                begin
//                  oled_data <= 16'b00010_010110_010000;
//                end
//              //normal green  
//              else if ((curr_y == 4 || curr_y == 5 || curr_y == 7 || curr_y == 8 || curr_y == 9 || curr_y == 43 || curr_y == 44 || curr_y == 45 || curr_y == 47 || curr_y == 48) && ((curr_x >= 10 && curr_x <=42) || (curr_x >= 49 && curr_x <=82)))
//                begin
//                  oled_data <= 16'b00010_010110_01000;
//                end
//              //normal green  
//              else if ((curr_x >= 7 && curr_x <= 85) && (curr_y >= 10 && curr_y <= 42))
//                begin
//                  oled_data <= 16'b00010_010110_01000;
//                end
                  
              else 
                  begin
                  //oled_data <= 16'b11111_111111_11111;
                  oled_data <= 16'b00010_010110_01000;
                  end
               end

endmodule
