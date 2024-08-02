#!/bin/sh

# For logging and reporting

# Taken from ALL_PLATFORM_TEST.sh
test_complete_colour="Blue"        export test_complete_colour
test_halt_colour="Red"             export test_halt_colour
test_running_colour="Green"        export test_running_colour

# aborted test code
testabort=                                           export testabort
testabort_msg=                                       export testabort_msg
image_update_failed=1                                export image_update_failed
image_update_failed_msg="uboot crash"                export image_update_failed_msg
#missing_files=2                   export missing_files
missing_uboot=21                                     export missing_uboot
missing_bootcore=22                                  export missing_bootcore
missing_fullimage=23                                 export missing_fullimage
missing_gphy_file=24                                 export missing_gphy_file
missing_uboot_msg="missing u-boot-nand image"        export missing_uboot_msg
missing_bootcore_msg="missing bootcore image"        export missing_bootcore_msg
missing_fullimage_msg="missing fullimage"            export missing_fullimage_msg
missing_gphy_file_msg="missing gphy_file"            export missing_gphy_file_msg
stop_test=3                                          export stop_test
stop_test_msg="test is forced stop"                  export stop_test_msg
failed_boot=4                                        export failed_boot
failed_boot_msg="DUT is off or uboot failed to stop" export failed_boot_msg
failed_ping=5                                        export failed_ping
failed_ping_msg="ping failed after linux bootup"     export failed_ping_msg
failed_ippwr=6                                       export failed_ippwr
failed_ippwr_msg="IP power switch failed"            export failed_ippwr_msg

# start.sh failed 
s_softlink_issue=30                                  export s_softlink_issue
s_softlink_issue_msg="ppacfg softlinks not found"    export s_softlink_issue_msg
s_ppa_auto_proxy_cpe_issue=31                        export s_ppa_auto_proxy_cpe_issue
s_ppa_auto_proxy_cpe_issue_msg="ppa auto proxy cpe not found"   export s_ppa_auto_proxy_cpe_issue_msg
s_ping_failed=32                                     export s_ping_failed
s_ping_failed_msg="start.sh ping failed"             export s_ping_failed_msg
s_dsl_failed=33                                      export s_dsl_failed
s_dsl_failed_msg="DSL failed to showtime"            export s_dsl_failed_msg

# access to cfg/ppa_auto_testcase_env
testreport=tmp_start.htm           export testreport # same as ppa_auto_tmp_result_log
fwversi=/tmp/version               export fwversi    # same as global_ppa_version_file

# reporting path/file
status_file=../web_gui/cgi-bin/auto_log/status.txt             export status_file
html_status_file=../web_gui/html/auto_live_status.htm          export html_status_file
html_result_file=../web_gui/html/auto_live_testcase.htm        export html_result_file
html_console_logfile=../web_gui/cgi-bin/auto_log/logfile.txt   export html_console_logfile
live_html_status=./update_html.sh                              export live_html_status
update_wanif=./update_wanif.sh                              export update_wanif
