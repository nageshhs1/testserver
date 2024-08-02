source cfg.tcl
set arglen [llength $argv]
#puts "arglen:$arglen"

#Counters for the index values of different parameters 
set index 0
set y 1
set z 1
set i 0
set j 1
set Length($i) 256
#set Load 100
#puts [array get wanport]
#puts "Entered the 3rd cfg"

#puts [array get wanport]
while {$index < $arglen} {
    set arg [lindex $argv $index]
	#puts $arg
    switch -exact -- $arg {
        -s {
            set args($arg) [lindex $argv [incr index]]
			#puts "S info"
			set slot($y) $args($arg)
			incr y
           }
		-t {
            set args($arg) [lindex $argv [incr index]]
			#puts $args($arg)
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
			if {[llength $args($arg)] > 1} {
				foreach val $args($arg) {
					if {[regexp {[0-9]/[0-9]?} $val temp]} {
							set wanport($j) $val
					 		incr j
						}
				}
			} else { 
			    if {$args($arg) != ""} {
					set wanport($j) $args($arg)
					#puts [array get wanport]
					incr j
					}
				
			}
        }
        -l {
            set args($arg) [lindex $argv [incr index]]
			global Load
			set Load $args($arg)
			}
		-g {
            set args($arg) [lindex $argv [incr index]]
			if {[llength $args($arg)] > 1} {
			array set Length $args($arg)
			} else {
			set Length($i) $args($arg)
			incr i
			}
			}
        -f {
              set args($arg) [lindex $argv [incr index]]
			  set frameLength $args($arg)
			}			
        
    }
    incr index
}

#set frameLengh $Length
#puts "wanport1:$wanport(1)"
if {[catch {set temp $port(1)}]} {
    puts "No Port info"
    }

set Tcount [array size port]
set WANcount [array size wanport]
#puts "WANcount:$WANcount"
#puts [array get wanport]
if {$WANcount == 0} {
    array set wanport [array get port]
	set WANcount $Tcount
	}
set LANPorts {}
#puts [array get wanport]
for { set index 1 }  { $index <= [array size port] }  { incr index } {
   #puts "port($index) : $port($index)"
   lappend LANPorts $port($index)
}
set WANPorts {}
for { set index 1 }  { $index <= [array size wanport] }  { incr index } {
   #puts "port($index) : $port($index)"
   lappend WANPorts $wanport($index)
}
set PortCount $Tcount
#puts [array get wanport]
#puts $WANPorts
set count 0
set z 1
set WANIPList(0) $Start_WANIP_Prefix$count

while {$count < $Tcount} {
      #puts [lindex $LANPorts $count]
      set var LANPort[lindex $LANPorts $count]
	  set LANIPList($z) $Start_LANIP_Prefix$count
	  if {$WANcount == $Tcount} {
		set WANIPList($z) $Start_WANIP_Prefix$count
	  } else {
	         
	         set WANIPList($z) $WANIPList([expr {$z - 1}])
	         
			 }
	  set UdpsourcePort($z) [expr { $UdpstartingPort + $z }]
	  set UdpDestPort($z) [expr { $UdpstartingPort + $z }]
	  set LANPortLocList($z) [lindex $LANPorts $count]
	  
	  set LANPortMACList($z) $LANMACPrefix$z
	  set WANPortMACList($z) $WANMACPrefix$z
	  
	  incr count
	  incr z
	    
}
set count 0
set z 1

while {$count < $WANcount} {
      #puts [lindex $WANPorts $count]
      set WANPortLocList($z) [lindex $WANPorts $count]
	  incr count
	  incr z
	  #puts $count
	  }
#Print Details 
if { $show_cfg != 0 } {
	puts "\n Config Details"
	puts "LANcount:$Tcount"
	puts "WANcount:$WANcount"
	puts [array get LANPortLocList]
	puts [array get WANPortLocList]
	puts [array get LANIPList]
	puts [array get WANIPList]
	puts [array get UdpsourcePort]
	puts [array get UdpDestPort]
	puts "Load:$Load"
	puts [array get LANPortMACList]
	puts [array get WANPortMACList]
	#puts [array get frameLength]
	puts "frameLength:$frameLength"
}
#exit 0