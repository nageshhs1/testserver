#!/bin/sh 

#load
. ../../cfg/ppa_auto_env
. ../../cfg/ppa_auto_env_setup

#Parameters used to get the version file from CPE
	ppa_auto_tool="../../bin/ppa_auto_tool"
	tmp_ifconfig_data_for_wan_reset="/tmp/ifconfig_data_for_wan_reset_$ppa_auto_name"
	local_wan_reset_file="/tmp/ifconfig_data_for_wan_reset"
	tmp_interface=$ppa_auto_if_cpe
	mode=""
	server_id=""



remove_ipv6_wan_routing_and_neigh_table()
{
	line="$@"
	ip_cmd=""

	check=$( echo $line | awk '{print $1}')
	var1=$check 
	var2=$lan_ip

	if echo $var1 | grep -i "^${var2}$" > /dev/null ; then
	ppa_echo "$line"
	Target_ip=$( echo $line | awk '{print $1}')
	Via_Gateway=$( echo $line | awk '{print $3}')
	Interface=$( echo $line | awk '{print $5}')

	if [ "$server_id" == "2" ];then
		ip_cmd="/ppa_server2_cfg/ip"
	else
		ip_cmd="ip"
	fi
		ppa_echo "ip -6 route del $Target_ip/128 dev $Interface via $Via_Gateway"
		cmd="$ip_cmd -6 route del $Target_ip/128 dev $Interface via $Via_Gateway > /dev/null 2>&1"
		ppa_echo "$ppa_auto_tool -i $ppa_auto_if_wan -n $ppa_auto_name -t $mode -c cmd -s "$cmd" -r $server_id"
		$ppa_auto_tool -i $ppa_auto_if_wan -n $ppa_auto_name -t $mode -c cmd -s "$cmd" -r $server_id
#incase of pppoe
		ppa_echo "ip -6 route del $Target_ip/128 via $Via_Gateway"
		cmd="$ip_cmd -6 route del $Target_ip/128 via $Via_Gateway > /dev/null 2>&1"
		ppa_echo "$ppa_auto_tool -i $ppa_auto_if_wan -n $ppa_auto_name -t $mode -c cmd -s "$cmd" -r $server_id"
		$ppa_auto_tool -i $ppa_auto_if_wan -n $ppa_auto_name -t $mode -c cmd -s "$cmd" -r $server_id
#delete neigh table

		ppa_echo "ip -6 neigh del $Via_Gateway dev $Interface"
		cmd="$ip_cmd -6 neigh del $Via_Gateway dev $Interface > /dev/null 2>&1"
		ppa_echo "$ppa_auto_tool -i $ppa_auto_if_wan -n $ppa_auto_name -t $mode -c cmd -s "$cmd" -r $server_id"
		$ppa_auto_tool -i $ppa_auto_if_wan -n $ppa_auto_name -t $mode -c cmd -s "$cmd" -r $server_id

	fi


}


wan_setting_reset_ipv6()
{
	touch $local_wan_reset_file	
	$ppa_auto_tool -i $ppa_auto_if_wan -n $ppa_auto_name -t $mode -c cmd -s "rm $tmp_ifconfig_data_for_wan_reset" -r $server_id
	if [ "$server_id" == "2" ];then
		cmd="/ppa_server2_cfg/ip -6 route show > $tmp_ifconfig_data_for_wan_reset"
	else
		cmd="ip -6 route show > $tmp_ifconfig_data_for_wan_reset"
	fi
	$ppa_auto_tool -i $ppa_auto_if_wan -n $ppa_auto_name -t $mode -c cmd -s "$cmd" -d $local_wan_reset_file -r $server_id 
	$ppa_auto_tool -i $ppa_auto_if_wan -n $ppa_auto_name -t $mode -c get -s $tmp_ifconfig_data_for_wan_reset -d $local_wan_reset_file -r $server_id

	FILE=$local_wan_reset_file
	BAKIFS=$IFS
	exec 3<&0
	exec 0<"$FILE"
	colum=$set;
	while read -r line
	do
		remove_ipv6_wan_routing_and_neigh_table $line
	done
	exec 0<&3
	IFS=$BAKIFS

#tunnel 6rd delete

		#echo "ip tunnel del $Tunnel_Dev_6rd_Name"
		cmd="ip tunnel del $Tunnel_Dev_6rd_Name > /dev/null 2>&1"
		#echo "$ppa_auto_tool -i $ppa_auto_if_wan -n $ppa_auto_name -t $mode -c cmd -s "$cmd" -r $server_id"
		$ppa_auto_tool -i $ppa_auto_if_wan -n $ppa_auto_name -t $mode -c cmd -s "$cmd" -r $server_id

#tunnel dslite delete

		ppa_echo "ip -6 tunnel del $Tunnel_Dev_dslite_Name"
		cmd="ip -6 tunnel del $Tunnel_Dev_dslite_Name > /dev/null 2>&1"
		ppa_echo "$ppa_auto_tool -i $ppa_auto_if_wan -n $ppa_auto_name -t $mode -c cmd -s "$cmd" -r $server_id"
		$ppa_auto_tool -i $ppa_auto_if_wan -n $ppa_auto_name -t $mode -c cmd -s "$cmd" -r $server_id

		interface_gre="test_gre$ppa_auto_name"
		ppa_echo "ip -6 tunnel del $interface_gre"
		cmd="ip -6 tunnel del $interface_gre > /dev/null 2>&1"
		ppa_echo "$ppa_auto_tool -i $ppa_auto_if_wan -n $ppa_auto_name -t $mode -c cmd -s "$cmd" -r $server_id"
		$ppa_auto_tool -i $ppa_auto_if_wan -n $ppa_auto_name -t $mode -c cmd -s "$cmd" -r $server_id

		interface_gre="test_gre$ppa_auto_name"
		ppa_echo "ip -6 link del $interface_gre"
		cmd="ip -6 link del $interface_gre > /dev/null 2>&1"
		ppa_echo "$ppa_auto_tool -i $ppa_auto_if_wan -n $ppa_auto_name -t $mode -c cmd -s "$cmd" -r $server_id"
		$ppa_auto_tool -i $ppa_auto_if_wan -n $ppa_auto_name -t $mode -c cmd -s "$cmd" -r $server_id


	rm $local_wan_reset_file	
}


wan_setting_reset_ipv4()
{
	#currently used to reset dslite test case wan ipv4 routeing settings
	ppa_echo "IPV4 Route reset - WAN"
	ppa_echo "route del -net $cpe_lan_subnet netmask $wan_subnet_basic_mask" 
	cmd="route del -net $cpe_lan_subnet netmask $wan_subnet_basic_mask > /dev/null 2>&1"
	$ppa_auto_tool -i $ppa_auto_if_wan -n $ppa_auto_name -t $mode -c cmd -s "$cmd" -r $server_id 

	interface_gre="test_gre_$ppa_auto_name"
	ppa_echo "ip tunnel del $interface_gre"
	cmd="ip tunnel del $interface_gre > /dev/null 2>&1"
	ppa_echo "$ppa_auto_tool -i $ppa_auto_if_wan -n $ppa_auto_name -t $mode -c cmd -s "$cmd" -r $server_id"
	$ppa_auto_tool -i $ppa_auto_if_wan -n $ppa_auto_name -t $mode -c cmd -s "$cmd" -r $server_id

	interface_gre="test_gre_$ppa_auto_name"
	ppa_echo "ip link del $interface_gre"
	cmd="ip link del $interface_gre > /dev/null 2>&1"
	ppa_echo "$ppa_auto_tool -i $ppa_auto_if_wan -n $ppa_auto_name -t $mode -c cmd -s "$cmd" -r $server_id"
	$ppa_auto_tool -i $ppa_auto_if_wan -n $ppa_auto_name -t $mode -c cmd -s "$cmd" -r $server_id
}


Reset_Automation_settings()
{
	server_id=$1

	if [ "$server_id" == "" ];then
		server_id=0;
		mode="wan"
	else
		mode="cpe"		#work around for ppa_wan_proxy server 2
	fi

	echo "Wan Reset: Server_id = $server_id mode = $mode"
	cmd="killall mc_sender > /dev/null 2>&1"
	$ppa_auto_tool -i $ppa_auto_if_wan -n $ppa_auto_name -t $mode -c cmd -s "$cmd" -r $server_id 
	cmd="killall mc_sender6 > /dev/null 2>&1"
	$ppa_auto_tool -i $ppa_auto_if_wan -n $ppa_auto_name -t $mode -c cmd -s "$cmd" -r $server_id 

	wan_setting_reset_ipv6
	wan_setting_reset_ipv4
	ppa_echo ""
}

Reset_Automation_settings $1

