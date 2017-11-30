-makelib ies/xil_defaultlib -sv \
  "D:/Xilinx/Vivado/2016.4/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
-endlib
-makelib ies/xpm \
  "D:/Xilinx/Vivado/2016.4/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies/xil_defaultlib \
  "../../../../vga_test.srcs/sources_1/ip/pll/pll_clk_wiz.v" \
  "../../../../vga_test.srcs/sources_1/ip/pll/pll.v" \
-endlib
-makelib ies/xil_defaultlib \
  glbl.v
-endlib

