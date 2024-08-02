#Variables to be in Topo
# Flag Value 1 is ON and Flag Value 0 is OFF
set chassisIp 10.226.44.148
set UdpstartingPort 1023
set LANMACPrefix 00:10:94:00:00:1
set WANMACPrefix 00:10:95:00:00:2
set Start_LANIP_Prefix 192.168.1.1
set Start_WANIP_Prefix 192.168.2.1
set LANGatewayIP 192.168.1.1
set WANGatewayIP 192.168.2.1




#Newly added: 
set runTime 50
set resolution 0.005
set Load_min 0.0
set Load_max 100.0 
set frameLength 1024
set Load 100.0 


#Flag: 
set show_cfg 0
set bi 0
#Flag bit to print Detailed Log information in Transmit script.
#We can use it for only Debug purpose 
set print_result 0

