`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/28 11:19:53
// Design Name: 
// Module Name: uart_test
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


module uart_test(
    input sys_clk_p,
    input sys_clk_n,
    input uart1_rx,
    output uart1_tx
    );
    
////////////////���ʱ��ת���ɵ���ʱ��////////////////////////
    wire sys_clk_ibufg;
     IBUFGDS #
           (
            .DIFF_TERM    ("FALSE"),
            .IBUF_LOW_PWR ("FALSE")
            )
           u_ibufg_sys_clk
             (
              .I  (sys_clk_p),
              .IB (sys_clk_n),
              .O  (sys_clk_ibufg)
              );
    
    wire clk;       //clock for 9600 uart port
    wire [7:0] txdata,rxdata;     //���ڷ������ݺʹ��ڽ�������
    
    
    
    //����ʱ�ӵ�Ƶ��Ϊ16*9600
    clkdiv u0 (
            .clk200                  (sys_clk_ibufg),       //200Mhz�ľ�������                     
            .clkout                  (clk)                  //16�������ʵ�ʱ��                        
     );
    
    //���ڽ��ճ���
    uartrx u1 (
            .clk                     (clk),                 //16�������ʵ�ʱ�� 
            .rx                         (uart1_rx),              //���ڽ���
            .dataout                 (rxdata),              //uart ���յ�������,һ���ֽ�                     
            .rdsig                   (rdsig),               //uart ���յ�������Ч 
            .dataerror               (),
            .frameerror              ()
    );
    
    //���ڷ��ͳ���
    uarttx u2 (
            .clk                     (clk),                  //16�������ʵ�ʱ��  
            .tx                      (uart1_tx),             //���ڷ���
            .datain                  (txdata),               //uart ���͵�����   
            .wrsig                   (wrsig),                //uart ���͵�������Ч  
            .idle                    ()     
        
     );
    
    //�������ݷ��Ϳ��Ƴ���
    uartctrl u3 (
            .clk                     (clk),                           
            .rdsig                   (rdsig),                //uart ���յ�������Ч   
            .rxdata                  (rxdata),                  //uart ���յ������� 
            .wrsig                   (wrsig),                //uart ���͵�������Ч  
            .dataout                 (txdata)                 //uart ���͵����ݣ�һ���ֽ� 
        
     );
endmodule
