#grep -e 'cells' co_result.log | cut -d: -f2 | awk '{print $1}'| awk 'NR%2{printf $0"";next;}1' > tmp
#cells=$(grep -e 'cells' $ppa_auto_testcase_log_folder/co_result.log | cut -d: -f2 | awk '{print $1}'| awk 'NR%2{printf $0"";next;}1')
max_pcr=100
if [ ! -f $ppa_auto_testcase_log_folder/co_result.log ]; then
        echo "why no packet result file: $ppa_auto_testcase_log_folder/co_result.log"
        report_quit $ppa_auto_result_fail;
fi
grep -e 'cells' $ppa_auto_testcase_log_folder/co_result.log | cut -d: -f2 | awk '{print $1}'| awk 'NR%2{printf $0"";next;}1' > tmp
cells=$(grep -e 'cells' $ppa_auto_testcase_log_folder/co_result.log | cut -d: -f2 | awk '{print $1}'| awk 'NR%2{printf $0"";next;}1')
if (( $($cells < $max_pcr) )); then
                echo "$ppa_auto_result_ok($cells)"
                report_quit "$ppa_auto_result_ok($cells)"
        else
                echo "$ppa_auto_result_fail($cells)"
                report_quit "$ppa_auto_result_fail($cells)"
        fi

#report_quit "$ppa_auto_result_fail"
