`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/27 13:28:04
// Design Name: 
// Module Name: pll_test
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


module pll_test(
        input sys_clk_p,
        input sys_clk_n,
        input rst_n,
        output clk_out
    );

wire sys_clk_ibufg;
IBUFGDS #
    ( 
    .DIFF_TERM ("TRUE"), 
    .IBUF_LOW_PWR ("FALSE") 
    ) 
    u_ibufg_sys_clk 
    ( 
    .I (sys_clk_p), 
    .IB (sys_clk_n), 
    .O (sys_clk_ibufg) 
    );

wire locked;
wire pll_clk_o;

clk_wiz_0 clk_wiz_0_inst (
    .clk_in1(sys_clk_ibufg),
    .clk_out1(),
    .clk_out2(),
    .clk_out3(),
    .clk_out4(pll_clk_o),
    .reset(~rst_n),
    .locked(locked)
    );

ODDR2 #(
    .DDR_ALIGNMENT("NONE"),
    .INIT(1'b0),
    .SRTYPE("SYNC")
    ) ODDR2_inst (
    .Q(clk_out),
    .C0(pll_clk_o),
    .C1(~pll_clk_o),
    .CE(1'b1),
    .D0(1'b1),
    .D1(1'b0),
    .R(1'b0),
    .S(1'b0)
    );
    
endmodule
