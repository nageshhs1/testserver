#!/usr/bin/tclsh
# Commented Print commands are for debugging purpose 
source cfg.tcl
set frame_size {}
source import_cfg2.tcl
append frame_size $frameLength
lappend frame_size 0
#puts "FL:$frameLength Load:$Load"
set z 0
set n [lindex $frame_size $z]


while {n != 0} {
	set n [lindex $frame_size $z]
	set frameLengh $n
	if {$frameLengh == 0} {
		#puts "FL:$frameLengh"
		#puts "Run Completed"
		break
	}
	after 2000
	#puts "next"
	set result [exec tclsh.exe transmit.tcl -t [array get port] -l $Load -f $frameLength -r [array get wanport]]
	
	#puts $result 
	set isMatch_Error [string match "Error caught" $result]
	if {$isMatch_Error != 0 } {
	puts $result
	exit 0 
	}
	
	#puts "[lindex $result 0]"
	#puts "[lindex $result 1]"
	array set dr [lindex $result 0]
	array set dp [lindex $result 1]
	
	#puts [array get dr]
	#puts $dr(0)
	#puts $dr(1)
	set sum 0
	for { set index 1} {$index <= [array size dr]} {incr index} {
	        #puts $dr($index)
			set sum [ expr {$sum + $dr($index)}]
        		}
	set drop [expr { $sum/[array size dr]}]
	#puts "drop:$drop"

	#exit 0	
	set sum 0.0 
	for { set index 1} {$index <= [array size dp]} {incr index} {
			set sum [ expr {$sum + $dp($index)}]   		
		}
	#puts $sum
	set test_status [expr { $sum/[array size dp]}]
	#puts "test_status:$test_status"
	
	set x 0.0

	puts " Frame_size: $frameLengh \tMin_load: [format "%.12f" $Load_min] \tMax_load: [format "%.12f" $Load_max] \tLoad: [format "%.12f" $Load] \tDrop_count: $drop \t\tDrop_per: $test_status" 
	set temp " Frame_size: $frameLengh \tMin_load: [format "%.12f" $Load_min] \tMax_load: [format "%.12f" $Load_max] \tLoad: [format "%.12f" $Load] \tDrop_count: $drop \t\tDrop_per: $test_status\n"
	set filename "Algorithm_log.txt"
	set fileId [open $filename "a+"]
	puts -nonewline $fileId $temp
	close $fileId 
	if {$drop == 0} {
       #puts "Drop count is $drop"
	   if { $Load == $Load_max } {
			 puts "$test_status <= $resolution && $test_status != 0 For Load: $Load%"
	         set last "Fame Size : $frameLengh, Supported Load : $Load %, DroppedFramePercent :$test_status\n"
	         set filename "TestResults.txt"
             set fileId [open $filename "a+"]
             puts -nonewline $fileId $last
             close $fileId
	         set z [expr {$z + 1}]
			 } else {
						set Load_min $Load
						set Load [expr {(($Load_max + $Load_min)/2)}]  
						#puts "Increase Load: $Load"
					}
		} else {
				if {$test_status < $resolution} {
						puts "$test_status <= $resolution && $test_status != 0 For Load: $Load%"
						set last "Frame Size : $frameLengh, Supported Load : $Load %, DroppedFramePercent :$test_status\n"
						set filename "TestResults.txt"
						set fileId [open $filename "a+"]
						puts -nonewline $fileId $last
						close $fileId
						set z [expr {$z + 1}]
					} else {
								set Load_max $Load
								set Load [expr {(($Load_max + $Load_min)/2)}]
								#puts "reduce load"
								#puts $Load
						}
				}
	#puts " Frame_size: $frameLengh Min_load: $Load_min Max_load: $Load_max Load: $Load Drop_count: $drop Drop_per: $test_status" 		
	set n [lindex $frame_size $z]
	after 1000
	if {$Load < 0.001} {
			puts " Load is below the spirent resolution"
			exit
		}
	}
