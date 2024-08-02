#!/bin/sh 
in=$1 # wanif 
f=../cfg/ppa_auto_env_setup



main()
{
    lineno=$(grep -n phy_wan_ifname0 $f)
    lineno=${lineno%%:*}
    echo "lineno=$lineno, wan_if=$in"
    sed -i ''"$lineno"'s/.*/phy_wan_ifname0='"$in"'; export phy_wan_ifname0/' $f 
}

main
