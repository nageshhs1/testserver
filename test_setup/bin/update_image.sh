#!/bin/sh
. ../cfg/log_report.sh
board_path=../board
cmd_start_run_delay=1
crash_count=500
status_file=../web_gui/cgi-bin/auto_log/status.txt

Log_Error_To_AllPlatform_Test_report_And_Reset_Platform()
{
	ERROR_MASSAGE=$1
	echo "$ERROR_MASSAGE"
}


Stop_boot_up()
{
	echo "HARD RESET...."
	uboot_crash_counter=0
	Continue=""
	FILE="$SERIAL_DEVICE"
	BAKIFS=$IFS
	exec 3<&0
	exec 0<"$FILE"
	while read -r -t 3 line
	do
		echo "SERIAL_PORTREAD: $line"
		Continue="set"
		if [ "$uboot_crash_counter" == $crash_count ];then
			Log_Error_To_AllPlatform_Test_report_And_Reset_Platform "BOARD CRASH 1[ABORT SCRIPT]"
			#set_test_status $test_complete_colour TEST_COMPLETE
			exec 0<&3 # restore previous stdin.
			IFS=$BAKIFS #   and IFS.
			exit $image_update_failed
		fi
		uboot_crash_counter=`expr $uboot_crash_counter + 1`
	done
	exec 0<&3
	IFS=$BAKIFS

	echo "Continue = $Continue"
	echo "\\n" > $SERIAL_DEVICE
	check=$(echo $Continue | grep "set")
	if [ "$check" != "" ];
	then
		echo "Key sent to stop Autoboot via $SERIAL_DEVICE"
		
		# In case to read all environment variables, then use following lines
		# *******************************************************************
		#echo "printenv" > $SERIAL_DEVICE
		#exec 3<&0
		#exec 0<"$FILE"
		#while read -r -t 5 line
		#do
		#	echo "SERIAL_ENVIRO:   $line"
		#done	
		#exec 0<&3
		#IFS=$BAKIFS
		# *******************************************************************
		
		#set_test_status $test_running_colour TEST_RUNNING
	else
		Log_Error_To_AllPlatform_Test_report_And_Reset_Platform "BOARD CRASH [ABORT SCRIPT]"
		#set_test_status $test_complete_colour TEST_COMPLETE
		exec 0<&3 # restore previous stdin.
		IFS=$BAKIFS #   and IFS.
		echo "BROAD CRASH.....???"
	fi
	[ "$check" == "" ] && exit $failed_boot # failed to stop uboot or DUT is off
	sleep 1
}

Image_exist_link()
{
    echo "Images are in $BOOT_TFTPBOOT/$p"
	if [ ! -e $BOOT_TFTPBOOT/$p/$UBOOT_FILE ]; then
		GLog_Error_To_AllPlatform_Test_report_And_Reset_Platform "$UBOOT_FILE is missing, abort test !"
		exit $missing_uboot
	elif [ ! -e $BOOT_TFTPBOOT/$p/$BOOTCORE_FILE ]; then
		Log_Error_To_AllPlatform_Test_report_And_Reset_Platform "$BOOTCORE_FILE is missing, abort test !"
		exit $missing_bootcore
	elif [ ! -e $BOOT_TFTPBOOT/$p/$FULLIMAGE_FILE ]; then
		Log_Error_To_AllPlatform_Test_report_And_Reset_Platform "$FULLIMAGE_FILE is missing, abort test !"
		exit $missing_fullimage
	elif [ ! -e $BOOT_TFTPBOOT/$p/$GPHY_FILE ]; then
		Log_Error_To_AllPlatform_Test_report_And_Reset_Platform "$GPHY_FILE is missing, abort test !"
		exit $missing_gphy_file
    fi		
}

Set_ip_lanpc()
{
	echo " ifconfig $TEST_SETUP_ETH_IF $BOOT_SERVERIP up"
	ifconfig $TEST_SETUP_ETH_IF $BOOT_SERVERIP up
}

Serial_port_init()
{
	setserial $SERIAL_DEVICE baud_base $BAUDRATE
	stty -F $SERIAL_DEVICE raw ispeed $BAUDRATE ospeed $BAUDRATE -ignpar cs8 -cstopb -echo
	echo "/dev/ttyS0 set to :"
	stty -a -F $SERIAL_DEVICE
}

Boot_param_set()
{
	#perl $Read_Write_Serial_Device "boot_param" $ETHADDR $BOOT_IPADDR $BOOT_SERVERIP "$p/"
        #perl $Read_Write_Serial_Device "images" $UBOOT_CMD $BOOTCORE_CMD $FULLIMAGE_UPDATE_CMD $GPHY_UPDATE_CMD
        echo "setenv ethaddr $ETHADDR; setenv ipaddr $BOOT_IPADDR; setenv serverip $BOOT_SERVERIP; setenv tftppath $p/" > $SERIAL_DEVICE
        echo "setenv ethaddr $ETHADDR; setenv ipaddr $BOOT_IPADDR; setenv serverip $BOOT_SERVERIP; setenv tftppath $p/" 
        echo "setenv update_all 'run update_nandboot; run update_bootcore; run update_fullimage; run update_gphyfirmware" > $SERIAL_DEVICE
        echo "setenv update_all 'run update_nandboot; run update_bootcore; run update_fullimage; run update_gphyfirmware" 
}

Image_exist_Boot_param_set()
{
	echo "Images are in $BOOT_TFTPBOOT/$p"
        echo "setenv ethaddr $ETHADDR; setenv ipaddr $BOOT_IPADDR; setenv serverip $BOOT_SERVERIP; setenv tftppath $p/" > $SERIAL_DEVICE
        echo "setenv ethaddr $ETHADDR; setenv ipaddr $BOOT_IPADDR; setenv serverip $BOOT_SERVERIP; setenv tftppath $p/"

	if [ -e $BOOT_TFTPBOOT/$p/$UBOOT_FILE ]; then
		echo "setenv update_all 'run update_nandboot" > $SERIAL_DEVICE
		echo "setenv update_all 'run update_nandboot"
	elif [ -e $BOOT_TFTPBOOT/$p/$BOOTCORE_FILE ]; then
		echo "setenv update_all 'run update_bootcore" > $SERIAL_DEVICE
		echo "setenv update_all 'run update_bootcore"
	elif [ -e $BOOT_TFTPBOOT/$p/$FULLIMAGE_FILE ]; then
		echo "setenv update_all 'run update_fullimage" > $SERIAL_DEVICE
		echo "setenv update_all 'run update_fullimage"
	elif [ -e $BOOT_TFTPBOOT/$p/$GPHY_FILE ]; then
		echo "setenv update_all 'run update_gphyfirmware" > $SERIAL_DEVICE
		echo "setenv update_all 'run update_gphyfirmware"
	fi
}
run_update()
{
	update_command=$1;
	sleep $cmd_start_run_delay
	perl $Read_Write_Serial_Device "$update_command"
	check_result run
}


ping_dut()
{
	ping -c $1 $BOOT_IPADDR
	if [ $? -eq 0 ] ; then #checking return value of ping [0--success and 1 --un_success]
		echo "ping -c $BOOT_IPADDR SUCCESS [ FIRMWARE UP ]"
	else
		echo $failed_ping_msg
		Log_Error_To_AllPlatform_Test_report_And_Reset_Platform "PING failed ->(problem in FW download ??? or network connection ?? or firmware crash ??? ...)"
		#set_test_status $test_complete_colour TEST_COMPLETE
		exit $failed_ping
	fi
}

wait_cpe_ready()
{
        sleep 1 
        echo -e -n "reset\r" > $SERIAL_DEVICE
        
        if [ `cat $status_file` == stopping ]; then
		    echo "Server cancels test [current status: upload image done]"
            sleep 10 # this sleep required to ensure board is out from autoboot 
		    exit $stop_test
	    fi
         
    #sleep 70 # wait till test setup can ping the board (after 60-70s ) 
	#run_update $FLASH_FLASH_CMD # it is not stable in new test setup  
	#ping_dut
	#Code below do ping test until first successful ECHO reply
	a=0
    no_ping=1
	try_before_1st_success=60
	try_after_success=10
	while [ $a -lt $try_before_1st_success ]
	do
        	ping  -c 1 $BOOT_IPADDR
	        if [ $? -eq 0 ]
        	then
                no_ping=0
			    ping_dut $try_after_success
	            a=$try_before_1st_success
        	else
                no_ping=1
                a=$((a+1))
                echo "$a.ping"
	        fi
	done
    [ $no_ping -eq 1 ] && exit $failed_ping # failed kernel boot up
}

check_result()
{
	result=`cat $serial_read_write_result_log`
	
	if [ $1 == "set" ]; then
		printf "Setting variable(s): "
	elif [ $1 == "run" ]; then
		printf "Run update command(s): "
	fi
	
	if [ "$result" == "PASS" ];
	then
		echo "OK"
	else
		echo "NOT OK"
		Log_Error_To_AllPlatform_Test_report_And_Reset_Platform " uboot $1 cmd [ABORT SCRIPT] "
		#set_test_status $test_complete_colour TEST_COMPLETE
		exec 0<&3 # restore previous stdin.
		IFS=$BAKIFS #   and IFS.
		exit $image_update_failed
	fi
}

# Script starts here

usage() { echo "Usage: $0 [-b <board_config>] [-p <image_path>]" 1>&2; exit 1; }

while getopts ":b:p:" o; do
    case "${o}" in
        b)
            b=${OPTARG}
            ;;
        p)
            p=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${b}" ] || [ -z "${p}" ]; then
    usage
fi

Start_update_image()
{
	echo " ===== Uploading images [START] ==== " 
	
	. $board_path/${b}
	rm $BOARD_PATH/board_common.cfg
	ln -s $BOARD_PATH/${b} $BOARD_PATH/board_common.cfg
	
	#Image_exist_link

	Serial_port_init

	date +%d-%m-%Y_%H:%M:%S # start ticking
		
	./turn_dut_power.sh -b $b -s 'off'
        [ $? -gt 0 ] && exit $failed_ippwr
	./turn_dut_power.sh -b $b -s 'on'
        [ $? -gt 0 ] && exit $failed_ippwr
	Stop_boot_up

	Set_ip_lanpc

	# to record serial activity
	if [ -f serial_read_write_result_log ]; then	
		rm serial_read_write_result_log
		touch serial_read_write_result_log
	fi

	if [ "$UBOOT_ENABLE" == "enable" ];then
		if [[ -f $BOOT_TFTPBOOT/$p/$UBOOT_FILE && -f $BOOT_TFTPBOOT/$p/$GPHY_FILE ]];then
			echo "start update four images"
			Boot_param_set
			run_update $FOUR_IMAGES_UPDATE_CMD
			echo "finish update four images"
		else
			echo "start update fullimage"
			Image_exist_Boot_param_set
			run_update $FOUR_IMAGES_UPDATE_CMD
			echo "finish update fullimage"
		fi
                #sleep 1
		#echo "start update four images"
		#Boot_param_set
		#Image_exist_Boot_param_set
		#run_update $FOUR_IMAGES_UPDATE_CMD
		#echo "finish update four images"
	fi	

	date +%d-%m-%Y_%H:%M:%S # stop ticking
	
	echo " ===== Uploading images [END] ==== "
	
	wait_cpe_ready
	
	exit 0
	
}
	


Start_update_image

