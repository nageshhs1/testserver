#!/usr/bin/tclsh

if {[catch {
source cfg.tcl
source import_cfg3.tcl
global wancount
global bi
set wancount [array size WANPortLocList]
global stream_count
set stream_count [array size WANIPList]


#Spirent TCL Script for Configuring ports, Generating packets and getting results
package require SpirentTestCenter
#puts "SpirentTestCenter system version:\t[stc::get system1 -Version]"
stc::config system1 -IsLoadingFromConfiguration "true"
stc::config automationoptions -logTo stdout -logLevel ERROR
global project1
set project1 [stc::create "project" \
        -TableViewData "" \
        -SelectedTechnologyProfiles {} \
        -ConfigurationFileName {Output.tcl} ]

#Initiation of the STC parameters 
set x 1
set LANPortList {}
stc::connect $chassisIp
while {$x <= $PortCount} {
	set var lport($x)
	set lport($x) [stc::create port -under $project1 -location $chassisIp/$LANPortLocList($x)]
	lappend LANPortList $var
	stc::reserve $chassisIp/$LANPortLocList($x)
	incr x
}
	set x 1
	set WANPortList {}
while {$x <= $wancount} {
	set var wport($x)
	if {$WANPortLocList($x) != $LANPortLocList($x)} {
			set wport($x) [stc::create port -under $project1 -location $chassisIp/$WANPortLocList($x)]
			lappend WANPortList $var
			stc::reserve $chassisIp/$WANPortLocList($x)
			}
	incr x
}
stc::perform setupportmappings
after 2000

#Initiation of the Ports,EmulatedDevice & StreamBlock
	set x 1 
while {$x <= $PortCount} {
    set lEmulatedDevice($x) [stc::create "EmulatedDevice" -under $project1 -EnablePingResponse "FALSE" ]	
	set lEthIIIf($x) [stc::create "EthIIIf"  -under $lEmulatedDevice($x)  -SourceMac $LANPortMACList($x) -SrcMacList "" ]
	#puts $LANPortMACList($x)
	set lIpv4If($x) [stc::create "Ipv4If" \
        -under $lEmulatedDevice($x) \
        -Address $LANIPList($x)\
        -AddrList "" \
        -Gateway $LANGatewayIP \
        -GatewayList "" \
        -ResolveGatewayMac "TRUE" ]
	stc::config $lEmulatedDevice($x) -AffiliationPort-targets $lport($x)
	stc::config $lEmulatedDevice($x) -TopLevelIf-targets $lIpv4If($x)
	stc::config $lEmulatedDevice($x) -PrimaryIf-targets $lIpv4If($x)
	stc::config $lIpv4If($x) -StackedOnEndpoint-targets $lEthIIIf($x)
	#Display Device information.
	if {$print_result != 0} {
		puts "$lEmulatedDevice($x) Information"
		set lstHostInfo [stc::get $lEmulatedDevice($x)]
		foreach {szAttribute szValue} $lstHostInfo {
				puts \t$szAttribute\t$szValue
				}
	puts "\nBefore Arp/Nd starts"
    puts "\t$lEmulatedDevice($x) : EthIIIf.SourceMac [stc::get $lEmulatedDevice($x) -EthIIIf.SourceMac ]"
	puts "\t$lEmulatedDevice($x) : Ipv4If.Address [stc::get $lEmulatedDevice($x) -Ipv4If.Address]"
	puts "\t$lEmulatedDevice($x) : Ipv4If.GatewayIP [stc::get $lEmulatedDevice($x) -Ipv4If.Gateway]"
	puts "\t$lEmulatedDevice($x) : Ipv4If.GatewayMac [stc::get $lEmulatedDevice($x) -Ipv4If.GatewayMac]\n"	
    }	
   incr x				
	}
	
	
	

	set x 1 
	while {$x <= $wancount} {
	  if {$WANPortLocList($x) != $LANPortLocList($x)} {
	    set wEmulatedDevice($x) [stc::create "EmulatedDevice" -under $project1 -EnablePingResponse "FALSE" ]	
		set wEthIIIf($x) [stc::create "EthIIIf"  -under $wEmulatedDevice($x) -SourceMac $WANPortMACList($x) -SrcMacList "" ]
		set wIpv4If($x) [stc::create "Ipv4If" \
			-under $wEmulatedDevice($x) \
			-Address $WANIPList($x)\
			-AddrList "" \
			-Gateway $WANGatewayIP \
			-GatewayList "" \
			-ResolveGatewayMac "TRUE" ]
		stc::config $wEmulatedDevice($x) -AffiliationPort-targets $wport($x)
		stc::config $wEmulatedDevice($x) -TopLevelIf-targets $wIpv4If($x)
		stc::config $wEmulatedDevice($x) -PrimaryIf-targets $wIpv4If($x)
		stc::config $wIpv4If($x) -StackedOnEndpoint-targets $wEthIIIf($x)
		#For loop to Display Device information.
		if {$print_result != 0} {
		puts "$wEmulatedDevice($x) Information"
		set lstHostInfo [stc::get $wEmulatedDevice($x)]
		foreach {szAttribute szValue} $lstHostInfo {
				puts \t$szAttribute\t$szValue
			}
       
	puts "\nBefore Arp/Nd starts"
    puts "\t$wEmulatedDevice($x) : EthIIIf.SourceMac [stc::get $wEmulatedDevice($x) -EthIIIf.SourceMac ]"
	puts "\t$$wEmulatedDevice($x) : Ipv4If.Address [stc::get $wEmulatedDevice($x) -Ipv4If.Address]"
	puts "\t$$wEmulatedDevice($x) : Ipv4If.GatewayIP [stc::get $wEmulatedDevice($x) -Ipv4If.Gateway]"
	puts "\t$$wEmulatedDevice($x) : Ipv4If.GatewayMac [stc::get $wEmulatedDevice($x) -Ipv4If.GatewayMac]"	
	}	
	}
	incr x
	}	
	set x 1
	set y 1
	while {$x <= $PortCount} { 
	set stream_fram_config($x) "<frame ><config><pdus><pdu name=\"ipv4_7092\" pdu=\"ipv4:IPv4\"><totalLength>28</totalLength><ttl>255</ttl><sourceAddr>$LANIPList($x)</sourceAddr><destAddr>$WANIPList($x)</destAddr><gateway>$LANGatewayIP</gateway><tosDiffserv name=\"anon_3227\"><tos name=\"anon_3228\"><precedence>0</precedence><dBit>0</dBit><tBit>0</tBit><rBit>0</rBit><mBit>0</mBit><reserved>0</reserved></tos></tosDiffserv></pdu><pdu name=\"proto1\" pdu=\"udp:Udp\"><sourcePort>$UdpsourcePort($x)</sourcePort><destPort override=\"true\" >$UdpDestPort($x)</destPort></pdu></pdus></config></frame>"
	
	
	set streamblock($x) [stc::create streamblock -under $lport($x) \
        -frameLengthMode FIXED \
		-FixedFrameLength $frameLength \
	    -InsertSig "TRUE" \
        -FrameConfig $stream_fram_config($x) ]
	stc::config $streamblock($x) -SrcBinding-targets $lIpv4If($x)
	stc::config $streamblock($x) -DstBinding-targets $wIpv4If($y)
	set streamBlockLoadProfile($x) [stc::create "streamBlockLoadProfile" -under $project1 -Load $Load -LoadUnit "PERCENT_LINE_RATE" ]
	stc::config $streamblock($x) -AffiliationStreamBlockLoadProfile-targets $streamBlockLoadProfile($x)
	if {$print_result != 0} {
		set lstHostInfo [stc::get $lEmulatedDevice($x)]
		puts $stream_fram_config($x)
		foreach {szAttribute szValue} $lstHostInfo {
					puts \t$szAttribute\t$szValue
				}
	}			
	set lgenerator($x) [lindex [stc::get $lport($x) -children-generator] 0]
	#puts $lgenerator($x)
	set lgeneratorconfig($x) [lindex [stc::get $lgenerator($x) -children-generatorConfig] 0]
	stc::config $lgeneratorconfig($x) \
        -FixedLoad $Load \
        -Duration $runTime \
        -DurationMode "SECONDS"
	incr x
	if { $PortCount == $wancount} { 
     incr y	}
	}
	
	set x 1 
	set y 1
	while {$x <= $wancount} {
	if {$WANPortLocList($x) != $LANPortLocList($x)} {
	set wstream_fram_config($x) "<frame ><config><pdus><pdu name=\"ipv4_7092\" pdu=\"ipv4:IPv4\"><totalLength>28</totalLength><ttl>255</ttl><sourceAddr>$WANIPList($x)</sourceAddr><destAddr>$LANIPList($x)</destAddr><gateway>$WANGatewayIP</gateway><tosDiffserv name=\"anon_3227\"><tos name=\"anon_3228\"><precedence>0</precedence><dBit>0</dBit><tBit>0</tBit><rBit>0</rBit><mBit>0</mBit><reserved>1</reserved></tos></tosDiffserv></pdu><pdu name=\"proto1\" pdu=\"udp:Udp\"><sourcePort>$UdpsourcePort($x)</sourcePort><destPort override=\"true\" >$UdpDestPort($x)</destPort></pdu></pdus></config></frame>"
	
	
	set wstreamblock($x) [stc::create streamblock -under $wport($x) \
        -frameLengthMode FIXED \
		-FixedFrameLength $frameLength \
	    -InsertSig "TRUE" \
        -FrameConfig $wstream_fram_config($x) ]
	stc::config $wstreamblock($x) -SrcBinding-targets $wIpv4If($y)
	stc::config $wstreamblock($x) -DstBinding-targets $lIpv4If($x)
	set wstreamBlockLoadProfile($x) [stc::create "streamBlockLoadProfile" -under $project1 -Load $Load -LoadUnit "PERCENT_LINE_RATE" ] 
    stc::config $wstreamblock($x) -AffiliationStreamBlockLoadProfile-targets $wstreamBlockLoadProfile($x)


	# Display stream block information.
	if {$print_result != 0} {
	    puts $wstream_fram_config($x)
		set lstStreamBlockInfo [stc::perform StreamBlockGetInfo -StreamBlock $wstreamblock($x)]  
		foreach {szName szValue} $lstStreamBlockInfo {
					puts \t$szName\t$szValue
				}
		}
	}
	if {$bi } {
	set wgenerator($x) [lindex [stc::get $wport($x) -children-generator] 0]
	#puts $wgenerator($x)
	set wgeneratorconfig($x) [lindex [stc::get $wgenerator($x) -children-generatorConfig] 0]
	stc::config $wgeneratorconfig($x) \
        -FixedLoad $Load \
        -Duration $runTime \
        -DurationMode "SECONDS"
		}
	incr x
	if { $PortCount == $wancount} { 
			incr y	}
	}

		set x 1
while {$x <= $wancount} {
	
		 
				set wAnalyzer($x) [stc::get $wport($x) -children-Analyzer]	
				set wAnalyzerConfig($x) [stc::get $wAnalyzer($x) -children-AnalyzerConfig]
				global whCapture
				set whCapture($x) [stc::get $wport($x) -children-capture]
				stc::config $whCapture($x) -mode REGULAR_MODE -srcMode TX_RX_MODE
				#stc::perform ArpNdStart -HandleList [list $wport($x)]	
				after 1000
				
	incr x
	}
	set x 1
	while { $x <= $PortCount} {
		set lAnalyzer($x) [stc::get $lport($x) -children-Analyzer]	
		set lAnalyzerConfig($x) [stc::get $lAnalyzer($x) -children-AnalyzerConfig]
		global lhCapture
		set lhCapture($x) [stc::get $lport($x) -children-capture]
		stc::config $lhCapture($x) -mode REGULAR_MODE -srcMode TX_RX_MODE  
		after 1000
		incr x 
		}
	#Global initialization 
	set ResultOptions [lindex [stc::get $project1 -children-ResultOptions] 0]
	stc::config $ResultOptions \
        -DeleteAllAnalyzerStreams TRUE
	# Subscribe to realtime results.

	#puts "Subscribe to results"
	stc::subscribe -Parent $project1 \
                -ConfigType Analyzer \
                -resulttype AnalyzerPortResults  \
				-viewAttributeList "TotalFrameCount udpframecount minframelength maxframelength L1BitRate TotalBitRate TotalFrameRate DroppedFrameCount" \
				-Interval 5 -filenameprefix "Analyzer_Port_Results"

	stc::subscribe -Parent $project1 \
                 -ConfigType Generator \
                 -resulttype GeneratorPortResults  \
				 -viewAttributeList "" \
                 -filenameprefix "Generator_Port_Counter" \
				 -Interval 5
				 
	stc::perform ArpNdStart -HandleList [stc::get $project1 -children-port]
    after 1000
    global whCapture
	global hResultDataSet
	set hResultDataSet [stc::subscribe -parent [lindex [stc::get system1 -children-Project] 0] \
        -configType streamblock \
        -resultType RxStreamSummaryResults \
		-filterList "[lindex [stc::get system1.Project(1) -children-RxPortResultFilter] 0] " \
        -viewAttributeList "framerate bitcount l1bitrate l1bitcount Comp32 framecount droppedframecount droppedframepercent minframelength maxframelength" \
		-interval 1 -filenamePrefix "$frameLength-rxstreamsummaryresults"]
		

	# Subscribe to results for result query work_loop-0004-txstreamresults
	stc::subscribe -parent [lindex [stc::get system1 -children-Project] 0] \
        -resultParent " [lindex [stc::get system1 -children-Project] 0] " \
        -configType streamblock \
        -resultType txstreamresults \
        -filterList "" \
        -viewAttributeList "framecount framerate bitrate expectedrxframecount l1bitcount l1bitrate bitcount " \
        -interval 5 -filenamePrefix "$frameLength-qos_8q-0002-txstreamresults"


		
   set j 1
   while {$j <= $wancount} {
        #puts "start analyzer" 
		stc::perform AnalyzerStart -AnalyzerList "$wAnalyzer($j)"
   		stc::perform CaptureStart -captureProxyId $whCapture($j)
        incr j
   }	
   set k 1 
   while {$k <= $PortCount} {
   stc::perform AnalyzerStart -AnalyzerList "$lAnalyzer($k)"
   stc::perform CaptureStart -captureProxyId $lhCapture($k)
   #puts "start gen & ana $lhCapture($k)"
   incr k
   }
   #Apply config 
   global project1
   stc::perform ResultsClearAll -portlist [stc::get $project1 -children-port]
   stc::perform ResultClearAllTraffic -portlist [stc::get $project1 -children-port]
   after 2000
   stc::apply	
   
   after 9000
   #Start Analyzer,Generator and Capture the Result
proc run {frameLength PortCount x} {
   global lgenerator
   global wgenerator
   global wAnalyzer
   global lAnalyzer
   global streamid
   global wancount
   global hResultDataSet
   global whCapture
   global lhCapture
   global project1 
   global bi
   global stream_count
   
   set k 1
   while { $k <= $PortCount} {   
   #puts "start gen & ana $hCapture($x)"
   
   stc::perform generatorstart -generatorlist "$lgenerator($k)"
   
   #puts "$lgenerator($k)"
   incr k
   }
   if {$bi } {
		set j 1
		while {$j <= $wancount} {
			stc::perform generatorstart -generatorlist "$wgenerator($j)"
			incr j 
		}
   }
   #after 2000
   # Waits until Run time completes
   set i 1
   set streamid 0
   set tempvar 0
   global count
   set count $wancount
   set stream_count [expr {$stream_count - 1 } ]
   while { [array size sid] < $stream_count} {
       #puts "[array size sid] < $stream_count"
	   foreach  hResults [stc::get $hResultDataSet -ResultHandleList] {
       #puts $hResults
       array set aResults [stc::get $hResults]
	   #puts $hResults
       set isMatch_start [string match "rxstreamsummaryresults*" $hResults]
	   
       if {$isMatch_start != 0 && $aResults(-Comp32) != 0 && $streamid != $aResults(-Comp32) } {
				set streamid $aResults(-Comp32)
				#puts "streamid: $streamid"
				set sid($i) $streamid
				incr i
					
				}
		  
	   if {$isMatch_start != 0 &&$aResults(-Comp32) != 0 && $aResults(-DroppedFramePercent) > 80} {
        
			stc::perform ResultsClearAll -portlist [stc::get $project1 -children-port]
			stc::perform ResultClearAllTraffic -portlist [stc::get $project1 -children-port]
			}	   
       after 100
	   incr tempvar
       if {$tempvar == 20} {
			break
		}
		}
		
		}
   
   
   #Get the Result for Each Loop
   #puts [array size sid]
   #puts [array get sid]
   
   
   
   
   proc Get_result {strid} { 
   global runTime
   global hResultDataSet
   global project1
   set y 0
   while {$y < 1} {
            #puts "delay loop"
            #Capture the stream Results 
			after [expr {$runTime * 1000}]
            foreach  hResults [stc::get $hResultDataSet -ResultHandleList] {
				#puts "$hResults"
				array set aResults [stc::get $hResults]
				set isMatch_start [string match "rxstreamsummaryresults*" $hResults]
				if { $isMatch_start != 0 && $aResults(-FrameCount) > 0 && $aResults(-DroppedFrameCount) > 0 && $aResults(-Comp32) == $strid} {
			              #Stop Generator and Analyzers		
						  #puts "Stop with drop"
						 	
						  set drpper $aResults(-DroppedFramePercent)
						  set drpcnt $aResults(-DroppedFrameCount)
						  stc::perform ResultsClearAll -portlist [stc::get $project1 -children-port]
                          stc::perform ResultClearAllTraffic -portlist [stc::get $project1 -children-port]
						  after 2000
                          # If Drop Return the results
                          #return [ list $aResults(-DroppedFramePercent) $aResults(-DroppedFrameCount)]
                          return [ list $drpper $drpcnt]
			                               }
                          										   
				                  }
	incr y
    	
	#after 1000
	set drpper $aResults(-DroppedFramePercent)
    set drpcnt $aResults(-DroppedFrameCount)
	stc::perform ResultsClearAll -portlist [stc::get $project1 -children-port]
    #stc::perform ResultClearAllTraffic -portlist {[stc::get $project1 -children-port]} 
	#after 2000
	#puts "If No drop return resutls "
    #return [list $aResults(-DroppedFramePercent) $aResults(-DroppedFrameCount)]
    return [list $drpper $drpcnt]
   
}
}


proc stop_all {} { 
   global lgenerator
   global wgenerator
   global wAnalyzer
   global lAnalyzer
   global PortCount
   global wancount
   global bi
   global whCapture
   global project1
   global frameLength
   #puts "stop all"
   
   set k 1
	while { $k <= $PortCount} {
		stc::perform generatorStop -generatorlist "$lgenerator($k)"
		stc::perform AnalyzerStop -AnalyzerList "$lAnalyzer($k)"
		incr k
	}
   set j 1
   while {$j <= $wancount} {
        #puts "stop analyzer"
		if {$bi } {stc::perform generatorStop -generatorlist "$wgenerator($j)"}
		stc::perform AnalyzerStop -AnalyzerList "$wAnalyzer($j)"
		#stc::perform CaptureStop -captureProxyId $whCapture($j)
		stc::perform CaptureStop -captureProxyId $whCapture($j)
		stc::perform CaptureDataSave -captureProxyId $whCapture($j) -FileName "capture($frameLength).pcap" -FileNameFormat PCAP -IsScap FALSE
		incr j
   }
   #puts "[stc::get $project1 -children-port]"
   stc::perform ResultsClearAll -portlist [stc::get $project1 -children-port]
   #stc::perform ResultClearAllTraffic -portlist {[stc::get $project1 -children-port]}
   }

   
   for { set index 1 }  { $index <= [array size sid] }  { incr index } {
   #puts "sid($index) : $sid($index)"
    
    set tem_result [eval [concat Get_result $sid($index)]]
	#puts "tem_result: $tem_result"
	set temp_drop_per($index) [lindex $tem_result 0]
	set temp_drop_count($index) [lindex $tem_result 1]
	#puts [list [array get temp_drop_per] [array get temp_drop_count]]
    }
	stop_all
	return [list [array get temp_drop_per] [array get temp_drop_count]]
	

 
}
set x 1
set d1 {}
set p1 {}
#puts "Configuration Completed"
    
set result [eval [concat run $frameLength $PortCount $x]]
#puts "$result"
set test_status [lindex $result 0]
set drop [lindex $result 1]
set darray($x) $drop
lappend d1 $drop
set dparray($x) $test_status
lappend p1 $test_status
incr x 
if {$print_result != 1} {
		#Print the Test Results
		#puts [list [array get darray] [array get dparray]]
		puts "$d1 $p1"
		set last "DroppedFramePercent: $test_status %, Dropcount: $drop\n"
		set filename "25times_check.txt"
		set fileId [open $filename "a+"]
		puts -nonewline $fileId $last
		close $fileId
		} else {
			puts "DroppedFramePercent: $test_status %, Dropcount: $drop"
		} 
	
	#Cleanup the chassis and port config and release 
proc cleanup {project1 print_result} {
    if {$print_result != 0} {
		puts "Clearup the Ports and Delete the project"
	}
    stc::perform chassisDisconnectAll 
    stc::perform resetConfig
	stc::delete $project1
}
cleanup $project1 $print_result
} err] } {
	puts "Error caught: $err"
}