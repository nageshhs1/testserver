source cfg.tcl
set arglen [llength $argv]

#Counters for the index values of different parameters 
set index 0
set y 1
set z 1
set i 0
set j 1

set frameLength1($i) $frameLength

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
			set port($z) $args($arg)
			incr z
        }
		-r {
            set args($arg) [lindex $argv [incr index]]
			set wanport($j) $args($arg)
			incr j
        }
        -l {
            set args($arg) [lindex $argv [incr index]]
			global Load
			set Load $args($arg)
			}
		-f {
            set args($arg) [lindex $argv [incr index]]
			set frameLength1($i) $args($arg)
			incr i
			}	
        
    }
    incr index
}

