#!/bin/sh

killall update_image.sh 2>/dev/null
killall run_one_board.sh 2>/dev/null
killall run_boards.sh 2>/dev/null
killall ./auto_testing_ps.sh 2>/dev/null
killall perl 2>/dev/null
echo "finished" > ../web_gui/cgi-bin/auto_log/status.txt
