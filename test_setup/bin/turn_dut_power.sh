#!/bin/sh
. ../cfg/log_report.sh
ON=1
OFF=0
sleep3=3
when=

usage() { echo "Usage: $0 [-b <board_config>] [-s <on_off>]" 1>&2; exit 1; }

while getopts ":b:s:" o; do
    case "${o}" in
        b)
            b=${OPTARG}
            ;;
        s)
            s=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${b}" ] || [ -z "${s}" ]; then
    usage
fi

. ../board/${b}

echo "IP_POWER_MODEL_CPE: $IP_POWER_MODEL_CPE (ip=$IP_POWER_IPADDR_CPE)"

if [ ${s} == "on" ]; then
        a=$SECONDS
	sudo wget -nv -r http://$IP_POWER_USER_CPE:$IP_POWER_PASS_CPE\@$IP_POWER_IPADDR_CPE/$IP_POWER_HTTP_POST_CPE$IP_POWER_PORT_CPE=$ON;
        [ $? -gt 0 ] && echo "power on failed" && exit $failed_ippwr 
        waiting=$(( SECONDS - a ))
        when=`date +%d-%m-%Y_%H:%M:%S`
	echo "DUT is ON: $when"		
elif [ ${s} == "off" ]; then
        a=$SECONDS
	sudo wget -nv -r http://$IP_POWER_USER_CPE:$IP_POWER_PASS_CPE\@$IP_POWER_IPADDR_CPE/$IP_POWER_HTTP_POST_CPE$IP_POWER_PORT_CPE=$OFF;
	#Below sleep added in-between board power off->on
        [ $? -gt 0 ] && echo "power off failed" && exit $failed_ippwr 
        waiting=$(( SECONDS - a ))
	sleep 2
        when=`date +%d-%m-%Y_%H:%M:%S`
        echo "DUT is OFF: $when"
fi

if [ $waiting -gt $sleep3 ]; then  
  echo "TOO LONG: waiting $waiting secs" 
  exit $failed_ippwr
fi
