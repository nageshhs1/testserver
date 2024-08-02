#!/bin/sh 

#load
. ../../cfg/ppa_auto_env
. ../../cfg/ppa_auto_testcase_env
. ../../cfg/ppa_auto_env_setup

delay=1;

#Parameters used to get the version file from CPE
	tmp_cpe_file="/tmp/ifconfig_data_for_reset"
	local_version_file="/tmp/ifconfig_data_for_reset_dup"
	tmp_interface=$ppa_auto_if_cpe


get_ipv4_cpe_address_settings()
{
	if [ -f $local_version_file ]; then
	    rm -f $local_version_file
	fi

	touch $local_version_file 
	$ppa_auto_tool -i $tmp_interface -n $ppa_auto_name -t cpe -c cmd -s "rm $tmp_cpe_file"	

	cmd="ifconfig > $tmp_cpe_file"
	$ppa_auto_tool -i $tmp_interface -n $ppa_auto_name -t cpe -c cmd -s "$cmd"

	$ppa_auto_tool -i $tmp_interface -n $ppa_auto_name -t cpe -c get -s $tmp_cpe_file -d $local_version_file
}

get_ipv6_address_cpe_settings()
{
	if [ -f $local_version_file ]; then
	    rm -f $local_version_file
	fi

	touch $local_version_file 
	$ppa_auto_tool -i $tmp_interface -n $ppa_auto_name -t cpe -c cmd -s "rm $tmp_cpe_file"	

	cmd="ip -6 addr show > $tmp_cpe_file"
	$ppa_auto_tool -i $tmp_interface -n $ppa_auto_name -t cpe -c cmd -s "$cmd"

	$ppa_auto_tool -i $tmp_interface -n $ppa_auto_name -t cpe -c get -s $tmp_cpe_file -d $local_version_file
}

cpe_setting_reset_ipv4()
{
	get_ipv4_cpe_address_settings
	#[ -e $ppa_auto_tool_retcode_file  ] && return
	echo "IPV4 Address reset - CPE"

	FILE=$local_version_file
	BAKIFS=$IFS
	exec 3<&0
	exec 0<"$FILE"
	while read -r line
	do
		check=$(echo $line | grep "Link encap:")	
		if [ "$check" != "" ];then
			Interface_line=$check
			interface=$(echo $Interface_line | awk '{ print $1 }')
			ppa_echo "ifconfig $interface 0.0.0.0 ---> CPE"
			cmd="ifconfig $interface 0.0.0.0 > $tmp_cpe_file"
			$ppa_auto_tool -i $tmp_interface -n $ppa_auto_name -t cpe -c cmd -s "$cmd" -d $local_version_file
			[ -e $ppa_auto_tool_retcode_file  ] && return
		fi
	done
	exec 0<&3
	IFS=$BAKIFS

	interface_gre="gre$ppa_auto_name"
	#echo "ip tunnel del $interface_gre"
	cmd="ip tunnel del $interface_gre > /dev/null 2>&1"
	#echo "$ppa_auto_tool -i $tmp_interface -n $ppa_auto_name -t cpe -c cmd -s "$cmd""
	$ppa_auto_tool -i $tmp_interface -n $ppa_auto_name -t cpe -c cmd -s "$cmd"

	interface_gre="gre$ppa_auto_name"
	#echo "ip link del $interface_gre"
	cmd="ip link del $interface_gre > /dev/null 2>&1"
	#echo "$ppa_auto_tool -i $tmp_interface -n $ppa_auto_name -t cpe -c cmd -s "$cmd""
	$ppa_auto_tool -i $tmp_interface -n $ppa_auto_name -t cpe -c cmd -s "$cmd"
}

cpe_setting_reset_ipv6()
{
	get_ipv6_address_cpe_settings
#	[ -e $ppa_auto_tool_retcode_file  ] && return

	ppa_echo ""
	echo "IPV6 Address reset - CPE"

	FILE=$local_version_file
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

			#echo "ip -6 addr del $address dev $interface ---> CPE"
			cmd="ip -6 addr del $address dev $interface > $tmp_cpe_file"
			$ppa_auto_tool -i $tmp_interface -n $ppa_auto_name -t cpe -c cmd -s "$cmd" -d $local_version_file
			[ -e $ppa_auto_tool_retcode_file  ] && return
			#sleep 1
		fi
	done
	exec 0<&3
	IFS=$BAKIFS

#tunnel 6rd delete
			interface_6rd="6rd_$ppa_auto_name"
			#echo "ip tunnel del $interface_6rd"
			cmd="ip tunnel del $interface_6rd"
			$ppa_auto_tool -i $tmp_interface -n $ppa_auto_name -t cpe -c cmd -s "$cmd" -g $ppa_auto_debug
			[ -e $ppa_auto_tool_retcode_file  ] && return
#tunnel 6rd delete 
			interface_dslite="dslite_$ppa_auto_name"
			#echo "ip tunnel del $interface_dslite"
			cmd="ip tunnel del $interface_dslite"
			$ppa_auto_tool -i $tmp_interface -n $ppa_auto_name -t cpe -c cmd -s "$cmd" -g $ppa_auto_debug
			[ -e $ppa_auto_tool_retcode_file  ] && return


	interface_gre="gre$ppa_auto_name"
	#echo "ip -6 tunnel del $interface_gre"
	cmd="ip -6 tunnel del $interface_gre > /dev/null 2>&1"
	#echo "$ppa_auto_tool -i $tmp_interface -n $ppa_auto_name -t cpe -c cmd -s "$cmd" -d $local_version_file"
	$ppa_auto_tool -i $tmp_interface -n $ppa_auto_name -t cpe -c cmd -s "$cmd" -d $local_version_file

	interface_gre="gre$ppa_auto_name"
	#echo "ip -6 link del $interface_gre"
	cmd="ip -6 link del $interface_gre > /dev/null 2>&1"
	#echo "$ppa_auto_tool -i $tmp_interface -n $ppa_auto_name -t cpe -c cmd -s "$cmd" -d $local_version_file"
	$ppa_auto_tool -i $tmp_interface -n $ppa_auto_name -t cpe -c cmd -s "$cmd" -d $local_version_file

}


Reset_Automation_settings()
{
	echo ""
	echo "Reset Script Start - CPE"
	download_file "../../cfg/brctl_setup" "/var/t.sh"	
	$ppa_auto_tool -i $tmp_interface -n $ppa_auto_name -t cpe -c run -s /var/t.sh
	#echo "-----press ENTER for Reset_Automation_settings )"
	#read key

	cpe_setting_reset_ipv6	
	cpe_setting_reset_ipv4
	cmd="killall pppd > /dev/null 2>&1"
	#echo "$ppa_auto_tool -i $tmp_interface -n $ppa_auto_name -t cpe -c cmd -s "$cmd""
	$ppa_auto_tool -i $tmp_interface -n $ppa_auto_name -t cpe -c cmd -s "$cmd" -g $ppa_auto_debug

	cmd="vconfig rem $phy_wan_ifname0.$wan_vlan2_id 2>&1"
	#echo "$ppa_auto_tool -i $tmp_interface -n $ppa_auto_name -t cpe -c cmd -s "$cmd""
	$ppa_auto_tool -i $tmp_interface -n $ppa_auto_name -t cpe -c cmd -s "$cmd" -g $ppa_auto_debug

	cmd="vconfig rem $phy_lan_ifname0.$lan_vlan1 2>&1"
#	echo "$ppa_auto_tool -i $tmp_interface -n $ppa_auto_name -t cpe -c cmd -s "$cmd""
	$ppa_auto_tool -i $tmp_interface -n $ppa_auto_name -t cpe -c cmd -s "$cmd" -g $ppa_auto_debug
         cmd="vconfig rem $phy_lan_ifname1.$lan_vlan2 2>&1"
#       echo "$ppa_auto_tool -i $tmp_interface -n $ppa_auto_name -t cpe -c cmd -s "$cmd""
        $ppa_auto_tool -i $tmp_interface -n $ppa_auto_name -t cpe -c cmd -s "$cmd" -g $ppa_auto_debug

	echo "Reset Script Finish - CPE"
	download_file "../../cfg_current/cpe_env_global" "/var/cpe_env_global"
	download_file "cpe/cpe_env" "/var/cpe_env"
exit 0
}

Reset_Automation_settings


