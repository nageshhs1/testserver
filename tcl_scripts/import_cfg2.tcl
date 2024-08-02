source cfg.tcl
set arglen [llength $argv]

#Counters for the index values of different parameters 
set index 0
set y 1
set z 1
set i 0
set j 1

set Length($i) 256
 
while {$index < $arglen} {
    set arg [lindex $argv $index]
	#puts $arg
    switch -exact -- $arg {
        -s {
            set args($arg) [lindex $argv [incr index]]
			set slot($y) $args($arg)
			incr y
        }
		-t {
            set args($arg) [lindex $argv [incr index]]
			#puts [llength $args($arg)]
			if {[llength $args($arg)] > 1} {
			foreach val $args($arg) {
				#puts $val 
				if {[regexp {[0-9]/[0-9]?} $val temp]} {
					set port($z) $val
					incr z
					}
			}
			} else {set port($z) $args($arg)
			incr z
			}
        }
		-r {
            set args($arg) [lindex $argv [incr index]]
			#puts [llength $args($arg)]
			if {[llength $args($arg)] > 1} {
			foreach val $args($arg) {
				#puts $val 
				if {[regexp {[0-9]/[0-9]?} $val temp]} {
					set wanport($j) $val
					incr j
					}
			}
			} else {set wanport($j) $args($arg)
			incr j
			}
			
        }
        -l {
            set args($arg) [lindex $argv [incr index]]
			global Load
			set Load $args($arg)
			}
		-g {
            set args($arg) [lindex $argv [incr index]]
			#puts " Frame array size"
			#puts [llength $args($arg)]
			if {[llength $args($arg)] > 1} {
			array set Length $args($arg)
			} else {
			set Length($i) $args($arg)
			incr i
			}
			}
		-f {
              set args($arg) [lindex $argv [incr index]]
			  #puts [llength $args($arg)]
			  #global Length
			  set frameLength $args($arg)
			}	
				
        
    }
    incr index
}

