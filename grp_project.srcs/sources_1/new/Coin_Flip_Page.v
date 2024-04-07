`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.03.2024 14:58:33
// Design Name: 
// Module Name: Coin_Flip_Page
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


module Coin_Flip_Page(
input clk, 
input btnL,
input btnR, 
input btnC,
input [7:0] JA,
output [7:0] JB, 
output [7:0] JC,
input [15:0] sw, 
input btnU, btnD,
output [15:0] led,
output [6:0] seg,
output dp,
output [3:0] an,
inout ps2_clk,
inout ps2_data);
    
    
        
    wire [7:0] curr_x;
    wire [6:0] curr_y;
    wire fb;
    wire [12:0] pixel_index;
    reg [15:0] oled_data = 16'b11111_111111_11111;
        
    //Values for our rectangle to allow for toggling between the 2 states
    reg [7:0] rectangle_x_value = 6;
    reg [6:0] rectangle_y_value = 2;
    
    //Clock Wires and Initialisations
    wire clock_6p25Mhz;
    wire clock_25Mhz;
    wire clock_1Hz;
    flexible_clock CoinFlip_6p25Mhz (clk, 7, clock_6p25Mhz);
    flexible_clock CoinFlip_25Mhz (clk, 1, clock_25Mhz);
    flexible_clock CoinFlip_1Hz (clk, 49999999,clock_1Hz);
    
    wire clk_6p25Mhz;
    flexible_clock clk_6p25M (clk, 7, clk_6p25Mhz);
    
    wire movementClk;
    flexible_clock move (clk, 99999, movementClk); //currently 500hz
    
    wire collisionClk;
    flexible_clock coll (clk, 24999, collisionClk);    //2khz
    //flexible_clock coll (clk, 1, collisionClk);
    
    wire placerClk;
    flexible_clock placer (clk, 2499999, placerClk); //25hz
    
    
    assign curr_x = pixel_index % 96;
    assign curr_y = pixel_index / 96;
    wire [15:0] rect_oled_data;
        
    wire toggleWire;
    reg toggleState = 0;
    reg [1:0] mainState = 0;
    reg rightState = 0;
    wire [15:0] result_oled_data;
    reg result_input = 0;
    wire [15:0] pool_oled_data;
    
 //-------------------------------------------------------------------------------------------->   
    reg [7:0] wallLeft = 3;
    reg [7:0] wallRight = 89;
    reg [6:0] wallUp = 3;
    reg [6:0] wallDown = 49;
    wire left, middle, right, new_event;
    wire [11:0] mouse_value = 12'd95;
    wire [11:0] mouseXpos, mouseYpos;
    wire [3:0] mouseZpos;
    
    wire [11:0] ballHandlerXpos;
    wire [11:0] ballHandlerYpos;    
    
    MouseCtl Master_Mouse(
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
    
    
    Mouse_Tx mouse_x_tx_final(
            .clk(clk),
            .enable(1),
            .input_data(mouseXpos),
            .JA(JB[0]),
            .check_tx(led[15])
            );

    wire [11:0] output_x_mouse_value;   
    mouse_receive mouse_x_rx_final(
        .clk(clk),
        .JB(JA[0]),
        .output_data(output_x_mouse_value) ,
        .checker(led[14])
        );        

    Mouse_Tx mouse_y_tx_final(
            .clk(clk),
            .enable(1),
            .input_data(mouseYpos),
            .JA(JB[1]),
            .check_tx(led[13])
            );

    wire [11:0] output_y_mouse_value;   
    mouse_receive mouse_y_rx_final(
        .clk(clk),
        .JB(JA[1]),
        .output_data(output_y_mouse_value) ,
        .checker(led[12])
        );        
    
    wire left_click;
    assign ballHandlerXpos = (sw[5]) ? output_x_mouse_value : mouseXpos;
    assign ballHandlerYpos = (sw[5]) ? output_y_mouse_value : mouseYpos;
    assign JB[2] = left;
    assign left_click = (sw[5]) ? JA[2] : left;
//------------------------------------------------------------------------------------->    

    
    
    ballHandler ballhandlr(
        .reset(sw[15]),
        .btnL(btnL),
        .btnC(btnC),
        .btnR(btnR),
        .mouseXpos(ballHandlerXpos),
        .mouseYpos(ballHandlerYpos),
        .leftClick(left_click),
        .btnU(btnU),
        .btnD(btnD),
        .sysClk(clk),
        .movementClk(movementClk),
        .collisionClk(collisionClk),
        .wallLeft(wallLeft),
        .wallRight(wallRight),
        .wallUp(wallUp),
        .wallDown(wallDown),
        .x(curr_x),
        .y(curr_y),
        .pixelData(pool_oled_data),
        .an(an),
        .seg(seg),
        .dp(dp),
        .placerClk(placerClk)
        );
    
              
    Oled_Display Coin_Page_Oled (
        .clk(clock_6p25Mhz), 
        .reset(0), 
        .frame_begin(fb), 
        .sending_pixels(),
        .sample_pixel(), 
        .pixel_index(pixel_index), 
        .pixel_data(oled_data), 
        .cs(JC[0]), 
        .sdin(JC[1]), 
        .sclk(JC[3]), 
        .d_cn(JC[4]), 
        .resn(JC[5]), 
        .vccen(JC[6]),
        .pmoden(JC[7])
        );        
        
    reg [15:0] bdColor;        
    rectangle_With_Alphabets coin_flip_rect (
        .Clk_Rect(clock_25Mhz),
        .x(curr_x),
        .y(curr_y),
        .borderColor(bdColor),
        .top_x(rectangle_x_value),
        .top_y(rectangle_y_value),
        .oled_data(rect_oled_data)
        );
     
    toggler_function(
       .clock(clock_1Hz),
       .randomOut(toggleWire)
       );
    
    Coin_Result coin_flip_result(
        .clock(clock_25Mhz),
        .result_check(result_input),
        .oled_data(result_oled_data)
        );     
    
    reg usedC = 0;  
    wire btnCSignal;
    
    de_bounce(
        .btn(btnC),
        .ticks(5), 
        .sysClk(clk),
        .clk(clock_1Hz), 
        .signal(btnCSignal)
        );
    
    wire [31:0] state1Count;    
    count_up_in_s state_1_counter(
            .CLOCK(clock_1Hz),
            .switch(sw[0]),
            .timeinseconds(5),
            .count(state1Count)
            );
    
    wire [31:0] state2Count;    
    count_up_in_s state_2_counter(
            .CLOCK(clock_1Hz),
            .switch(sw[1]),
            .timeinseconds(5),
            .count(state2Count)
            );
    
    wire [31:0] state3Count;    
    count_up_in_s state_3_counter(
            .CLOCK(clock_1Hz),
            .switch(sw[2]),
            .timeinseconds(5),
            .count(state3Count)
            ); 
    
    wire colortoggle;
    border_color_change(
        .CLOCK(clock_1Hz),
        .button(btnC),
        .timetosustain(25),
        .changeColor (colortoggle)
        );        
   
   wire [15:0] pool_logo;
   pool_startpage pool_Start_final(
        .clk(clk),
        .pixels(pixel_index),
        .oled_data(pool_logo)
         );
         
    wire [15:0] pixel_startup_data;     
    startup_page startup_final(
             .clk(clk),
             .pixels_startup(pixel_index),
             .oled_startup(pixel_startup_data)
             );
    
    
    wire [15:0] pixel_heads_data;          
    heads heads_final(
        .clk(clk),
        .pixels_heads(pixel_index),
        .oled_heads(pixel_heads_data)    
        );
          
    wire [15:0] pixel_tails_data;             
    tails tails_final(
        .clk(clk),
        .pixels_tails(pixel_index),
        .oled_tails(pixel_tails_data)
        );
        
    wire [15:0] pixel_finish_data;
    finish finish_finals(
        .clk(clk),
        .pixels_finish(pixel_index),
        .oled_finish(pixel_finish_data)
        );
//--------------------------------------   INTRA-UART   ------------------------------------->         
wire [15:0] intra_uart_info;
Intra_UART intra_uart_module(
    .clk(clk),
    .receive(JA[4]),
    .transmit(JB[4]),
    .pixel_data_received (intra_uart_info)
    );
//--------------------------------------------------------------------------------------> 
wire random_generation;
randomizer random_final(
    .clk(clk),
    .switch(sw[0]),
    .rng(random_generation)
    );

    always @ (posedge clock_25Mhz)
        begin
        
         //Initialisation
         oled_data <= pixel_startup_data;
         toggleState <= toggleWire;
         rightState = (btnR && !colortoggle) ? 1 : rightState;
         rightState = (btnL && !colortoggle) ? 0 : rightState;
         
            
         if (sw[0] && (state1Count == 5) )
           begin
           if (random_generation)
               begin
               oled_data <= pixel_heads_data;
               end
           
           else 
               begin
               oled_data <= pixel_tails_data;
               end

           end
           
         if (sw[1] && (state2Count == 5))
           begin
            oled_data <= pool_oled_data;
           end
          
         if (sw[2] && (state3Count == 5))
         begin
          oled_data <= pixel_finish_data;
         end
        end
        
endmodule
