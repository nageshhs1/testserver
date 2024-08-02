#!/usr/bin/tclsh
#Source configuration file 
source import_cfg1.tcl

set frame_size {}
for {set index 0} { $index < [array size frameLength1] }  { incr index } {
	lappend frame_size $frameLength1($index)
	}


# Pass the parameters as arguments to next script
foreach value $frame_size {
	#puts $value
	
	set result [exec tclsh.exe performance.tcl -t [array get port] -r [array get wanport] -l $Load -f $value]
	#set result 1
	puts $result

	set filename "Loop_console_log.txt"
	set fileId [open $filename "a+"]
	puts -nonewline $fileId $result
	close $fileId
	} 	
 set last "Test Completed \n\n"
 set filename "TestResults.txt"
 set fileId [open $filename "a+"]
 puts -nonewline $fileId $last
 close $fileId
 set filename "Algorithm_log.txt"
 set fileId [open $filename "a+"]
 puts -nonewline $fileId $last
 close $fileId