#load
. ../cfg/ppa_auto_env
. ../cfg/ppa_auto_env_setup
. ../cfg/ppa_auto_testcase_env
. ../cfg/getopt.sh
. ../cfg/log_report.sh

ppa_aut_env_setup_file="../cfg/ppa_auto_env_setup"
ppa_co_setup_file="../cfg/ppa_co_env_setup"
testlink=../Auto 
status_file=../web_gui/cgi-bin/auto_log/status.txt

curr_start_time=`date +%s`
#Logic use
	set=1
	unset=0
	delay=2
	cpe_ready=0;
    #dsl_wan=1;
    #dsl_link_status=0

#Path to config file path in PC
	conf_file_path="../cfg/cpe_env_global"

#Parameters used to get the version file from CPE
	ppa_auto_tool="../bin/ppa_auto_tool"
	tmp_cpe_file="/tmp/ppa_version"
	tmp_interface=$ppa_auto_if_cpe
	local_version_file="${global_ppa_version_file}"  #changed
	telnet_expect_file="../bin/telnet.expect"
	serialport_read_write="sudo perl ../bin/addmisc_extract.pl" export serialport_read_write


#Parameters used to parse the version file -> find_and_set()
	FIRMWAREFAMILY=""
    
#local tmp folder in LAN server    
    tmp_folder="tmp_log"
    local_tmp_file=$tmp_folder/tmp_dsl.log
    [ ! -e $tmp_folder ] && mkdir $tmp_folder
	
cpe_ready_ping_times=5


generate_html_test_report_wit_tmp_htm()
{
	echo "This function inside start.sh stores running testcases only"
	#date_time=`date`
	#Value=$(echo $date_time | sed -e "s/\ /-/g")
	Value=$(date +%Y%m%d"_"%H%M%S)
	Test_Report_Header="Test_Report_"$Value	 
	root_path=`pwd`
	dir_log=$root_path"/HTML_test_report/"
	test_report_file=$dir_log$Test_Report_Header".html"	
	if test -d $dir_log
	then
		sudo rm $dir_log"*"			
		echo "tmp Test Result log directory Exist"
	else
		mkdir $dir_log
	fi

	cp $ppa_auto_tmp_result_log $test_report_file
	echo "</table>" >> $test_report_file	
	echo "</body>" >> $test_report_file
	echo "</html>" >> $test_report_file		
}

check_dsl_link()
{  
   dsl_link_wait_time=200
   dsl_link_status=0;
   #if [ ! $dsl_wan -eq 0 ]; then  
        echo "DSL LINK CHECK"
        i="0"
        while [ $i -lt $dsl_link_wait_time ]
        do 
            i=$(( $i+1 ))
            #get dsl link status from cpe
            $ppa_auto_tool -i $tmp_interface -n $ppa_auto_name -t cpe -c cmd -s "/opt/lantiq/bin/dsl_cpe_pipe.sh lsg > $tmp_cpe_file" 
            #sleep 1	            
            $ppa_auto_tool -i $tmp_interface -n $ppa_auto_name -t cpe -c get -s $tmp_cpe_file -d $local_tmp_file
            #echo "DSL LINK file: $local_tmp_file" 
            #cat $local_tmp_file
            dsl_link_str=`cat $local_tmp_file | grep 801`
            if [ "$dsl_link_str" != "" ]; then               
               echo "DSL SHOWTIME"
               dsl_link_status=1
               break #return
            else
               echo "No DSL link (try=$i): `cat $local_tmp_file`"
               
            fi
        done
   #else 
   #    return
   #fi 
   [ $dsl_link_status -eq 1 ] && return
   dsl_link_status=0

   echo ""
   echo -----------------------------------------------------------
   echo "No DSL LINK. Please check Cable connections or CPE Status!"    
   echo -----------------------------------------------------------
   echo ""
   exit $s_dsl_failed

}

	
detect_cpe_ready()
{
	#In case the script is running for second time in this running DUT
	cmd="ifconfig br0 $cpe_default_ip up"
	ppa_echo "$ppa_auto_tool -i $tmp_interface -n $ppa_auto_name -t cpe -c cmd -s "$cmd""
	$ppa_auto_tool -i $tmp_interface -n $ppa_auto_name -t cpe -c cmd -s "$cmd"
	[ $? -eq 0 ] && cpe_ready=1
}

generate_telnet_expect_file()
{

	path_d=../bin/telnet.expect	
	rm $path_d
	echo "#!/usr/local/bin/expect" >>  $path_d
	echo "spawn telnet $cpe_default_ip" >>  $path_d
	echo "expect \"'^]'.\"" >>  $path_d 
	echo "expect \"login:\"" >>  $path_d 
	echo "send \"root\\n\""  >>  $path_d
	echo "expect \"Password:\"" >>  $path_d 
	echo "send \"admin\\n\"" >>  $path_d 
	echo "expect \"#\"" >>  $path_d
	echo "send \"killall ppa_auto_proxy_cpe \\n\"" >>  $path_d
	echo "expect \"#\"" >>  $path_d
	# tftp ppa_auto_proxy_cpe from LAN PC to CPE
	#
	echo "send \"tftp -gr ppa_auto_proxy_cpe -l /tmp/ppa_auto_proxy_cpe $lan_tmp_ip\\n\"" >>  $path_d
	echo "expect \"#\"" >>  $path_d
	echo "send \"chmod a+x /tmp/ppa_auto_proxy_cpe\\n\"" >>  $path_d
	echo "expect \"#\"" >>  $path_d
    	echo "send \"insmod /lib/modules/*.*/tunnel6.ko\\n\"" >>  $path_d
	echo "expect \"#\"" >>  $path_d
    	echo "send \"insmod /lib/modules/*.*/tunnel4.ko\\n\"" >>  $path_d
	echo "expect \"#\"" >>  $path_d
	echo "send \"insmod /lib/modules/*.*/ip_tunnel.ko\\n\"" >>  $path_d
	echo "expect \"#\"" >>  $path_d
    	echo "send \"insmod /lib/modules/*.*/ip6_tunnel.ko\\n\"" >>  $path_d
	echo "expect \"#\"" >>  $path_d
    	echo "send \"insmod /lib/modules/*.*/ip4_tunnel.ko\\n\"" >>  $path_d
	echo "expect \"#\"" >>  $path_d
	echo "send \"insmod /lib/modules/*.*/sit.ko\\n\"" >>  $path_d
	echo "expect \"#\"" >>  $path_d
    	echo "send \"insmod /lib/modules/*.*/gre.ko\\n\"" >>  $path_d
	echo "expect \"#\"" >>  $path_d
    	echo "send \"insmod /lib/modules/*.*/ip_gre.ko\\n\"" >>  $path_d
	echo "expect \"#\"" >>  $path_d
        echo "send \"insmod /lib/modules/*.*/ip6_gre.ko\\n\"" >>  $path_d
	echo "expect \"#\"" >>  $path_d
	echo "send \"/tmp/ppa_auto_proxy_cpe -i eth0_1 -n $ppa_auto_name > /dev/null 2>&1 & \\n\"" >>  $path_d
	echo "expect \"#\"" >>  $path_d
	echo "send \"/tmp/ppa_auto_proxy_cpe -i eth0_2 -n $ppa_auto_name > /dev/null 2>&1 & \\n\"" >>  $path_d
	echo "expect \"#\"" >>  $path_d
	echo "send \"/tmp/ppa_auto_proxy_cpe -i eth0_3 -n $ppa_auto_name > /dev/null 2>&1 & \\n\"" >>  $path_d
	echo "expect \"#\"" >>  $path_d
	echo "send \"/tmp/ppa_auto_proxy_cpe -i eth0_4 -n $ppa_auto_name > /dev/null 2>&1 & \\n\"" >>  $path_d
	echo "expect \"#\"" >>  $path_d
	echo "send \"mkdir /var/run/xl2tpd\\n\"" >>  $path_d
	echo "expect \"#\"" >>  $path_d
	echo "send \"mkdir /tmp/xl2tpd\\n\"" >>  $path_d
	echo "expect \"#\"" >>  $path_d
	echo "send \"cd /tmp/xl2tpd\\n\"" >>  $path_d
	echo "expect \"#\"" >>  $path_d
	echo "send \"tftp -g -r xl2tpd $lan_tmp_ip\\n\"" >>  $path_d
	echo "expect \"#\"" >>  $path_d
	echo "send \"cd /var\\n\"" >>  $path_d
	echo "expect \"#\"" >>  $path_d
	echo "send \"tftp -g -r ppa_auto_env $lan_tmp_ip\\n\"" >>  $path_d
	echo "expect eof" >>  $path_d
}



Download_ppa_proxy_and_run_in_cpe()
{	

	ping -c $cpe_ready_ping_times $cpe_default_ip
	if [ $? -eq 0 ] ; then #checking return value of ping [0--success and 1 --un_success]
		echo "ping -c $cpe_default_ip SUCCESS [ MPE FIRMWARE UP ]"
	else
		echo "MPE FIRMWARE NOT UP ->firmware crash ???  please check.....)"
		echo "MPE FIRMWARE NOT UP ->firmware crash ???  please check.....)"
		echo "MPE FIRMWARE NOT UP ->firmware crash ???  please check.....)"
		echo "MPE FIRMWARE NOT UP ->firmware crash ???  please check.....)"
		echo "MPE FIRMWARE NOT UP ->firmware crash ???  please check.....)"
		exit $s_ping_failed # kernel crash
	fi
	echo "TELNET:: to $cpe_default_ip start"
	expect $telnet_expect_file
	echo "TELNET:: complete"
}

get_version_info_from_cpe()
{
	if [ -f $local_version_file ]; then
	    rm -d $local_version_file
	fi
	touch $local_version_file
	$ppa_auto_tool -i $tmp_interface -n $ppa_auto_name -t cpe -c cmd -s "rm $tmp_cpe_file"	
	
	$ppa_auto_tool -i $tmp_interface -n $ppa_auto_name -t cpe -c cmd -s "rm /tmp/ppa_getver.sh"

	$ppa_auto_tool -i $tmp_interface -n $ppa_auto_name -t cpe -c put -s "../bin_cpe/ppa_getver.sh" -d /tmp/ppa_getver.sh

	$ppa_auto_tool -i $tmp_interface -n $ppa_auto_name -t cpe -c cmd -s "/tmp/ppa_getver.sh $tmp_cpe_file" 

	$ppa_auto_tool -i $tmp_interface -n $ppa_auto_name -t cpe -c get -s $tmp_cpe_file -d $local_version_file

	cat_mib_cmd="ls /usr/lib/pppd/ >> $tmp_cpe_file"
	$ppa_auto_tool -i $tmp_interface -n $ppa_auto_name -t cpe -c cmd -s "$cat_mib_cmd" -d $local_version_file

	$ppa_auto_tool -i $tmp_interface -n $ppa_auto_name -t cpe -c get -s $tmp_cpe_file -d $local_version_file
		
	echo "::: mpefw version ::: `cat $local_version_file`"
	cat $local_version_file
}

add_ppa_auto_env_setup_cfg()
{
	ppa_echo "cat $ppa_aut_env_setup_file $conf_file_path "
	cat $ppa_aut_env_setup_file >> $conf_file_path
	ppa_echo "cat $ppa_co_setup_file $conf_file_path "
	cat $ppa_co_setup_file >> $conf_file_path
}

Start_Test()
{
	echo ""
	echo " :::::::::::::AUTOMATION START INITIAL SET UP ::::::::::::::::::::"
	echo ""

	
	soft_link=ppa_auto_env_setup
	[ ! -e ../cfg/$soft_link ] && echo "$soft_link not found which should be linked  to cfg\cfg-users ??" && exit $s_softlink_issue 
	
	soft_link=ppa_auto_spirent_env_setup
	[ ! -e ../cfg/$soft_link ] && echo "$soft_link not found which should be linked  to cfg\cfg-users ??" && exit $s_softlink_issue 
	
	soft_link=ppa_co_env_setup
	[ ! -e ../cfg/$soft_link ] && echo "$soft_link not found which should be linked  to cfg\cfg-users ??" && exit $s_softlink_issue
		
	ppa_echo "ifconfig $ppa_auto_if_cpe $lan_tmp_ip up"
	killall tcp_client 2>/dev/null
	killall perl 2>/dev/null
	cp -f ../cfg/ppa_auto_env /tftpboot/
	chmod a+r /tftpboot/ppa_auto_env
	ifconfig $ppa_auto_if_cpe $lan_tmp_ip up	

        if [ `cat $status_file` == stopping ]; then
       	    echo "Server cancels test [current status: start.sh]"
            exit 1
        fi
        
	detect_cpe_ready
	if [ $cpe_ready -eq 0 ] ; then	
		echo "Check if ppa_auto_proxy_cpe is in /bin folder ..."
		ls -lrt $lan_ppa_bin_path/ppa_auto_proxy_cpe
		if [ $? -gt 0 ] ; then #checking return value of ls [0--success and >0 --un_success]
			echo "ppa_auto_proxy_cpe not found, EXIT !!!"
			exit $ppa_auto_proxy_cpe_issue
		fi
		chmod 755 $lan_ppa_bin_path/ppa_auto_proxy_cpe
		# Softlink to /tftpboot
		[ ! -e /tftpboot/ppa_auto_proxy_cpe ] && ln -s `pwd`/$lan_ppa_bin_path/ppa_auto_proxy_cpe /tftpboot
		[ ! -e /tftpboot/xl2tpd ] && ln -s `pwd`/$lan_ppa_bin_path/xl2tpd  /tftpboot
		generate_telnet_expect_file	
		Download_ppa_proxy_and_run_in_cpe
	fi
	get_version_info_from_cpe

	if [ -f $conf_file_path ]; then
	    rm -d $conf_file_path
	fi
	touch $conf_file_path
        add_ppa_auto_env_setup_cfg

        if [ $phy_wan_ifname0 == "nas"  ] || [  $phy_wan_ifname0 == "ptm0" ]; then
           echo "check_dsl_link ($phy_wan_ifname0)" 
           check_dsl_link
	fi

	opt="-n $repeat_times -d $delay_wait_session_continue"
	if [ "$testcase_name" != "" ] ; then
	   opt="$opt -t $testcase_name"
	fi
	
	if [ ! $run_confirmation -eq 0 ] ; then
	   opt="$opt -c"
	fi
	
	if [ ! $testcase_verbose -eq 0 ] ; then
	   opt="$opt -v"
	fi
	
	if [ ! $auto_switch_testcase -eq 0 ] ; then
	   opt="$opt -f"
	fi

	if [ ! $hard_test_only -eq 0 ] ; then
	   opt="$opt -r"
	fi		
	echo "opt = $opt"
	ppa_echo ss_opt=$opt
	
	echo "Start Testing $phy_wan_ifname0 $lan_tmp_ip: $ppa_auto_tmp_result_log created"
	touch $testlink/$ppa_auto_tmp_result_log
	# TODO: live result file is originated at start.sh, now change the softlink

        sudo ../bin/ss.sh $opt
	
	generate_html_test_report_wit_tmp_htm # TODO removed?

	exit 0
}

Start_Test


