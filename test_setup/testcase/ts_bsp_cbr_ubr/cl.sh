declare -a br_list
br_list=$(ls /proc/sys/net/ipv4/conf/ | grep "br")
for i in ${br_list[@]}
do
brctl delbr $i
done 
#echo "$br_list"
