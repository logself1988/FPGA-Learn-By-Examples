set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
############## clock define##################
create_clock -period 5 [get_ports sys_clk_p]
set_property PACKAGE_PIN R4 [get_ports sys_clk_p]
set_property IOSTANDARD DIFF_SSTL15 [get_ports sys_clk_p]

##############reset key define##################

############## usb uart define##################
set_property IOSTANDARD LVCMOS33 [get_ports uart1_rx]
set_property PACKAGE_PIN Y12 [get_ports uart1_rx]

set_property IOSTANDARD LVCMOS33 [get_ports uart1_tx]
set_property PACKAGE_PIN Y11 [get_ports uart1_tx]
