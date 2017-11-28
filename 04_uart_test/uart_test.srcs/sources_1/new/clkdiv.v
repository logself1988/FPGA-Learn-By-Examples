`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/28 11:19:53
// Design Name: 
// Module Name: clkdiv
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
//16*9600 = 153600
//200MHz/153600 = 1302

module clkdiv(
    clk200,
    clkout
    );
    
input clk200;
output clkout;
reg clkout;
reg [15:0] cnt;

always @(posedge clk200)
    begin
        if(cnt == 16'd650)  //??
        begin
            clkout <= 1'b1;
            cnt <= cnt + 16'd1;
        end
        else if(cnt == 16'd1301)
        begin
            clkout <= 1'b0;
            cnt <= 16'd0;
        end
        else
        begin
            cnt <= cnt + 16'd1;
        end
    end              

endmodule
