#!/bin/sh
#load


function clean_up()
{
	exec 0<&3
	IFS=$BAKIFS
	exit 0
}

trap clean_up SIGHUP SIGINT SIGTERM

read_cpe_console()
{
	sudo stty -F $SERIAL_DEVICE raw ispeed $BAUDRATE ospeed $BAUDRATE -ignpar cs8 -cstopb -echo

	BAKIFS=$IFS
	exec 3<&0
	exec 0<"$SERIAL_DEVICE"
	while read -r -t 10000 line
	do
		echo "$line" 
	done
}

read_cpe_console
