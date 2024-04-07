`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.04.2024 10:21:18
// Design Name: 
// Module Name: Mouse_UART
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


module Mouse_UART(
    input clk,
    input [15:0] sw,
    input [7:0] JB,
    output [7:0] JA,
    output [15:0] led,
    inout ps2_clk,
    inout ps2_data
    );
    
    wire [11:0] mouse_value = 12'd95;
    wire [11:0] mouseXpos, mouseYpos;
    wire [3:0] mouseZpos;
    wire left, middle, right, new_event;
    
    MouseCtl UART_mousectl(
        .clk(clk),
        .rst(0),
        .value(mouse_value),
        .setx(0),
        .sety(0),
        .setmax_x(1),
        .setmax_y(1),
        .xpos(mouseXpos),
        .ypos(mouseYpos),
        .zpos(mouseZpos),
        .left(left), .middle(middle), .right(right), .new_event(new_event),
        .ps2_clk(ps2_clk), .ps2_data(ps2_data)
        );
    
    Mouse_Tx mouse_x_tx(
        .clk(clk),
        .enable(sw[0]),
        .input_data(mouseXpos),
        .JA(JA[0]),
        .check_tx(led[0])
        );
    
    wire [11:0] output_data_value;   
    mouse_receive mouse_x_rx(
        .clk(clk),
        .JB(JB[0]),
        .output_data(output_data_value) ,
        .checker(led[1])
        );    

//    Mouse_Tx mouse_y_tx(
//        .clk(clk),
//        .enable(sw[1]),
//        .input_data(mouseYpos),
//        .JA(JA[1]),
//        .check_tx(led[2])
//        );
        
//    mouse_receive mouse_y_rx(
//        .clk(clk),
//        .JB(JB[1]),
//        .output_data(led[15:4]) ,
//        .checker(led[3])
//        );    

assign led[15:4] = output_data_value[11:0];


endmodule
