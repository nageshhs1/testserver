#!/bin/sh
. ../cfg/cpe_env_global
. ../cfg/ppa_auto_env
. ../cfg/ppa_auto_testcase_env
. ../cfg/getopt.sh


set=1
unset=0
auto_path=../Auto
status_file=../web_gui/cgi-bin/auto_log/status.txt
curr_testcase="";
curr_start_time=0;
curr_end_time=0;
Spirent_Test_Complete=""
ppa_auto_tool_retcode=0;
curr_loop_time=0;

#$1: filename
is_file_exist()
{
  #echo check file $1
  f_exist=0
  ( [ -e $1 ] || [ -h $1 ] ) && f_exist=1;
}

#$1: directory name
is_dir_exist()
{
  #echo check file $1
  f_exist=0
  ( [ -d $1 ] || [ -h $1 ] ) && f_exist=1;
}

init_tmp_report_file()
{
	echo "init_tmp_report_file inside `pwd`"
	testdate=$(date +%Y%m%d"_"%H%M%S)
	Test_Report_Header="Test_Report_"$testdate
	[ -e $ppa_auto_tmp_result_log ] && echo  "" > $ppa_auto_tmp_result_log;
	echo "<html>" >> $ppa_auto_tmp_result_log
	echo "<body style=\"background-color:PowderBlue;\">" >> $ppa_auto_tmp_result_log
	echo "" >> $ppa_auto_tmp_result_log
	echo "" >> $ppa_auto_tmp_result_log
	echo "<h2><strong>$Test_Report_Header</strong></h2>" >> $ppa_auto_tmp_result_log
	echo "" >> $ppa_auto_tmp_result_log
	echo '<table style="text-align: left" border="1"  cellpadding="2">  ' >> $ppa_auto_tmp_result_log
	echo "<tr><td>Index</td><td>Test Name</td><td>Groups</td><td>Result</td><td>Duration(Sec)</td></tr>" >> $ppa_auto_tmp_result_log
}


#$1: input string
color="";
make_color()
{
  color="";
  filter_ok=`echo $1 | grep -v ok | grep -v FrameSize`
  [ "$filter_ok" != "" ] && color="red"
  
}

#$1: test script name
#S2: test case group name
descrption_file="testcase_description.htm"
generate_html_test_report()
{
  echo "s4line 75"
  echo "generate_html_test_report inside `pwd`"

  curr_end_time=`date +%s`
  curr_time_taken=$(( $curr_end_time - $curr_start_time ))
  if [ ! $ppa_auto_tool_retcode -eq 0 ]; then
    result="ppa proxy fail"
  else
    #cat $1/$ppa_auto_testcase_result_file
    result=`cat $1/$ppa_auto_testcase_result_file`
  fi
  make_color "$result"
  if [ "${color}" == "" ]; then
    echo "<tr><td>$test_index</td><td>$1</td><td>$2</td><td>$result</td><td>$curr_time_taken</td></tr>" >> $ppa_auto_tmp_result_log
  else
    echo "<tr BGCOLOR=\"red\"><td>$test_index</td><td>$1</td><td>$2</td><td>$result</td><td align="center">$curr_time_taken</td></tr>" >> $ppa_auto_tmp_result_log
  fi
  
}

#$1: script filename
#$2: run at backgroud or forground
run_one_single_script()
{
  
  is_file_exist $1
  
  #if file not exist, exit the API
  if [ $f_exist -eq 0 ]; then
    #echo  "   script $1 not exist ---"
    return
  fi
  
  #workaround for vm os. sometimes vm cannot receive any multicast packet.
  #but if it will work after wireshark caputring on this interface
  ifconfig $ppa_auto_if_cpe promisc up
  ifconfig $ppa_auto_if_wan promisc up
  
  
  #check to run the command at fore/back ground
  if [ $2 -gt 0 ]; then
    $1 &
  else
    $1
  fi
  echo "   script $1 done ---"
}

#$1: wait for script filename
#$2: delay time in seconds
run_confirmation_delay_handle()
{
  is_file_exist $1
  if [ $f_exist -gt 0 ] ; then
    if [ $run_confirmation -gt 0 ]; then
      echo "-----press ENTER for next $curr_testcase/$file"
      read key
    else
      sleep $2
      echo "-----Run for next $curr_testcase/$file"
    fi
  fi
}

#$1: testscript name/folder
#$2: testscript group name
#$3: test case index
run_one_test_case()
{
  curr_start_time=`date +%s`
  is_dir_exist $1
  if [ $f_exist -eq 0 ]; then
    echo ""
    echo "Testcase not exist: $1"
    return
  fi
  
  cd $1
  
  
  [ -e $ppa_auto_tool_retcode_file ] && rm $ppa_auto_tool_retcode_file
  ppa_auto_tool_retcode=0
  
  echo "-----Start run testcase $1--------"
  $ppa_auto_tool -i $ppa_auto_if_cpe -n $ppa_auto_name -t cpe -c cmd -s "echo --- Start run testcase[$curr_loop_time][$test_index] $1 --- > /dev/console " -d "" -g $ppa_auto_debug
  curr_testcase=$1

  file="./cpe_init_script"
  [ -e $file ] && $ppa_auto_tool -i $ppa_auto_if_cpe -n $ppa_auto_name -t cpe -c cmd -s "echo   ----- to run script $file--- > /dev/console " -d "" -g  $ppa_auto_debug
  run_one_single_script $file 0
  
  if [ -e $ppa_auto_tool_retcode_file  ]; then
    ppa_auto_tool_retcode=1;
    cd ..
    generate_html_test_report $1 $2
    return
  fi
 
  file="./lan_init_script"
  run_confirmation_delay_handle $file 0
  run_one_single_script $file 0
  
  file="./wan_init_script"
  run_confirmation_delay_handle $file 0
  run_one_single_script $file 0
  sleep $delay_init
  
  
  file="./cpe_packet_script"
  [ -e $file ] && $ppa_auto_tool -i $ppa_auto_if_cpe -n $ppa_auto_name -t cpe -c cmd -s "echo   ----- to run script $file--- > /dev/console " -d "" -g  $ppa_auto_debug
  run_confirmation_delay_handle $file 0
  run_one_single_script $file 0
  if [ -e $ppa_auto_tool_retcode_file  ]; then
    ppa_auto_tool_retcode=1;
    cd ..
    generate_html_test_report $1 $2
    return
  fi
  
  file="./wan_packet_script"
  run_confirmation_delay_handle $file 3
  run_one_single_script $file 0
  
  #special one here: put at the last of all xxx_packet_script,
  #at the same time, add a special delay here
  file="./lan_packet_script"
  run_confirmation_delay_handle $file 3
  #run at background for normal test case except for spirent test case
  #if [ -f ./lan_packet_script_foreground ]; then
  run_one_single_script $file 0
  #else
  #	run_one_single_script $file 0
  #fi
  
  sleep $delay_packet
  echo "   Waiting for session to set up"
  sleep $delay_wait_session_setup   #very important to sleep after all packet_script
  
  file="./cpe_pre_verify_script"
  [ -e $file ] && $ppa_auto_tool -i $ppa_auto_if_cpe -n $ppa_auto_name -t cpe -c cmd -s "echo   ----- to run script $file--- > /dev/console " -d "" -g  $ppa_auto_debug
  run_confirmation_delay_handle $file 0
  run_one_single_script $file 0
  
  if [ -e $ppa_auto_tool_retcode_file  ]; then
    ppa_auto_tool_retcode=1;
    cd ..
    generate_html_test_report $1 $2
    return
  fi
  
  file="./lan_pre_verify_script"
  run_confirmation_delay_handle $file 0
  run_one_single_script $file 0
  
  file="./wan_pre_verify_script"
  run_confirmation_delay_handle $file 0
  run_one_single_script $file 0
  sleep $delay_pre_verify
  
  
  #since all mib counter is cleared now. Need wait for a while for session to run
  sleep $delay_wait_session_continue # adjust the value in the cfg/getopt.sh

  file="./cpe_verify_script"
  [ -e $file ] && $ppa_auto_tool -i $ppa_auto_if_cpe -n $ppa_auto_name -t cpe -c cmd -s "echo   ----- to run script $file--- > /dev/console " -d "" -g  $ppa_auto_debug
  run_confirmation_delay_handle $file 0
  run_one_single_script $file 0
  if [ -e $ppa_auto_tool_retcode_file  ]; then
    ppa_auto_tool_retcode=1;
    
    cd ..
    generate_html_test_report $1 $2
    return
  fi
  
  file="./lan_verify_script"
  run_confirmation_delay_handle $file 0
  run_one_single_script $file 0
  
  
  file="./wan_verify_script"
  run_confirmation_delay_handle $file 0
  run_one_single_script $file 0
  sleep $delay_verify
  
  file="./cpe_stop_verify_script"
  [ -e $file ] && $ppa_auto_tool -i $ppa_auto_if_cpe -n $ppa_auto_name -t cpe -c cmd -s "echo   ----- to run script $file--- > /dev/console " -d "" -g  $ppa_auto_debug
  run_confirmation_delay_handle 0
  run_one_single_script $file 0
  
  if [ -e $ppa_auto_tool_retcode_file  ]; then
    ppa_auto_tool_retcode=1;
    
    cd ..
    generate_html_test_report $1 $2
    return
  fi
  
  file="./lan_stop_verify_script"
  run_confirmation_delay_handle 0
  run_one_single_script $file 0
  
  file="./wan_stop_verify_script"
  run_confirmation_delay_handle $file 0
  run_one_single_script $file 0
  sleep $delay_stop_verify
  
  file="./cpe_result_script"
  [ -e $file ] && $ppa_auto_tool -i $ppa_auto_if_cpe -n $ppa_auto_name -t cpe -c cmd -s "echo   ----- to run script $file--- > /dev/console " -d "" -g  $ppa_auto_debug
  run_confirmation_delay_handle $file 0
  run_one_single_script $file 0
  
  if [ -e $ppa_auto_tool_retcode_file  ]; then
    ppa_auto_tool_retcode=1;
    cd ..
    generate_html_test_report $1 $2
    return
  fi
  
  file="./lan_result_script"
  run_confirmation_delay_handle $file 0
  run_one_single_script $file 0
  
  file="./wan_result_script"
  run_confirmation_delay_handle $file 0
  run_one_single_script $file 0
  sleep $delay_result

  $ppa_auto_tool -i $ppa_auto_if_cpe -n $ppa_auto_name -t cpe -c put -s $ppa_auto_testcase_result_file  -d /var/result.log -g $ppa_auto_debug
  $ppa_auto_tool -i $ppa_auto_if_cpe -n $ppa_auto_name -t cpe -c cmd -s "echo ----- The result -----> /dev/console" -d "" -g $ppa_auto_debug
  $ppa_auto_tool -i $ppa_auto_if_cpe -n $ppa_auto_name -t cpe -c cmd -s "cat /var/result.log > /dev/console" -d "" -g $ppa_auto_debug
  $ppa_auto_tool -i $ppa_auto_if_cpe -n $ppa_auto_name -t cpe -c cmd -s "echo ----------------------> /dev/console" -d "" -g $ppa_auto_debug

  cd ..
  generate_html_test_report $1  $2
}

force_exit()
{
  echo "capture force kill like ctrl-c, or stopping status"
  
  #cd $last_folder
  exit 1
}

####################### Start Script Entry ############
####Note-----------------
#If one parameter name is 0, then disable run_confirmation, ie, it will auto run all test scripts
#install trap
trap force_exit SIGINT

echo repeat_times=$repeat_times
echo testcase_name=$testcase_name
echo testcase_verbose=$testcase_verbose
echo run_confirmation=$run_confirmation
echo delay_wait_session_continue=$delay_wait_session_continue
echo auto_switch_testcase=$auto_switch_testcase
echo hard_test_only=$hard_test_only


#download scripts, like ip command
echo "`pwd`"
../bin/one_time_script.sh $ppa_auto_if_cpe 0


i=0
while [ $i -lt ${repeat_times} ]
do
  start_time=`date +%s`
  time_tag=$(date +%Y%m%d"_"%H%M%S)
  
  echo --current repeat times=$i, total_repeat=${repeat_times} ------
  i=$(( $i+1 ))
  curr_loop_time=$i;

  #init tmp report
  # TODO removed?
  if [ ! -s $ppa_auto_tmp_result_log ]; then
	init_tmp_report_file
	echo "$ppa_auto_tmp_result_log write starts"
  fi
  
  if [ -n "$testcase_name" ]; then
    test_index=1
    curr_testcase_name=$testcase_name
    run_one_test_case $testcase_name
  else
	test_index=1;
	for testcase_name in $auto_path/ts_*; do
		curr_testcase_name=${testcase_name##*/}
		echo -----test_index=$test_index: $curr_testcase_name ----
		echo ""
		run_one_test_case $curr_testcase_name
        	if [ `cat $status_file` == stopping ]; then
               	    echo "Server cancels test [current status: current testcase done]"
               	    exit 1
        	fi
		test_index=$(($test_index+1))
	done	
  fi

  #save result to tmp: note, hardcoded filename here
  #tmp_path=tmp_log
  #[ ! -d $tmp_path ] && mkdir $tmp_path
  #cp tmp.htm $tmp_path/tmp${i}_${time_tag}.htm
  #
  #echo "Test result saved from $tmp_path/tmp1_${time_tag}.htm to $tmp_path/tmp${i}_${time_tag}.htm"
  end_date=`date +%s`
  diff_time=$(( $end_date - $start_time ))
  echo "Took about $diff_time seconds to complete $i test cases"
done






