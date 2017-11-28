`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/28 11:19:53
// Design Name: 
// Module Name: uarttx
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


module uarttx(
    clk,
    datain,
    wrsig,
    idle,
    tx  
    );

input clk;           //UARTʱ�ӣ�16��clk����һ��bit
input [7:0] datain;  //��Ҫ���͵�����
input wrsig;         //���������������Ч
output idle;         //��·״ָ̬ʾ����Ϊæ����Ϊ����            
output tx;           //���������ź�

reg idle,tx;
reg send;
reg wrsigbuf,wrsigrise;
reg presult;
reg [7:0] cnt;
parameter paritymode = 1'b0;

//��ⷢ�������Ƿ���Ч���ж�wrsig��������
always @(posedge clk)
begin
    wrsigbuf <= wrsig;
    wrsigrise <= (~wrsigbuf) & wrsig;
end

always @(posedge clk)
begin
    if (wrsigrise && (~idle))
    begin
        send <= 1'b1;
    end
    else if (cnt == 8'd168)
    begin
        send <= 1'b0;
    end
end

always @(posedge clk)
begin
  if(send == 1'b1)  begin
    case(cnt)                 //tx��͵�ƽ������ʼλ��0~15��ʱ��Ϊ������ʼλ
    8'd0: begin
         tx <= 1'b0;
         idle <= 1'b1;
         cnt <= cnt + 8'd1;
    end
    8'd16: begin
         tx <= datain[0];    //��������λ�ĵ�λbit0,ռ�õ�16~31��ʱ��
         presult <= datain[0]^paritymode;
         idle <= 1'b1;
         cnt <= cnt + 8'd1;
    end
    8'd32: begin
         tx <= datain[1];    //��������λ�ĵ�2λbit1,ռ�õ�47~32��ʱ��
         presult <= datain[1]^presult;
         idle <= 1'b1;
         cnt <= cnt + 8'd1;
    end
    8'd48: begin
         tx <= datain[2];    //��������λ�ĵ�3λbit2,ռ�õ�63~48��ʱ��
         presult <= datain[2]^presult;
         idle <= 1'b1;
         cnt <= cnt + 8'd1;
    end
    8'd64: begin
         tx <= datain[3];    //��������λ�ĵ�4λbit3,ռ�õ�79~64��ʱ��
         presult <= datain[3]^presult;
         idle <= 1'b1;
         cnt <= cnt + 8'd1;
    end
    8'd80: begin 
         tx <= datain[4];   //��������λ�ĵ�5λbit4,ռ�õ�95~80��ʱ��
         presult <= datain[4]^presult;
         idle <= 1'b1;
         cnt <= cnt + 8'd1;
    end
    8'd96: begin
         tx <= datain[5];    //��������λ�ĵ�6λbit5,ռ�õ�111~96��ʱ��
         presult <= datain[5]^presult;
         idle <= 1'b1;
         cnt <= cnt + 8'd1;
    end
    8'd112: begin
         tx <= datain[6];    //��������λ�ĵ�7λbit6,ռ�õ�127~112��ʱ��
         presult <= datain[6]^presult;
         idle <= 1'b1;
         cnt <= cnt + 8'd1;
    end
    8'd128: begin 
         tx <= datain[7];    //��������λ�ĵ�8λbit7,ռ�õ�143~128��ʱ��
         presult <= datain[7]^presult;
         idle <= 1'b1;
         cnt <= cnt + 8'd1;
    end
    8'd144: begin
         tx <= presult;      //������żУ��λ��ռ�õ�159~144��ʱ��
         presult <= datain[0]^paritymode;
         idle <= 1'b1;
         cnt <= cnt + 8'd1;
    end
    8'd160: begin
         tx <= 1'b1;         //����ֹͣλ��ռ�õ�160~167��ʱ��            
         idle <= 1'b1;
         cnt <= cnt + 8'd1;
    end
    8'd168: begin           //����λ8��ʱ�� 
         tx <= 1'b1;             
         idle <= 1'b0;       //һ֡���Ϸ��ͽ���
         cnt <= cnt + 8'd1;
    end
    default: begin
          cnt <= cnt + 8'd1;
    end
   endcase
  end
  else  begin
    tx <= 1'b1;
    cnt <= 8'd0;
    idle <= 1'b0;
  end
end

endmodule
