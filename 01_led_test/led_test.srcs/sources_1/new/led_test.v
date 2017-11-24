`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/22 17:29:03
// Design Name: 
// Module Name: led_test
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

module led_test(
        sys_clk_p,
        sys_clk_n,
        rst_n,
        led
    );
       
//=================================
//Port Declaration
//=================================
 
 input sys_clk_p;
 input sys_clk_n;
 input rst_n;
 output [3:0] led;
 
 //==================================
 //Definition
 //==================================
 reg [31:0] timer;
 reg [3:0] led;
 wire sys_clk_ibufg;
 
 //==================================
 //差分时钟转换为单端时钟
 //==================================
 IBUFGDS #
    (
        .DIFF_TERM  ("FALSE"),
        .IBUF_LOW_PWR ("FALSE")
     )
     u_ibug_sys_clk
        (
            .I  (sys_clk_p),
            .IB  (sys_clk_n),
            .O  (sys_clk_ibufg)
         );

//===================================
//计数器计数
//===================================
always @(posedge sys_clk_ibufg or negedge rst_n)
    begin
        if(~rst_n)
            timer <= 0;
        else if(timer == 32'd199_999_999)
            timer <= 0;
        else
            timer <= timer + 1'b1;
    end
    

//====================================
//LED control
//====================================
always @(posedge sys_clk_ibufg or negedge rst_n)
    begin
        if(~rst_n)
            led <= 4'b0000;
        else if(timer == 32'd49_999_999)
            led <= 4'b1110;
        else if(timer == 32'd99_999_999)
            led <= 4'b1101;
        else if(timer == 32'd149_999_999)
            led <= 4'b1011;
        else if(timer == 32'd199_999_999)
            led <= 4'b0111;
    end
    
    
endmodule
