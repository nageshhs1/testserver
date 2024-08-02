#!/bin/sh

#need run_confirmation by step and step
#delay_init mainly for dsl showtime and  ppp set up, also for kill old nas interface and re-create new nas interface
delay_init=0
#since there is delay_wait_session_setup. so set zero here
delay_packet=0  
delay_wait_session_setup=5
#since there is delay_wait_session_continue. so set zero here
delay_pre_verify=0  
delay_wait_session_continue=25
delay_verify=0
delay_stop_verify=0
delay_result=0

run_confirmation=0
repeat_times=1
testcase_name=""   
testcase_verbose=0
auto_switch_testcase=0
hard_test_only=0
mode=""
ALL_PLATFORM_Test_Report_Path=""
PLATFORM_FAMILY=""
WAN_INF=""


option_list="ht:m:cn:R:d:frvP:W:"

usage()
{
cat << EOF
usage: $0 options

This script run one or all testcases with specific repeat times

OPTIONS:
   -h      Show this message
   -t      Test case, like ts_lan_wan_static_tcp ( 0ptional )
           This option is optional. If skipped, it means run all test cases under current folder
   -c      need confirmation with every script ( for debugging only and no parameter )
   -n      repeat loop times  ( default is 1 )
   -d      traffic injection times  ( default is 40 seconds )
   -f      auto switch test case folder according to PPA FW version ( no parameter)
   -r      run test procedure only without real testing ( no parameter )
   -v      Verbose ( no parameter )
EOF
}


while getopts ${option_list} OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         t)
             testcase_name=$OPTARG
             ;;
         n)
             repeat_times=$OPTARG
             [ $repeat_times -eq 0 ] && repeat_times=30000
             ;;         
         v)
             testcase_verbose=1
             ;;
         c) 
            run_confirmation=1
             ;;
         d)
            delay_wait_session_continue=$OPTARG
	    ;;		
         m)  
	    mode=$OPTARG
            ;;
         P)  
	    PLATFORM_FAMILY=$OPTARG
            ;;
         R)  
	    ALL_PLATFORM_Test_Report_Path=$OPTARG
            ;;
         W)  
	    WAN_INF=$OPTARG
            ;;
         f)  
	    auto_switch_testcase=1
            ;;
         r) 
            hard_test_only=1
            ;;			
	?)
             usage
             exit
             ;;
     esac
done

echo ALL_PLATFORM_Test_Report_Path=$ALL_PLATFORM_Test_Report_Path
echo mode=$mode
#echo repeat_times=$repeat_times
#echo testcase_name=$testcase_name
#echo testcase_verbose=$testcase_verbose
#echo run_confirmation=$run_confirmation
#echo delay_wait_session_continue=$delay_wait_session_continue

