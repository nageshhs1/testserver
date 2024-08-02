#!/bin/sh

#load global env 
. ../cfg/cpe_env_global
. ../cfg/ppa_auto_env
. ../cfg/ppa_auto_testcase_env

tmp_bin=`pwd`
echo "tmp_bin=$tmp_bin"
#PATH=$PATH:$tmp_bin/../bin/

#overwritten ppa_auto_path in this file
ppa_auto_tool=../bin/ppa_auto_tool
iperf=../bin/iperf

ifconfig $ppa_auto_if_cpe up

download_one_level_folder()
{ #$1: source folder
  #$2: dst folder

  #echo `pwd`
  local folder=""
  local wan

  #pushd .  #don't know why in ubuntu some times not work, but in fedora ok
  #cd $1   
  files=`ls $1`
  #echo files=$files
  for f in $files
  do
    if [ -f $1/$f ]; then
       #echo "to dowload file $1/$f to folder $2"
       download_file $1/$f $2  
    fi
  done 


  #popd 
  #cd ..
}

echo "Running One Time Script: Interface=$1 Server_id=$2"
echo "Current Folder: `pwd` "
interface=$1
server_id=$2

ifconfig $ppa_auto_if_cpe up
ifconfig $ppa_auto_if_wan  up

echo "Run One_time_script..."
download_file "../bin_cpe/cpe_cfg_reset.sh" "/var/cpe_cfg_reset.sh" "run"


#download ppa_auto_env
echo "download ppa_auto_env "
download_file "../cfg/ppa_auto_env" "/var/ppa_auto_env" 

#remove wave300 wlan from PPA directpath, otherwise it will cause crash
echo "$ppa_auto_tool -i $interface -n $ppa_auto_name -t cpe -c cmd -s rmmod mtlk -d "" -g $ppa_auto_debug -r $server_id"
$ppa_auto_tool -i $interface -n $ppa_auto_name -t cpe -c cmd -s "rmmod mtlk" -d "" -g $ppa_auto_debug -r $server_id
$ppa_auto_tool -i $interface -n $ppa_auto_name -t cpe -c cmd -s "$br2684_path -k 0" -d "" -g $ppa_auto_debug -r $server_id
$ppa_auto_tool -i $interface -n $ppa_auto_name -t cpe -c cmd -s "$br2684_path -k 1" -d "" -g $ppa_auto_debug -r $server_id
$ppa_auto_tool -i $interface -n $ppa_auto_name -t cpe -c cmd -s "$br2684_path -k 2" -d "" -g $ppa_auto_debug -r $server_id
$ppa_auto_tool -i $interface -n $ppa_auto_name -t cpe -c cmd -s "$br2684_path -k 3" -d "" -g $ppa_auto_debug -r $server_id
$ppa_auto_tool -i $interface -n $ppa_auto_name -t cpe -c cmd -s "$br2684_path -k 4" -d "" -g $ppa_auto_debug -r $server_id
$ppa_auto_tool -i $interface -n $ppa_auto_name -t cpe -c cmd -s "$br2684_path -k 5" -d "" -g $ppa_auto_debug -r $server_id
$ppa_auto_tool -i $interface -n $ppa_auto_name -t cpe -c cmd -s "rm -f $br2684_param_file_last*" -d "" -g $ppa_auto_debug -r $server_id


#Note: dwatch will monitor mini_httpd and re-spawn it found mini_httpd down. 
#So need to kill dwatch process first, then kill mini_httpd.
#$ppa_auto_tool -i $interface -n $ppa_auto_name -t cpe -c cmd -s "killall -9 dwatch"     -d "" -g $ppa_auto_debug -r $server_id
#$ppa_auto_tool -i $interface -n $ppa_auto_name -t cpe -c cmd -s "killall -9 mini_httpd" -d "" -g $ppa_auto_debug -r $server_id

$ppa_auto_tool -i $interface -n $ppa_auto_name -t cpe -c cmd -s "insmod /lib/modules/*/ip6_tables.ko"      -d "" -g $ppa_auto_debug -r $server_id
$ppa_auto_tool -i $interface -n $ppa_auto_name -t cpe -c cmd -s "insmod /lib/modules/*/ip6table_mangle.ko" -d "" -g $ppa_auto_debug -r $server_id

#disable Switch VLAN aware
$ppa_auto_tool -i $interface -n $ppa_auto_name -t cpe -c cmd -s "switch_cli GSW_CFG_SET bVLAN_Aware=0" -d "" -g $ppa_auto_debug -r $server_id

#Copy iperf to CPE
$ppa_auto_tool -i $interface -n $ppa_auto_name -t cpe -c put -s "$iperf" -d "/var/" -g $ppa_auto_debug -r $server_id

if [[ -n $(find . -name "ts_bsp_*") ]]; then 
	echo "MPE FW not installed as ts_bsp_* directory found " 
else
	#Need to kill below process only for MPE automation
	#Note: dwatch will monitor mini_httpd and re-spawn it found mini_httpd down. 
	#So need to kill dwatch process first, then kill mini_httpd.
	$ppa_auto_tool -i $interface -n $ppa_auto_name -t cpe -c cmd -s "killall -9 dwatch"     -d "" -g $ppa_auto_debug -r $server_id
	$ppa_auto_tool -i $interface -n $ppa_auto_name -t cpe -c cmd -s "killall -9 mini_httpd" -d "" -g $ppa_auto_debug -r $server_id
	echo "No BSP cases install MPEFW"
	# Execute MPE FW initialisation for fast hook
	download_file "../bin_cpe/mpe_init.sh" "/var/mpe_init.sh"  "run"
fi
