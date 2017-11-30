`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name:    vga_test 
//
//////////////////////////////////////////////////////////////////////////////////
module vga_test(
            input rst_n,
            input sys_clk_p,
            input sys_clk_n, 
            output vga_clk, 
			output vga_hs,
			output vga_vs,
			output vga_en,
			output [7:0] vga_r,
			output [7:0] vga_g,
			output [7:0] vga_b,
			input key1                        //����key1
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
                  
//-----------------------------------------------------------//
// ˮƽɨ��������趨1024*768 60Hz VGA
//-----------------------------------------------------------//
parameter LinePeriod =1344;            //��������
parameter H_SyncPulse=136;             //��ͬ�����壨Sync a��
parameter H_BackPorch=160;             //��ʾ���أ�Back porch b��
parameter H_ActivePix=1024;            //��ʾʱ��Σ�Display interval c��
parameter H_FrontPorch=24;             //��ʾǰ�أ�Front porch d��
parameter Hde_start=296;
parameter Hde_end=1320;

//-----------------------------------------------------------//
// ��ֱɨ��������趨1024*768 60Hz VGA
//-----------------------------------------------------------//
parameter FramePeriod =806;           //��������
parameter V_SyncPulse=6;              //��ͬ�����壨Sync o��
parameter V_BackPorch=29;             //��ʾ���أ�Back porch p��
parameter V_ActivePix=768;            //��ʾʱ��Σ�Display interval q��
parameter V_FrontPorch=3;             //��ʾǰ�أ�Front porch r��
parameter Vde_start=35;
parameter Vde_end=803;

//-----------------------------------------------------------//
// ˮƽɨ��������趨800*600 VGA
//-----------------------------------------------------------//
//parameter LinePeriod =1056;           //��������
//parameter H_SyncPulse=128;            //��ͬ�����壨Sync a��
//parameter H_BackPorch=88;             //��ʾ���أ�Back porch b��
//parameter H_ActivePix=800;            //��ʾʱ��Σ�Display interval c��
//parameter H_FrontPorch=40;            //��ʾǰ�أ�Front porch d��

//-----------------------------------------------------------//
// ��ֱɨ��������趨800*600 VGA
//-----------------------------------------------------------//
//parameter FramePeriod =628;           //��������
//parameter V_SyncPulse=4;              //��ͬ�����壨Sync o��
//parameter V_BackPorch=23;             //��ʾ���أ�Back porch p��
//parameter V_ActivePix=600;            //��ʾʱ��Σ�Display interval q��
//parameter V_FrontPorch=1;             //��ʾǰ�أ�Front porch r��


  reg[10 : 0] x_cnt;
  reg[9 : 0]  y_cnt;
  reg[23 : 0] grid_data_1;
  reg[23 : 0] grid_data_2;
  reg[23 : 0] bar_data;
  reg[3 : 0] vga_dis_mode;
  reg[7 : 0]  vga_r_reg;
  reg[7 : 0]  vga_g_reg;
  reg[7 : 0]  vga_b_reg;  
  reg hsync_r;
  reg vsync_r; 
  reg hsync_de;
  reg vsync_de;
  
  reg [15:0] key1_counter;                 //�������Ĵ���
  
  wire CLK_OUT1;
  wire CLK_OUT2;
  wire CLK_OUT3;
  wire CLK_OUT4; 
  
  wire [12:0]  bar_interval;  
  
assign	bar_interval 	= H_ActivePix[15: 3];         //�������=H_ActivePix/8  
  
//----------------------------------------------------------------
////////// ˮƽɨ�����
//----------------------------------------------------------------
always @ (posedge vga_clk)
       if(~rst_n)    x_cnt <= 1;
       else if(x_cnt == LinePeriod) x_cnt <= 1;
       else x_cnt <= x_cnt+ 1;
		 
//----------------------------------------------------------------
////////// ˮƽɨ���ź�hsync,hsync_de����
//----------------------------------------------------------------
always @ (posedge vga_clk)
   begin
       if(~rst_n) hsync_r <= 1'b1;
       else if(x_cnt == 1) hsync_r <= 1'b0;            //����hsync�ź�
       else if(x_cnt == H_SyncPulse) hsync_r <= 1'b1;
		 
		 		 
	    if(~rst_n) hsync_de <= 1'b0;
       else if(x_cnt == Hde_start) hsync_de <= 1'b1;    //����hsync_de�ź�
       else if(x_cnt == Hde_end) hsync_de <= 1'b0;	
	end

//----------------------------------------------------------------
////////// ��ֱɨ�����
//----------------------------------------------------------------
always @ (posedge vga_clk)
       if(~rst_n) y_cnt <= 1;
       else if(y_cnt == FramePeriod) y_cnt <= 1;
       else if(x_cnt == LinePeriod) y_cnt <= y_cnt+1;

//----------------------------------------------------------------
////////// ��ֱɨ���ź�vsync, vsync_de����
//----------------------------------------------------------------
always @ (posedge vga_clk)
  begin
       if(~rst_n) vsync_r <= 1'b1;
       else if(y_cnt == 1) vsync_r <= 1'b0;    //����vsync�ź�
       else if(y_cnt == V_SyncPulse) vsync_r <= 1'b1;
		 
	    if(~rst_n) vsync_de <= 1'b0;
       else if(y_cnt == Vde_start) vsync_de <= 1'b1;    //����vsync_de�ź�
       else if(y_cnt == Vde_end) vsync_de <= 1'b0;	 
  end
		 

//----------------------------------------------------------------
////////// ���Ӳ���ͼ�����
//----------------------------------------------------------------
 always @(negedge vga_clk)   
   begin
     if ((x_cnt[4]==1'b1) ^ (y_cnt[4]==1'b1))            //��������1ͼ��
			    grid_data_1<= 24'h000000;
	  else
			    grid_data_1<= 24'hffffff;
				 
	  if ((x_cnt[6]==1'b1) ^ (y_cnt[6]==1'b1))            //��������2ͼ�� 
			    grid_data_2<=24'h000000;
	  else
				 grid_data_2<=24'hffffff; 
   
	end
	
//----------------------------------------------------------------
////////// ��ɫ������ͼ�����
//----------------------------------------------------------------
 always @(negedge vga_clk)   
   begin
     if (x_cnt==Hde_start)            
			    bar_data<=24'hff0000;              //��ɫ����
	  else if (x_cnt==Hde_start + bar_interval)
			    bar_data<=24'h00ff00;              //��ɫ����				 
	  else if (x_cnt==Hde_start + bar_interval*2)            
			    bar_data<=24'h0000ff;               //��ɫ����
	  else if (x_cnt==Hde_start + bar_interval*3)         
			    bar_data<=24'hff00ff;               //��ɫ����
	  else if (x_cnt==Hde_start + bar_interval*4)           
			    bar_data<=24'hffff00;               //��ɫ����
	  else if (x_cnt==Hde_start + bar_interval*5)            
			    bar_data<=24'h00ffff;               //��ɫ����
	  else if (x_cnt==Hde_start + bar_interval*6)             
			    bar_data<=24'hffffff;               //��ɫ����
	  else if (x_cnt==Hde_start + bar_interval*7)            
			    bar_data<=24'h000000;               //��ɫ����
	  else if (x_cnt==Hde_start + bar_interval*8)              
			    bar_data<=24'h000000;               //�����ɫ
   
	end
	
//----------------------------------------------------------------
////////// VGAͼ��ѡ�����
//----------------------------------------------------------------
 //LCD�����ź�ѡ�� 
 always @(negedge vga_clk)  
    if(~rst_n) begin 
	    vga_r_reg<=0; 
	    vga_g_reg<=0;
	    vga_b_reg<=0;		 
	end
   else
     case(vga_dis_mode)
         4'b0000:begin
			     vga_r_reg<=0;                        //VGA��ʾȫ��
                 vga_g_reg<=0;
                 vga_b_reg<=0;
			end
			4'b0001:begin
			     vga_r_reg<=8'b11111111;                 //VGA��ʾȫ��
                 vga_g_reg<=8'b11111111;
                 vga_b_reg<=8'b11111111;
			end
			4'b0010:begin
			     vga_r_reg<=8'b11111111;                //VGA��ʾȫ��
                 vga_g_reg<=0;
                 vga_b_reg<=0;  
         end			  
	      4'b0011:begin
			     vga_r_reg<=0;                      //VGA��ʾȫ��
                 vga_g_reg<=8'b11111111;
                 vga_b_reg<=0; 
         end					  
         4'b0100:begin     
			     vga_r_reg<=0;                      //VGA��ʾȫ��
                 vga_g_reg<=0;
                 vga_b_reg<=8'b11111111;
			end
         4'b0101:begin     
			     vga_r_reg<=grid_data_1[23:16];     // VGA��ʾ����1
                 vga_g_reg<=grid_data_1[15:8];
                 vga_b_reg<=grid_data_1[7:0];
         end					  
         4'b0110:begin     
			     vga_r_reg<=grid_data_2[23:16];    // VGA��ʾ����2
                 vga_g_reg<=grid_data_2[15:8];
                 vga_b_reg<=grid_data_2[7:0];
			end
		   4'b0111:begin     
			     vga_r_reg<=x_cnt[7:0];            //VGA��ʾˮƽ����ɫ
                 vga_g_reg<=x_cnt[7:0];
                 vga_b_reg<=x_cnt[7:0];
			end
		   4'b1000:begin     
			     vga_r_reg<=y_cnt[7:0];            //VGA��ʾ��ֱ����ɫ
                 vga_g_reg<=y_cnt[7:0];
                 vga_b_reg<=y_cnt[7:0];
			end
		   4'b1001:begin     
			     vga_r_reg<=x_cnt[7:0];            //VGA��ʾ��ˮƽ����ɫ
                 vga_g_reg<=0;
                 vga_b_reg<=0;
			end
		   4'b1010:begin     
			     vga_r_reg<=0;                     //VGA��ʾ��ˮƽ����ɫ
                 vga_g_reg<=x_cnt[7:0];
                 vga_b_reg<=0;
			end
		   4'b1011:begin     
			     vga_r_reg<=0;                            //VGA��ʾ��ˮƽ����ɫ
                 vga_g_reg<=0;
                 vga_b_reg<=x_cnt[7:0];			
			end
		   4'b1100:begin     
			     vga_r_reg<=bar_data[23:16];              //VGA��ʾ��ɫ��
                 vga_g_reg<=bar_data[15:8];
                 vga_b_reg<=bar_data[7:0];			
			end
		   default:begin
			     vga_r_reg<=8'b11111111;                 //VGA��ʾȫ��
                 vga_g_reg<=8'b11111111;
                 vga_b_reg<=8'b11111111;
			end					  
         endcase;
	
  assign vga_hs = hsync_r;
  assign vga_vs = vsync_r;  
  assign vga_r = (hsync_de & vsync_de)?vga_r_reg:8'b00000000;
  assign vga_g = (hsync_de & vsync_de)?vga_g_reg:8'b00000000;
  assign vga_b = (hsync_de & vsync_de)?vga_b_reg:8'b00000000;
  assign vga_clk = CLK_OUT3;  //VGAʱ��Ƶ��ѡ��65Mhz
  assign vga_en = hsync_de & vsync_de;
  
    
   pll pll_inst
  (// Clock in ports
   .clk_in1(sys_clk_ibufg),      // IN
   .clk_out1(CLK_OUT1),     // 21.175Mhz for 640x480(60hz)
   .clk_out2(CLK_OUT2),     // 40.0Mhz for 800x600(60hz)
   .clk_out3(CLK_OUT3),     // 65.0Mhz for 1024x768(60hz)
   .clk_out4(CLK_OUT4),     // 108.0Mhz for 1280x1024(60hz)
   .reset(0),               // reset input 
   .locked(LOCKED));        // OUT
// INST_TAG_END ------ End INSTANTIATI

 //��ť�������	
  always @(posedge vga_clk)
	  begin
	    if (key1==1'b0)                               //�����ťû�а��£��Ĵ���Ϊ0
	       key1_counter<=0;
	    else if ((key1==1'b1)& (key1_counter<=16'hc350))      //�����ť���²�����ʱ������1ms,����      
          key1_counter<=key1_counter+1'b1;
  	  
       if (key1_counter==16'hc349)                //һ�ΰ�ť��Ч���ı���ʾģʽ
		    begin
		      if(vga_dis_mode==4'b1101)
			      vga_dis_mode<=4'b0000;
			   else
			      vga_dis_mode<=vga_dis_mode+1'b1; 
          end	
     end			 
	  

endmodule
