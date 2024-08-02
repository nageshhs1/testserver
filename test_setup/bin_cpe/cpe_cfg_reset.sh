#remove br-lan which set by UGW itself. 
#in this automation test, it is using br0
flag=$(brctl show | grep br-lan)
if [ "$flag" != "" ]; then   
	ifconfig rtlog0 down
	brctl delif br-lan rtlog0
	brctl delif br-lan wlan0
	ifconfig br-lan down
	brctl delbr br-lan
fi

