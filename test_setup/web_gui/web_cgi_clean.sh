#!/bin/sh
cgi_bin=cgi-bin
cgi_log=auto_log

#web server path( like apache server's absolute folders)
cgi_bin_path=/var/www/bin
html_path=/var/www/html

cgi_bin_files=("auto_dispatch.cgi" "auto_free.cgi" "auto_status.cgi" "auto_stop.cgi" "auto_stopping_ps.sh" "auto_testing_ps.sh" "auto_live_log.pl" "auto_upload.cgi" "auto_download.cgi" "$cgi_log" );
html_files=("auto_free.html" "auto_dispatch.html" "auto_stop.html" "auto_upload.html" "test_setup.html" "ts_timer.htm" "auto_live_status.htm" "auto_live_testcase.htm") ;

curr_src_pwd=`pwd`
pushd . # store original folder

#remove cgi_bin_path first
cd $cgi_bin_path
echo "remove cgi_bin_path first `pwd`"
list_len=${#cgi_bin_files[@]};
for (( i=0; i<${list_len}; i++ ))
do
  rm ${cgi_bin_files[$i]} -f
  #[ ${cgi_bin_files[$i]} = $cgi_log ] && sudo rm -rf ${cgi_bin_files[$i]}
done

#remove html_files 
cd $html_path
echo "remove html_files `pwd`"
list_len=${#html_files[@]};
#echo current working folder is `pwd`
for (( i=0; i<${list_len}; i++ ))
do
  rm ${html_files[$i]} -f
  #[  ${html_files[$i]} = $tss ] && sudo rm -rf  ${html_files[$i]}
done

popd
