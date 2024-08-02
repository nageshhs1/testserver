#!/bin/sh 
in=$1 # update or set
f=$2  # HTML file
b=$3  # board id
w=$4  # wan mode
c=$5  # colour
s=$6  # status


function clean_up()
{
	exec 0<&3 # restore previous stdin.
	IFS=$BAKIFS #   and IFS.
	echo "update_test_status.sh CLEAN UP DONE"
	rm $f
	exit
}

trap clean_up SIGHUP SIGINT SIGTERM

update_status()
{
	lineno=$(grep -n $b  $f | grep $w)
    lineno=${lineno%%:*}
	#echo "lineno=$lineno"
	# replace the whole line with new status
	sed -i ''"$lineno"'s/.*/ <tr><td>'"$b"'<\/td><td>'"$w"'<\/td><td><strong><font style=\"color:'"$c"'\">'"$s"'<\/strong><\/td><\/tr> /' $f
	
}

set_status()
{
	# always set the last one in the table
	sed -i '/<\/table>/i <tr><td>'"$b"'</td><td>'"$w"'</td><td><strong><font style=\"color:'"$c"'\">'"$s"'</strong></td></tr>' $f
}

main()
{
	if [[ $in == 'update' ]]; then	
		update_status
	elif [[ $in == 'set' ]]; then
		set_status
	fi
		
}

main
#main set tss_status.htm 2 ptm green testing
