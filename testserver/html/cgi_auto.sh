#!/bin/bash
#configure local file
cgi_bin=cgi-bin
cgi_log=auto_log
livelog=$cgi_bin/$cgi_log/logfile.txt

#configure web server ( like apache server's absolute folders)
cgi_bin_path=/var/www/bin
html_path=/var/www/html
results_path=/testserver/db/log/task/

#web server default user and group account
web_user="www-data:www-data"
cur_user="dccom:dccom"

#cgi_bin_files=("auto_dispatch.cgi" "auto_free.cgi" "auto_status.cgi" "auto_stop.cgi" "auto_stopping_ps.sh" "auto_testing_ps.sh" "auto_live_log.pl" "auto_upload.cgi" "auto_download.cgi" "$cgi_log" );
cgi_bin_files=("auto_dispatch.cgi" "auto_upload.cgi" "auto_download.cgi" );

ln -s $results_path results
chown ${web_user} results -R
chmod a+rwx results -R

curr_src_pwd=`pwd`

pushd . # store original folder
[ ! -e $cgi_bin_path ] && mkdir $cgi_bin_path -p  && chown  ${web_user}  $cgi_bin_path -R
#[ ! -e $html_path ] && mkdir $html_path -p && chown  ${web_user}  $html_path  -R

cd $html_path
ln -s ${curr_src_pwd} testserver
chown ${web_user} testserver -R
chmod a+rwx testserver -R

#copy cgi_bin_path first
list_len=${#cgi_bin_files[@]};
#echo list_len=$list_len
cd $cgi_bin_path
for (( i=0; i<${list_len}; i++ ))
do
  ln -s ${curr_src_pwd}/$cgi_bin/${cgi_bin_files[$i]} -f
  chown ${web_user} ${cgi_bin_files[$i]} -R
done

popd
