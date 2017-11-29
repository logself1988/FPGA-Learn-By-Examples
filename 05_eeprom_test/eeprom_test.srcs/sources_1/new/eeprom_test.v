`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/29 10:31:42
// Design Name: 
// Module Name: eeprom_test
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


module eeprom_test(
    input sys_clk_p,
    input sys_clk_n, 
    input RSTn,
    output SCL,          //EEPROM IIC clock
    inout SDA            //EEPROM IIC data
    );
  
wire [7:0] RdData;       //EEPROM �������ݼĴ���
wire Done_Sig;           //IICͨ������ź�

reg [3:0] i;
reg [3:0] rLED;

reg [7:0] rAddr;
reg [7:0] rData;
reg [1:0] isStart;

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

/***************************/
/*   EEPROM write and read */
/***************************/	  
always @ ( posedge sys_clk_ibufg or negedge RSTn )	
	 if( !RSTn ) begin
			i <= 4'd0;
			rAddr <= 8'd0;
			rData <= 8'd0;
			isStart <= 2'b00;
         rLED <= 4'b0000;
	 end
	 else
		case( i )
				
	     0:
		  if( Done_Sig ) begin isStart <= 2'b00; i <= i + 1'b1; end                    //�ȴ�IICд�������, ���i״̬��Ϊ1
		  else begin isStart <= 2'b01; rData <= 8'h12; rAddr <= 8'd0; end              //eeprom д����(0x12)��addr 0
					 
		  1:
		  if( Done_Sig ) begin isStart <= 2'b00; i <= i + 1'b1; end                    //�ȴ�IIC���������, ���i״̬��Ϊ2
		  else begin isStart <= 2'b10; rAddr <= 8'd0; end                              //eeprom �� addr 0������
					 
		  2:
		  begin rLED <= RdData[3:0]; end		                 //led�Ƹ�ֵ 
		
		endcase	
	 
/***************************/
//I2Cͨ�ų���//
/***************************/				
iic_com U1
	 (
	     .CLK( sys_clk_ibufg ),
		  .RSTn( RSTn ),
		  .Start_Sig( isStart ),                //iic��д����: 2'b01ΪIICд; 2'b10ΪIIC��
		  .Addr_Sig( rAddr ),                   //EEPROM��iic��д��ַ
		  .WrData( rData ),                     //EEPROM��iicд����
		  .RdData( RdData ),                    //EEPROM��iic������
		  .Done_Sig( Done_Sig ),                //IIC��д����ź�,��IIC��д�������
	      .SCL( SCL ),
		  .SDA( SDA )
);

/***************************/
//chipscope icon��ila, ���ڹ۲��ź�//
/***************************/	
wire [7:0] probe0;
ila_0 u_ila_0(
	.clk(sys_clk_ibufg),
	.probe0(probe0)

);

assign probe0[7:0] = RdData[7:0];
endmodule
