#!/bin/sh 

#load
. ../../cfg/ppa_auto_env
. ../../cfg/ppa_auto_env_setup

#Parameters used to get the version file from CPE
	ppa_auto_tool="../../bin/ppa_auto_tool"
	tmp_cpe_file="/tmp/ifconfig_data_for_reset"
	local_version_file="/tmp/ifconfig_data_for_reset"
	tmp_interface=$ppa_auto_if_cpe



lan_setting_reset_ipv6()
{
	sudo rm tmp1
	ip -6 addr show > tmp1

	ppa_echo "IPV6 Address reset - LAN"
	FILE=tmp1
	BAKIFS=$IFS
	exec 3<&0
	exec 0<"$FILE"
	while read -r line
	do
		check=$(echo $line | grep ": <")	
		if [ "$check" != "" ];then
			Interface_line=$check
		fi

		check=$(echo $line | grep "inet6 200")	
		if [ "$check" != "" ];then

			address_line=$check
			interface=$(echo $Interface_line | awk -F[\":] '{ print $2 }')
			address=$(echo $address_line | awk '{ print $2 }')

			check=$(echo $interface | grep "@")	
			if [ "$check" != "" ];then
				interface=$(echo $interface | sed -e "s/\@.*//g" )
			fi

			ppa_echo "ip -6 addr del $address dev $interface --> LAN"
			ip -6 addr del $address dev $interface
			sleep 1
		fi
	done
	exec 0<&3
	IFS=$BAKIFS

	ppa_echo "IPV6 Route reset - LAN"
	sudo rm tmp1
	ip -6 route show > tmp1
	FILE=tmp1
	BAKIFS=$IFS
	exec 3<&0
	exec 0<"$FILE"
	while read -r line
	do
		check=$(echo $line | grep ": <")	
		if [ "$check" != "" ];then
			Interface_line=$check
		fi

		check=$(echo $line | grep "200")
		check1=$(echo $line | grep "via")
	
		if [ "$check" != "" ] && [ "$check1" != "" ];then

			address_line=$check
			interface=$(echo $address_line | awk '{ print $5 }')
			address1=$(echo $address_line | awk '{ print $1 }')
			address2=$(echo $address_line | awk '{ print $3 }')

			ppa_echo "ip -6 route del $address1/128 dev $interface via $address2 --- LAN"
			ip -6 route del $address1/128 dev $interface via $address2
			sleep 1
		fi
	done
	exec 0<&3
	IFS=$BAKIFS
}

lan_setting_reset_ipv4()
{
	sudo rm tmp1
	ifconfig > tmp1
	ppa_echo "IPV4 Address reset - LAN"
	FILE=tmp1
	BAKIFS=$IFS
	exec 3<&0
	exec 0<"$FILE"
	while read -r line
	do
		check=$(echo $line | grep "Link encap:")	
		if [ "$check" != "" ];then
			Interface_line=$check
			interface=$(echo $Interface_line | awk '{ print $1 }')

			check=$(echo $interface | grep "$ppa_auto_if_cpe")
			if [ "$check" != "" ];then
				ppa_echo "sudo ifconfig $interface 0.0.0.0 ---> LAN"
				sudo ifconfig $interface 0.0.0.0
			fi
		fi
	done
	exec 0<&3
	IFS=$BAKIFS

	ppa_echo "IPV4 Route reset - LAN"
	sudo rm tmp1
	route -n > tmp1
	FILE=tmp1
	BAKIFS=$IFS
	exec 3<&0
	exec 0<"$FILE"
	while read -r line
	do
		check=$(echo $line | grep "$ppa_auto_if_cpe")	
		if [ "$check" != "" ];then
			Interface_line=$check
			check=$(echo $Interface_line | grep "UG")	
			if [ "$check" != "" ];then
				address1=$(echo $Interface_line | awk '{ print $1 }')
				address2=$(echo $Interface_line | awk '{ print $2 }')
				NetMask=$(echo $Interface_line | awk '{ print $3 }')
				ppa_echo "sudo route del -net $address1 netmask $NetMask gw $address2 ---> LAN"
				sudo route del -net $address1 netmask $NetMask gw $address2
			fi
		fi
	done
	exec 0<&3
	IFS=$BAKIFS
}

Reset_Automation_settings()
{
	ppa_echo ""
	ppa_echo "Reset Script Start - LAN"
	lan_setting_reset_ipv6
	lan_setting_reset_ipv4
	vconfig rem $ppa_auto_if_cpe.$lan_vlan1_multi
        vconfig rem $ppa_auto_if_cpe.$lan_vlan2_multi
	ppa_echo "Reset Script Finish - LAN"
	ppa_echo ""
}

Reset_Automation_settings



