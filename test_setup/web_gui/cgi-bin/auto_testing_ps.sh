#!/bin/sh

echo "$0" > test.txt
#sleep 1
if [ -e /test_setup/bin/run_boards.sh ]; then
   cd /test_setup/bin
   sudo ./run_boards.sh $1
fi
#echo "finished" > auto_log/status.txt
