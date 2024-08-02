#unload PPA's MPE FW
ppa_mpe_f=$(cat /proc/ppa/mpe/accel | grep -i enable)
if [ "$ppa_mpe_f" != "" ]; then   
   echo "start to unload PPA's MPE FW---------------------------"
   ifconfig ath0 down
   ppacmd dellan -i ath0
   iwpriv ath0 ppa 0 
   wlanconfig ath0 destroy   
   [ -e /etc/rc.d/rc.wlan ] && /etc/rc.d/rc.wlan down
   ppacmd exit
   rmmod dlrx_fw.ko
   rmmod ltqmips_dtlk.ko
   sleep 3
   echo unload > /proc/ppa/mpe/fw
   sleep 1
   echo "Finished to unload PPA's MPE FW---------------------------"
fi
#load MPE FASTHOOK's MPE FW
ppa_mpe_f=$(cat /proc/mpe/mpefw_load_dbg | grep "MPE FW")
if [ "$ppa_mpe_f" == "" ]; then
    echo enable cpu mpe1 > /proc/dp/parser
    echo /lib/firmware/mpe_fw_be.img 1 > /proc/mpe/start_mpfw
    sleep 1
    echo enable > /proc/mpe/pae
    echo set 0 > /proc/mpe/mpedbg
fi	
