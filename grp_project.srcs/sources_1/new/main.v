`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.03.2024 12:10:50
// Design Name: 
// Module Name: main
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


module main(
    input clk, 
    input [15:0] sw, 
    output [7:0] JC,
    input btnC,
    input btnL,
    input btnR,
    input btnU, btnD,
    output [15:0] led,
    output [6:0] seg,
    output [3:0] an
    );
    
    wire clk_6p25Mhz;
    flexible_clock clk_6p25M (clk, 7, clk_6p25Mhz);
    
    wire movementClk;
    flexible_clock move (clk, 99999, movementClk); //currently 500hz
    
    wire collisionClk;
    flexible_clock coll (clk, 24999, collisionClk);    //2khz
    //flexible_clock coll (clk, 1, collisionClk);
    
    wire placerClk;
    flexible_clock placer (clk, 999999, placerClk); //50hz
    
    wire fb;
    wire [12:0] pixel_index;
    wire [7:0] x = pixel_index % 96;
    wire [6:0] y = pixel_index / 96;
    
    wire [15:0] pixelData;
    
    reg [7:0] wallLeft = 3;
    reg [7:0] wallRight = 89;
    reg [6:0] wallUp = 3;
    reg [6:0] wallDown = 49;

    ballHandler ballhandlr(
        .btnL(btnL),
        .btnC(btnC),
        .btnR(btnR),
        .btnU(btnU),
        .btnD(btnD),
        .sysClk(clk),
        .movementClk(movementClk),
        .collisionClk(collisionClk),
        .wallLeft(wallLeft),
        .wallRight(wallRight),
        .wallUp(wallUp),
        .wallDown(wallDown),
        .x(x),
        .y(y),
        .pixelData(pixelData),
        .led(led), 
        .sw(sw[0]),
        .placerClk(placerClk)
        );
                            
    Oled_Display oled (
        .clk(clk_6p25Mhz),
        .reset(0),
        .frame_begin(fb), 
        .sending_pixels(0),
        .sample_pixel(0), 
        .pixel_index(pixel_index), 
        .pixel_data(pixelData), 
        .cs(JC[0]), 
        .sdin(JC[1]), 
        .sclk(JC[3]), 
        .d_cn(JC[4]), 
        .resn(JC[5]), 
        .vccen(JC[6]),
        .pmoden(JC[7])
        ); 
        
endmodule
