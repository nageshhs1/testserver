#!/bin/sh
#configure local file
cgi_bin=cgi-bin
cgi_log=auto_log
livelog=$cgi_bin/$cgi_log/logfile.txt


#configure web server ( like apache server's absolute folders)
cgi_bin_path=/var/www/bin
html_path=/var/www/html

#web server default user and group account
web_user="www-data:www-data"
cur_user="dccom:dccom"

        echo "Link /bin/sh to /bin/bash  ..."
        if [ ! -e /bin/sh ]; then
           echo "add /bin/bash softlink"
           ln -s /bin/bash /bin/sh
        fi
        if [ "$(readlink -- "/bin/sh")" != /bin/bash ]; then
           echo "Relink /bin/sh"
           rm /bin/sh
           ln -s /bin/bash /bin/sh
        fi

cgi_bin_files=("auto_dispatch.cgi" "auto_free.cgi" "auto_status.cgi" "auto_stop.cgi" "auto_stopping_ps.sh" "auto_testing_ps.sh" "auto_live_log.pl" "auto_upload.cgi" "auto_download.cgi" "$cgi_log" );
#auto_log_files=("taskid.txt" "status.txt"); # automatically linked from "$cgi_log" in cgi_bin_files
html_files=("auto_free.html" "auto_dispatch.html" "auto_stop.html" "auto_upload.html" "test_setup.html" "ts_timer.htm" "auto_live_testcase.htm" "auto_live_status.htm") ;
#tss_files=("tss_console.htm" "tss_result.htm"); # automatically linked from $tss in tss_files

curr_src_pwd=`pwd`

touch html/auto_live_testcase.htm
touch html/auto_live_status.htm
sudo chown ${cur_user} html/auto_live_testcase.htm
sudo chown ${cur_user} html/auto_live_status.htm
chmod 755 $cgi_bin/auto_live_log.pl

pushd . # store original folder
[ ! -e $cgi_bin_path ] && mkdir $cgi_bin_path -p  && chown  ${web_user}  $cgi_bin_path -R 
[ ! -e $html_path ] && mkdir $html_path -p && chown  ${web_user}  $html_path  -R
[ ! -e $livelog ] && touch $livelog # used to update live console

#copy cgi_bin_path first
list_len=${#cgi_bin_files[@]};
#echo list_len=$list_len
cd $cgi_bin_path
for (( i=0; i<${list_len}; i++ ))
do
  ln -s ${curr_src_pwd}/$cgi_bin/${cgi_bin_files[$i]} -f
  chown ${web_user} ${cgi_bin_files[$i]} -R
done

touch $cgi_bin_path/$cgi_log/taskid.txt
touch $cgi_bin_path/$cgi_log/status.txt
# Both di and fr must have pair taskid for normal operation
touch $cgi_bin_path/$cgi_log/di.txt # dispatch task log
touch $cgi_bin_path/$cgi_log/fr.txt # free dispatched task`
chown ${web_user}  $cgi_bin_path/$cgi_log/di.txt
chown ${web_user}  $cgi_bin_path/$cgi_log/fr.txt
chown ${web_user}  $cgi_bin_path/$cgi_log/taskid.txt
chown ${web_user}  $cgi_bin_path/$cgi_log/status.txt
echo "free" > $cgi_bin_path/$cgi_log/status.txt


#copy html_files 
list_len=${#html_files[@]};
#echo list_len=$list_len
cd $html_path
for (( i=0; i<${list_len}; i++ ))
do
  #echo  ln -s  ${curr_src_pwd}/html/${html_files[$i]} -f
  ln -s  ${curr_src_pwd}/html/${html_files[$i]} -f
  chown ${web_user} ${html_files[$i]} -R
done


popd
