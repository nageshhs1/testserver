#!/bin/sh
. ../cfg/log_report.sh

taskid=$1
taskpath=/tftpboot/task/$taskid
bl=$taskpath/board_list.txt
board_id=
build_mode=
wan_mode=
reboot_opt=
valid=0
board_path=../board
live=0


# main 
Start_run_boards() 
{
	echo "Link /bin/sh to /bin/bash  ..."
	if [ ! -e /bin/sh ]; then
	   echo "add /bin/bash softlink"
	   ln -s /bin/bash /bin/sh
	fi
	if [ "$(readlink -- "/bin/sh")" != /bin/bash ]; then
	   echo "Relink /bin/sh"
	   rm /bin/sh
	   ln -s /bin/bash /bin/sh
	fi
	
	printf "Check if board_list exist: "
	if [ ! -e $bl ]; then
	   printf "Board list is missing !\n"
	   end_run
	fi
	
	while read line; do
		case "$line" in \#*) continue ;; esac 
		set -- $line	
		board_id=$1
		build_mode=$2
		wan_mode=$3
		reboot_opt=$4
                testabort=0

                if [ `cat $status_file` == stopping ]; then 
                    echo "STOP!!! task=$task_id board=$1 wan_mode=$3" 
                    testabort=$stop_test
                    break 
                fi

		printf "board_id=$board_id, build_mode=$build_mode, wan_mode=$wan_mode, reboot_opt=$reboot_opt\n"
		#Remove previous result htm files and create a default one
		if [ -e $taskpath/$board_id/result_$wan_mode.htm ]; then
			rm $taskpath/$board_id/result_$wan_mode.htm
		fi
		touch $taskpath/$board_id/result_$wan_mode.htm
		echo "Test is not yet running, miscofigured, or testcase file is missing." >> $taskpath/$board_id/result_$wan_mode.htm
		
		# Load DUT configuration
		. $board_path/board_$board_id.cfg
		
		# Check supported WAN mode on this DUT
		valid=0	
		a=( $CPE_WAN_MODE_LIST )
		len=${#a[@]}
		for(( i=0; i<$len; i++ ))
		do
			#echo ${a[$i]}
			if [ ${a[$i]} == $wan_mode ];then
				valid=1
				echo "Board$board_id has $wan_mode if, proceed ..."
				break
			fi
		done
		if [[ $valid -eq 0 ]] ; then
			echo "$wan_mode interface not found, process next board or exit (if it is the last one)"
			continue 
		fi
		
		# Check supported build mode on this DUT
		valid=0	
		a=$FW_BUILD_MODE_LIST
		if [[ $build_mode = $a* ]];then
		  valid=1
		  echo "Board$board_id runs with $build_mode model, proceed ..."
		fi
		if [[ $valid -eq 0 ]] ; then
			echo "$build_mode not found, process next board or exit (if it is the last one)"
			continue 
		fi
		
		echo "Check testcase list for $wan_mode mode"
		if [ ! -e $taskpath/$board_id/testcase_list_$wan_mode.txt  ]; then
			echo "testcase_list_$wan_mode not found, process next board or exit (if it is the last one)"
			continue			
		fi
		if [ $live -eq 0 ]; then
			echo "initialise live reporting files"
			start_live_html_status
			live=1
		fi
		
		echo "$taskpath/$board_id/log_$wan_mode.txt" > $html_console_logfile
		
		./run_one_board.sh -b board_$board_id.cfg -p task/$task_id -w $wan_mode > $taskpath/$board_id/log_$wan_mode.txt

	done < $bl # read -r line;
	
	end_run
}

end_run()
{
        echo "rb:testabort=$testabort"
        if [ $testabort -eq $stop_test ] || [ `cat $status_file` == stopping ]; then 
             echo "free" > $status_file
        else
             echo "finished" > $status_file
        fi
	exit 0
}

start_live_html_status()
{
	#TODO can be created in web_cgi_setup
	#rm $html_status_file
	#touch $html_status_file
	#chmod 777 $html_status_file
	#chown www-data:www-data $html_status_file
		
	#html open for All_Platform_Status_File
	echo "<html>" > $html_status_file
	echo "<body style=\"background-color:#82CAFF;\">" >> $html_status_file
	echo "<h3><div style=\"text-align: center\"><font style=\"color:#0000A0\"><u>TASK $task_id</u></font></div></h3>" >> $html_status_file
	echo "<table style=\"text-align: left\" border=\"1\"  cellpadding=\"2\">" >> $html_status_file
	echo "<tr>" >> $html_status_file
	echo "<th><b>BOARD</b>" >> $html_status_file
	echo "<th><b>WAN_MODE</b>" >> $html_status_file
	echo "<th><b>TEST STATUS</b></th>" >> $html_status_file
	echo "</tr>" >> $html_status_file

	#html close for All_Platform_Status_File
	echo "</table>" >> $html_status_file
	echo "</body>" >> $html_status_file
	echo "</html>" >> $html_status_file
}

task_id=$1
echo terminal_log.txt > $html_console_logfile
Start_run_boards > terminal_log.txt  

#rm z.txt; sudo ./run_boards.sh 2 >> z.txt
