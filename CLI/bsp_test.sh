#!/bin/bash

REMOTE_LOCATION=/tftpboot
IP_ADDR="10.226.45.48"
config_folder="/home/$USER"
image_path="bin/lantiq"
Sub_type="standard"
image_name="fullimage.img"
wan_mode="ETH"
test_type="Smoke"
meta_info=
tc_file="TG_BSP_ALL"

#Check for intel/lantiq model and initialize image/model paths.
function model()
{
    current=$(pwd)
    if [ -d $current/bin ]; then
	chk_wrt=$(ls $current/bin | grep intel_mips)
    else
	chk_wrt="lantiq"
    fi
    if [ $chk_wrt == 'intel_mips' ]; then
        echo "$chk_wrt is present taking fullimage for test."
	model=`cat $current/active_config` 
	[ "$model" == "" ] && echo "No model selected yet" && exit -1
	model=${model##*/}
        image_path="$current/bin/$chk_wrt"
	#model_path="GRX350"
	model_path=$(echo "$model" | tr '[:lower:]' '[:upper:]')
        echo "this is model_path:$model_path"
        model="GRX350"
        #active_model="GRX350"
        active_model=$model
        meta_info="GRX350_fullimage_test"
        echo $active_model
    else
	model=`cat active_config` 
	[ "$model" == "" ] && echo "No model selected yet" && exit -1
	model=${model##*/}
        image_path="bin/lantiq"
	model_path=$(echo "$model" | tr '[:upper:]' '[:lower:]')
        echo $model_path
        active_model=$model
        echo $active_model
    fi
}

function metainfo()
{
    cd ../../
    meta_info=$(hg log -r "." --template "{latesttag}\n")
    echo $meta_info
    cd -
}

function upload()
{
    if [ -f $image_path/uImage_bootcore ]; then
        bootcore="$image_path/uImage_bootcore"
    else
        bootcore="$image_location/uImage_bootcore"
    fi      
    
    file=$bootcore;
    [ ! -f $file ] && echo "Error: $file not found" && exit 1;
    file=$image_location/fullimage.img
    [ ! -f  $file ] && echo "Error: $file not found" && exit 1;
    fullimage=$file
    file=$image_location/u-boot-nand.bin
    [ ! -f $file ] && echo "Error: $file not found" && exit 1;
    uboot=$file

    file=$image_location/gphy_firmware.img
    [ ! -f $file ] && echo "Error: $file not found" && exit 1;
    gphy=$file

    curl -F filename=@"$fullimage" -F file_dir="$REMOTE_LOCATION/$time_tag" http://$IP_ADDR/cgi-bin/auto_upload.cgi
    [ $? -ne 0 ] && echo "Error: upload $fullimage failed" && exit 1;

    curl -F filename=@"$uboot" -F file_dir="$REMOTE_LOCATION/$time_tag" http://$IP_ADDR/cgi-bin/auto_upload.cgi
    [ $? -ne 0 ] && echo "Error: upload $uboot failed" && exit 1;

    curl -F filename=@"$bootcore" -F file_dir="$REMOTE_LOCATION/$time_tag" http://$IP_ADDR/cgi-bin/auto_upload.cgi
    [ $? -ne 0 ] && echo "Error: upload $bootcore failed" && exit 1;

    curl -F filename=@"$gphy" -F file_dir="$REMOTE_LOCATION/$time_tag" http://$IP_ADDR/cgi-bin/auto_upload.cgi
    [ $? -ne 0 ] && echo "Error: upload $gphy failed" && exit 1;

    #trigger test task request
    curl -F image="$time_tag" -F model="$model" -F user="$user" -F email="$email" -F wan[]="$wan_mode" -F ttype="$test_type" -F stype="$Sub_type" -F meta="$meta_info" -F tc_grp="$tc_file" -F action="Submit" http://$IP_ADDR/testserver/insert.php
    [ $? -ne 0 ] && echo "Error: Automation Task submitted failed" && exist 1;
    #Copy current image build time to temp_time 
    echo $curr_image_time > $image_location/temp_time
}

function upload_fullimage()
{
    file=$image_location/fullimage.img
    [ ! -f  $file ] && echo "Error: $file not found" && exit 1;
    fullimage=$file

    curl -F filename=@"$fullimage" -F file_dir="$REMOTE_LOCATION/$time_tag" http://$IP_ADDR/cgi-bin/auto_upload.cgi
    [ $? -ne 0 ] && echo "Error: upload $fullimage failed" && exit 1;

    #trigger test task request
    curl -F image="$time_tag" -F model="$model" -F user="$user" -F email="$email" -F wan[]="$wan_mode" -F ttype="$test_type" -F stype="$Sub_type" -F meta="$meta_info" -F tc_grp="$tc_file" -F action="Submit" http://$IP_ADDR/testserver/insert.php
    [ $? -ne 0 ] && echo "Error: Automation Task submitted failed" && exist 1;
    #Copy current image build time to temp_time 
    echo $curr_image_time > $image_location/temp_time

}

function usage()
{
    echo usage:
        echo " 1. -w  [wan] "
        echo " wan options:ETH(Default)/ATM/PTM/PTM_BONDING/*"
        echo " 2. -t [test type] "
        echo "test type: Smoke(Default)/Full/MPE/"
        echo " 3. -m [meta info] "
        echo "meta info: UGW version name"
        echo " 4. -u [username] "
        echo " 5. -e [email address] "
        echo " 6. -U [username] "
        echo " 7. -E [email address] "
        echo " To send e-mail to multiple users - add ',' between e-mail ids within double quotes"
        echo " Usage:  -E [email address-1],[email address-2],[email address-3], .. "
        echo " 8. -p [buildbot path] "
        echo " 9. -f [TestCase filename] "
}

opts_list="hw:t:m:u:e:U:E:p:f:w:"
while getopts ${opts_list} OPTION
do
case $OPTION in
    h)  
        usage
        exit 1
        ;;
    w)
        wan_mode=$OPTARG    
        echo "-w=$wan_mode"
        ;;

    t)  
        test_type=$OPTARG    
        echo "-t=$test_type"
        ;;

    m)  
        meta_info=$OPTARG
        ;;
    u)  
	user=$OPTARG
	USERNAME=$OPTARG
	save_user_account=1	        
        ;;
    U)  	
        user=$OPTARG
        ;;	
    e) 
        email=$OPTARG
	EMAIL=$OPTARG
	save_user_account=1
        ;;
    E)  	
        email=$OPTARG
        ;;
    p)
        buildbot_path=$OPTARG
        echo "$buildbot_path"
        copy_from_buildbot=1
        ;;
    f) 
        tc_file=$OPTARG
        echo "-f=$tc_file"
        ;;

    ?)  
        usage
        exit
        ;;
esac
done


[ ! -e $config_folder ] && echo "$config_folder not exist" && exit -1

if [ -e $config_folder/.bsp_test.cfg ]; then
    source $config_folder/.bsp_test.cfg
	if [ "$user" == "" ]; then
		user=$USERNAME;
		echo user=$user
	fi
	if [ "$email" == "" ]; then
		email=$EMAIL;
		echo email=$email
	fi
fi

save_user_account=0
if [ "$user" == "" ]; then
    read -p "Username: " user
    if [ "$user" == "" ]; then
        user=$(whoami)
    fi
	USERNAME=$user
	save_user_account=1
fi

while [ "$email" == "" ]
do
    echo "Please provide e-mail id"
    read -p "E-Mail id: " email
    EMAIL=$email
    save_user_account=1
done

if [ $save_user_account -eq 1 ]; then
	echo "Need save username/email to configuration file"
	echo "USERNAME=$USERNAME" > $config_folder/.bsp_test.cfg
	echo "EMAIL=$EMAIL" >> $config_folder/.bsp_test.cfg
fi

if [[ $copy_from_buildbot == 1 ]];then
        path1="$(echo $buildbot_path | grep RX | cut -d/ -f7 )"
        path2=$(echo "$path1" | tr '[:upper:]' '[:lower:]')
        echo $path2,$path1
        #Image download URLs from buildbot
        url="$buildbot_path$image_path/$path2/fullimage.img"
        url2="$buildbot_path$image_path/$path2/u-boot-nand.bin"
        url3="$buildbot_path$image_path/$path2/gphy_firmware.img"
        url4="$buildbot_path$image_path/$path2/uImage"
        local_dirct="/tftpboot/$path2"
        image_path="/tftpboot"
        model_path="$path2"
        model="$path1"
        echo "$image_path,$model_path"
else
        echo "Normal mode copy image from tftp"
        model
fi

function download()
{
        wget -m $url -nd -P $local_dirct
        [ $? -ne 0 ] && echo "Error: Download $url failed" && exit 1;
        wget -m $url2 -nd -P $local_dirct
        [ $? -ne 0 ] && echo "Error: Download $url2 failed" && exit 1;
        wget -m $url3 -nd -P $local_dirct
        [ $? -ne 0 ] && echo "Error: Download $url3 failed" && exit 1;
        wget -m $url4 -nd -P $local_dirct
        [ $? -ne 0 ] && echo "Error: Download $url4 failed" && exit 1;
        sudo chmod a+rwx /tftpboot/$path2/ -R
        if [ "$local_dirct/uImage" ]; then
              mv $local_dirct/uImage $local_dirct/uImage_bootcore
        fi
}

function delete_intel_mips()
{
if [ $chk_wrt == 'intel_mips' ]; then
        if [ -d $image_path/$model_path ]; then
           echo "DIR:$image_path/$model_path already exists..."
           sudo rm -rf $current/bin/$chk_wrt
        fi
fi
}
#model

#Check Intel_mips directory exists
if [ $chk_wrt == 'intel_mips' ]; then
	if [ -d $image_path/$model_path ]; then
	   echo "DIR:$image_path/$model_path Exists"
	else
	   sudo mkdir $image_path/$model_path
	   sudo chmod 777 $image_path/$model_path -R
	fi
	#sudo cp $image_path/openwrt-intel_mips-xrx500-EASY350-fullimage.img $image_path/$model_path/fullimage.img
	sudo cp $image_path/*.img $image_path/$model_path/fullimage.img
fi

#Check image directory exists
if [ -e $image_path ]; then
  image_location=$image_path/$model_path
  echo $image_location
else
  echo "Image Dir-'$image_path' not exists"
  exit
fi

#Check images are built
if [ -d ${image_path/$model_path} ]; then
	cd $image_path/$model_path
        curr_image_time=$(ls -lrt | grep "fullimage.img" | awk '{print $6 $7 $8}')
        cd -
else
  echo "Fullimage path-'$image_path/$model_path' not exists"
  exit
fi

echo "curr=$curr_image_time"

server_time=$(curl http://$IP_ADDR/testserver/timetag.php)
if [ $server_time ]; then
	time_tag=$server_time'_'$user'_'$model
	echo $time_tag
else
	echo "Test Server not reachable"
	exit
fi
if [ "$meta_info" ==  "" ]; then
	metainfo
fi
flag=0
dflag=0

if [ -e $image_location/temp_time ]; then
    prev_image_time=`cat $image_location/temp_time`
else
    prev_image_time=
fi

if [[ "$curr_image_time" == "$prev_image_time" && $copy_from_buildbot == 1 ]]; then
    echo "No change in the built image"
    read -p "Do you want to Download from Buildbot again (y/n)?" CONTD
    if [ "$CONTD" == "y" ]; then
        echo $image_location
        #exit
        if [[ -d $image_location && $path2 != "" ]]; then
             echo "Folder exist: $image_location"
             sudo rm -rf $image_location
        fi 
        echo $path1
        download
        dflag=1
    else
        echo "Using the existing $path2 images to create the task"
        dflag=1
    fi
fi
#Below check added to avoid duplicate creation of task
if [[ $dflag -eq 0 && $copy_from_buildbot == 1 ]]; then
        echo $image_location
        if [[ -d $image_location && $path2 != "" ]]; then
             echo "Folder exist: $image_location"
             sudo rm -rf $image_location
        fi
        download
fi

if [ "$curr_image_time" == "$prev_image_time" ]; then
    echo "No change in the built image"
    read -p "Do you want to upload again (y/n)?" CONT
    if [ "$CONT" == "y" ]; then
        upload
	flag=1
    else
        exit
    fi
fi
#Below check added to avoid duplicate creation of task
if [ $flag -eq 0 ] && [ $chk_wrt == 'intel_mips' ]; then
	upload_fullimage
	exit
else
	upload
	exit
fi
