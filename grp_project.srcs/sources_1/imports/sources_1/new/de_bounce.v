`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.03.2024 10:55:50
// Design Name: 
// Module Name: de_bounce
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


module de_bounce(input btn, sysClk, input [31:0] ticks, input clk, output reg signal = 0);


    reg [31:0] count = 0;
    reg [0:0] state = 0;
    
    always @ (posedge sysClk) begin
        state <= btn ? 1 :
            (count < ticks && count >= 1) ? 1 : 0;
    end
    
    always @ (posedge clk) begin
                 
        count <= state ? 
                 (count < ticks ) ? count + 1 : ticks
                 : 0;
        
        signal = state;   
    
    end
endmodule
