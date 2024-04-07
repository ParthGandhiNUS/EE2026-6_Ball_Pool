`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.04.2024 18:08:28
// Design Name: 
// Module Name: randomizer
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


module randomizer(
    input clk,
    input switch,
    output reg rng
    );
    
    reg [7:0] bit_counter = 0;
    reg intermediate = 0;
    reg bool = 0;
    
    always @ (posedge clk)
    begin
    bit_counter <= bit_counter + 1;
    
    intermediate <= bit_counter[7]^bit_counter[6]^bit_counter[5]^bit_counter[4]^bit_counter[3]^bit_counter[2]^bit_counter[1]^bit_counter[0];
    end
    
    always @ (posedge clk)
    begin
    if (switch && !bool)
        begin
        rng <= intermediate;
        end
        bool <= switch;
    end
    
    
    
endmodule
