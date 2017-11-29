`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name:    rtc_test 
// set and read the time from rtc, and send the time to uart port 
//////////////////////////////////////////////////////////////////////////////////

module rtc_test
(
    input          sys_clk_p,
    input          sys_clk_n,  
	input          rst_n,
	 
	 input          uart1_rx,                  //usb uart rx
     output         uart1_tx,                  //usb uart tx 
	
	 output         DS1302_RST,                 //ds1302 CE/RST
	 output         DS1302_SCLK,                //ds1302 SCLK
	 inout          DS1302_SIO                  //ds1302 SIO
	 

);


	 
/*******************************/
wire [7:0] Time_second;
wire [7:0] Time_munite;
wire [7:0] Time_hour;

reg [7:0] Time_second_reg;

wire clk;

reg [7:0] time_disp [17:0];                        //�洢�����ַ�

reg [15:0] uart_cnt;
reg [2:0] uart_stat;

reg  [7:0]  txdata;             //���ڷ����ַ�
reg         wrsig;               //���ڷ�����Ч�ź�

reg [8:0] k;

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
              			  
/********************************************/
//�洢�����͵�ʱ���ַ�
/********************************************/
always @(*)
begin     //���巢�͵��ַ�
	 time_disp[0]<=84;                           //�洢�ַ�T 
	 time_disp[1]<=105;                          //�洢�ַ�i
     time_disp[2]<=109;                          //�洢�ַ�m
	 time_disp[3]<=101;                          //�洢�ַ�e 	 
	 time_disp[4]<=32;                           //�洢�ַ��ո�                           
	 time_disp[5]<=105;                          //�洢�ַ�i 
	 time_disp[6]<=115;                          //�洢�ַ�s
	 time_disp[7]<=32;                           //�洢�ַ��ո� 
	 time_disp[8]<=Time_hour[7:4]+48;            //�洢�ַ�Сʱʮλ
	 time_disp[9]<=Time_hour[3:0]+48;            //�洢�ַ�Сʱ
	 time_disp[10]<=58;                           //�洢�ַ�:
	 time_disp[11]<=Time_munite[7:4]+48;         //�洢�ַ�����ʮλ
	 time_disp[12]<=Time_munite[3:0]+48;         //�洢�ַ�����
	 time_disp[13]<=58;                          //�洢�ַ�:
	 time_disp[14]<=Time_second[7:4]+48;         //�洢�ַ�����ʮλ
	 time_disp[15]<=Time_second[3:0]+48;         //�洢�ַ�����
	 time_disp[16]<=10;                          //���з�
	 time_disp[17]<=13;                          //�س��� 
end 

/**********��������ʱ��***********/
clkdiv u0 (
		.clk200                  (sys_clk_ibufg),                           
		.clkout                  (clk)             //���ڷ���ʱ��                 
 );
/********************************************/
//���ڷ���ʱ���ַ���
/********************************************/
always @(posedge clk )
begin
  if(!rst_n) begin   
		uart_cnt <= 0;
		uart_stat <= 3'b000;	
		k<=0;
  end
  else begin
  	 case(uart_stat)
	 3'b000: begin               
       if (Time_second_reg != Time_second) begin          //����������б仯,�򴮿ڷ���ʱ����Ϣtime_disp[0]~time_disp[17]
		    uart_stat <= 3'b001; 
			 Time_second_reg<=Time_second;
		 end
		 else begin
			 uart_stat <= 3'b000; 
			 Time_second_reg<=Time_second;
		 end
	 end	
	 3'b001: begin                      //���͵�18���ַ�time_disp[17]  
         if (k == 17 ) begin          		 
				 if(uart_cnt ==0) begin
					txdata <= time_disp[17]; 
					uart_cnt <= uart_cnt + 1'b1;
					wrsig <= 1'b1;                	//uart������Ч			
				 end	
				 else if(uart_cnt ==254) begin      //����һ���ַ��ĵȴ�ʱ��Ϊ255��ʱ��,�ȴ�ʱ��ֻҪ����168��ʱ��(һ���ֽڷ��͵�ʱ��)
					uart_cnt <= 0;
					wrsig <= 1'b0; 				
					uart_stat <= 3'b010; 
					k <= 0;
				 end
				 else	begin			
					 uart_cnt <= uart_cnt + 1'b1;
					 wrsig <= 1'b0;  
				 end
		 end
	    else begin
				 if(uart_cnt ==0) begin      //����ǰ17���ַ� 
					txdata <= time_disp[k]; 
					uart_cnt <= uart_cnt + 1'b1;
					wrsig <= 1'b1;                			
				 end	
				 else if(uart_cnt ==254) begin //����һ���ַ��ĵȴ�ʱ��Ϊ255��ʱ��,�ȴ�ʱ��ֻҪ����168��ʱ��(һ���ֽڷ��͵�ʱ��)
					uart_cnt <= 0;
					wrsig <= 1'b0; 
					k <= k + 1'b1;				
				 end
				 else	begin			
					 uart_cnt <= uart_cnt + 1'b1;
					 wrsig <= 1'b0;  
				 end
		 end	 
	 end
	 3'b010: begin       //����finish	 
		 	uart_stat <= 3'b000; 
	 end
	 default:uart_stat <= 3'b000;
    endcase 
  end
end
	 
/**********���ڷ��ͳ���***********/
uarttx u1 (
	  .clk                     (clk),                           
	  .datain                  (txdata),
      .wrsig                   (wrsig), 
      .idle                    (idle), 	
	  .tx                      (uart1_tx)		
 );
 
/**********RTCʱ�ӿ��Ƴ���***********/	 
rtc_time u2 (

       .CLK( sys_clk_ibufg ), 
	   .RSTn( rst_n ),
		 
	   .Time_second( Time_second ),             //DS1302������������
	   .Time_munite( Time_munite ),             //DS1302�����ķ�����
	   .Time_hour( Time_hour ),                 //DS1302������ʱ����

	   .RST( DS1302_RST ),
	   .SCLK( DS1302_SCLK ),
	   .SIO( DS1302_SIO )	 

);
	 
 

endmodule
