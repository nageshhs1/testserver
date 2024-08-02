#!/bin/sh

. ../cfg/log_report.sh

taskpath=/tftpboot/task
testlink=../Auto
task_id=
board_id=
wan_mode=

usage() { echo "Usage: $0 [-b <board_config>] [-p <image_path>] [-w wan_mode (eth/atm/ptm)]" 1>&2; exit 1; }

while getopts ":b:p:w:" o; do
    case "${o}" in
        b)
            b=${OPTARG}
            ;;		
        p)
            p=${OPTARG}
            ;;
        w)
            w=${OPTARG}
            ;;				
        *)
shift $((OPTIND-1))

            usage
            ;;
    esac
done

if [ -z "${b}" ] || [ -z "${p}" ] || [ -z "${w}" ]; then
    usage
fi

#echo "b = ${b}"
#echo "p = ${p}"
#echo "w = ${w}"

clean() 
{
	#rm -rf $testlink
	#rm ifx_set_login*
	#rm Set.cmd* 
	#rm ifx_set_wan_mode* 
	#rm index* 
	killall read_cpe_console.sh 2>/dev/null	
        echo "Switch off $b"
        # Uncommnent following line for image update 
	#./turn_dut_power.sh -b $b -s 'off'
	printf "Clean up unwanted files, go to next test if any.\n"
}


Start_run_one_board()
{
	printf "\n ::::::::::::::::::      START ONE BOARD TEST    ::::::::::::::::::"
	printf "\n :: Info: board_cfg=$b, image_path=$p, wan_mode=$w ::\n"

	
	#. $BOARD_PATH/${b}  # if this script runs standalone then it can be uploaded here
	
	# Grep board_id and task_id from board_cfg and image_path
	wan_mode=$w
	board_id="${b//[^0-9]/}"
	task_id="${p//[^0-9]/}"
        testabort=0
	
	#Remove default htm files for particular board/wan mode
	if [ -e $taskpath/$task_id/$board_id/result_$wan_mode.htm ]; then
		rm $taskpath/$task_id/$board_id/result_$wan_mode.htm
	fi
	
	#Create temporary folder first time
	[ ! -d $testlink ] && mkdir -p $testlink
	 
	prepare_result_header
	# Create softlink HTML result file for first time
	#[ ! -e $html_result_file ] && ln $testlink/$testreport $html_result_file	
        rm $html_result_file
	ln $testlink/$testreport $html_result_file	
	echo "HTML status file script: `pwd`/$live_html_status"
	$live_html_status  set $html_status_file $board_id $wan_mode $test_running_colour testing
        
    # Prepare DUT console log
    if [ -e $testlink/log_console_$wan_mode.txt ]; then
       rm $testlink/log_console_$wan_mode.txt
    fi
    cpe_log=$testlink/log_console_$wan_mode.txt
    echo "cpe_log=$cpe_log"
    touch $cpe_log
    chmod 777 $cpe_log
    killall putty 2>/dev/null   	

    # Uploading DUT images	
    curr_start_time=`date +%s`
    # Uncomment following line to load image using script
    #./update_image.sh -b $b -p $p 
    testabort=$?	
    if [ $testabort -gt 0 ]; then
        echo "update_image failed code = $testabort"
        if [ $testabort -eq $image_update_failed ]; then
            testabort=$image_update_failed
            testabort_msg=$image_update_failed_msg
        elif [ 	$testabort -eq 	$missing_uboot ]; then		
            testabort=$missing_uboot
            testabort_msg=$missing_uboot_msg
        elif [ 	$testabort -eq 	$missing_bootcore ]; then		
            testabort=$missing_bootcore
            testabort_msg=$missing_bootcore_msg
        elif [ 	$testabort -eq 	$missing_fullimage ]; then		
            testabort=$missing_fullimage
            testabort_msg=$missing_fullimage_msg
        elif [ 	$testabort -eq 	$missing_gphy_file ]; then		
            testabort=$missing_gphy_file
            testabort_msg=$missing_gphy_file_msg
        elif [ 	$testabort -eq 	$stop_test ]; then		
            testabort=$stop_test
            testabort_msg=$stop_test_msg
        elif [ 	$testabort -eq 	$failed_boot ]; then		
            testabort=$failed_boot
            testabort_msg=$failed_boot_msg
        elif [ 	$testabort -eq 	$failed_ping ]; then		
            testabort=$failed_ping
            testabort_msg=$failed_ping_msg	
        elif [  $testabort -eq  $failed_ippwr ]; then
            testabort=$failed_ippwr
            testabort_msg=$failed_ippwr_msg
        fi			
        echo "testabort[$testabort]:$testabort_msg" > "$cpe_log"
        failed_test_result $testabort
        upload_test_result
        clean
        exit 1
    fi
	
	echo "TESTCASE ON TASK=$task_id/BOARD=$board_id/WAN=$wan_mode EXECUTION [START]"	
	test_id=1 #testcase counter
	
	# Read DUT console from /dev/ttyS0
        killall tcp_client 2>/dev/null
        killall perl 2>/dev/null   	
	$Read_TTYS0_PATH >> ""$cpe_log"" &
	
	# Creating softlink to all testcases
	echo "Create Testcase Softlink"
	while read -r testcase; do
		case "$testcase" in \#*) continue ;; esac
		echo "Test $test_id ::::: $testcase ::::: "
		((test_id=test_id+1))
		ln -s ../testcase/$testcase $testlink/.	
	#done < $taskpath/2016/1/testcase_list_$wan_mode.txt	
	done < $taskpath/$task_id/$board_id/testcase_list_$wan_mode.txt	

        # Set WAN interface
        board_common=../board/board_common.cfg
        if [ $wan_mode ==  "eth" ]; then
           wan_if=$(sed -n 's/^CPE_WAN_ETH_LIST=//p' $board_common) 
        elif [ $wan_mode ==  "atm" ]; then
           wan_if=$(sed -n 's/^CPE_WAN_ATM_LIST=//p' $board_common) 
        elif [ $wan_mode ==  "ptm" ]; then
           wan_if=$(sed -n 's/^CPE_WAN_PTM_LIST=//p' $board_common) 
        fi
        echo "wan_mode=$wan_mode, wan_if=$wan_if"
        $update_wanif $wan_if
		
	#### All scripts running in the $testlink ####
	cd $testlink
	echo "start.sh run from`pwd`"	
	sudo ../bin/start.sh 
        testabort=$?
        if [ $testabort -gt 0 ]; then
            echo "start.sh failed code = $testabort"
            if [ $testabort -eq $s_softlink_issue ]; then
                testabort=$s_softlink_issue
                testabort_msg=$s_softlink_issue_msg
            elif [  $testabort -eq $s_ping_failed ]; then
                testabort=$s_ping_failed
                testabort_msg=$s_ping_failed_msg
            elif [  $testabort -eq $s_dsl_failed ]; then
                testabort=$s_dsl_failed
                testabort_msg=$s_dsl_failed_msg
            fi
            echo "testabort[$testabort]:$testabort_msg" > "$cpe_log"
            failed_test_result $testabort
            # Failed start.sh need to return to bin folder
            rm $testlink/ts*
            cd ../bin
            upload_test_result
            clean
            exit 1
        fi
	cd -
	#### #################################### ####
	
	echo "Remove Testcase Softlink"
	rm $testlink/ts*	

        [ `cat $status_file` == stopping ] && testabort=$stop_test && failed_test_result $testabort
       	
	#Close report and upload test report
	upload_test_result

	. $BOARD_PATH/${b}  # if this script runs standalone then it can be uploaded here
        #echo "Board to turn off $b"
	#./turn_dut_power.sh -b $b -s 'off'
	clean
}

prepare_result_header()
{
	cd $testlink
	echo "HTML result file: `pwd`/$testreport"	
	testdate=$(date +%Y%m%d" "%H:%M:%S)
	Test_Report_Header="Test_Report"
	# A new test report created
	echo "<html>" > $testreport
	echo "<body style=\"background-color:PowderBlue;\">" >> $testreport
	echo "" >> $testreport
	echo "" >> $testreport
	echo "<h2><strong>$Test_Report_Header</strong></h2>" >> $testreport 
	echo "" >> $testreport
	echo "board_cfg=$b, image_path=$p, wan_mode=$w on $testdate" >> $testreport
	echo "" >> $testreport
	echo "" >> $testreport
	#echo "failed causes: $image_update_failed(upload image), $kernel_crash(kernel crashed or missing files)" >> $testreport
	echo "" >> $testreport
	echo '<table style="text-align: left" border="1"  cellpadding="2">  ' >> $testreport
	echo "<tr><td>Index</td><td>Test Name</td><td>Groups</td><td>Result</td><td>Duration(Sec)</td></tr>" >> $testreport
	cd -
}

failed_test_result()
{
	cd $testlink
	test_index=
	#early_exit_header
	result="Failed($1)"
	curr_time_taken=0
	while read -r testcase; do
		case "$testcase" in \#*) continue ;; esac
		echo "<tr><td>$test_index</td><td>$testcase</td><td>$2</td><td><font color="red">$result</font></td><td align="center">$curr_time_taken</td></tr>" >> $testreport	
		#test_index=$(($test_index+1))
	done < $taskpath/$task_id/$board_id/testcase_list_$wan_mode.txt 
	cd -
}

upload_test_result()
{
	local curr_end_time=`date +%s`
	local curr_time_taken=$(( $curr_end_time - $curr_start_time ))
	read -r line < $fwversi # read first line

	echo "</table>" >> $testlink/$testreport	
        [ $testabort -gt 0 ] && echo "($testabort)$testabort_msg" >> $testlink/$testreport && echo "<br>" >> $testlink/$testreport
	echo "Time taken since uploading image: $curr_time_taken secs"  >> $testlink/$testreport
	echo "<br>" >> $testlink/$testreport
	echo "<small>$line</small>"  >> $testlink/$testreport
	echo "</body>" >> $testlink/$testreport
	echo "</html>" >> $testlink/$testreport	
        echo "rob:testabort=$testabort (rob=0 is normal case)"
        if [ $testabort -eq $stop_test ]; then
            $live_html_status update $html_status_file $board_id $wan_mode $test_halt_colour stopping 
        else
            $live_html_status update $html_status_file $board_id $wan_mode $test_complete_colour finished
        fi	
	cp $testlink/$testreport $taskpath/$task_id/$board_id/result_${wan_mode}.htm
	mv $cpe_log $taskpath/$task_id/$board_id/.
}

Start_run_one_board

#rm z.txt; sudo ./run_one_board.sh -b board_1.cfg -p task/2 -w eth >> z.txt
