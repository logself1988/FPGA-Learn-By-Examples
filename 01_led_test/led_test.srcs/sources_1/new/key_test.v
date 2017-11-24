`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/23 17:25:10
// Design Name: 
// Module Name: key_test
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


module key_test(
    input sys_clk_p,
    input sys_clk_n,
    input rst_n,
    input [3:0] key_in,
    output [3:0] led_out
    );
    
//===================
//Definition
//===================
reg [23:0] count;
reg [3:0] key_scan;
reg [3:0] key_scan_r;

//wire [3:0] key_flag;
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

//===============================
//每隔20ms采样按键值
//===============================    
always @(posedge sys_clk_ibufg or negedge rst_n)
    begin
        if(!rst_n)
            count <= 24'd0;
        else 
            begin
                if(count == 24'd3_999_999)   //20ms check the key value
                    begin
                        count <= 24'b0;
                        key_scan <= key_in;
                    end
                 else
                    count <= count + 24'b1;
             end
     end

//=============================
//检测按键是否按下
//=============================
always @(posedge sys_clk_ibufg)
    key_scan_r <= key_in;
    wire [3:0] key_flag = key_scan_r[3:0] & (~key_scan[3:0]);

//=============================
//LED按键控制反转
//=============================
reg [3:0] temp_led;
always @(posedge sys_clk_ibufg or negedge rst_n)
    begin
    if(!rst_n)
        temp_led <= 4'b1111;
    else
        begin
            if(key_flag[0]) temp_led[0] <= ~temp_led[0];
            if(key_flag[1]) temp_led[1] <= ~temp_led[1];
            if(key_flag[2]) temp_led[2] <= ~temp_led[2];
            if(key_flag[3]) temp_led[3] <= ~temp_led[3];
        end 
     end
     
assign led_out[0] = temp_led[0];
assign led_out[1] = temp_led[1];
assign led_out[2] = temp_led[2];
assign led_out[3] = temp_led[3];
                    
    
endmodule
