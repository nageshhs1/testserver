TCL Spirent Scripts Automation Details 

1.	Chassis 10.226.44.148,  Slot 1 and Ports 1/5 , 1/6 , 1/7, (Lan Ports ) and 1/8 (Wan Port ) 
2.	 Programs coded on 10.226.45.37 machine. C:\\Tcl\bin\ 
3.	Chassis 10.226.45.147, Slot 1 and Ports 1/11 and 1/12 can be used for the testing activities 
4.	Rack AR08 has Connecting Ports 

Script Structure : 
       -t   :   indicates Tx   Slot/port   we can use this flag multiple times to provide different ports       
                 Example :  -t 1/5 
      -r   :   indicates Tx   Slot/port   we can use this flag multiple times to provide different ports 
                 Example :  -r 1/8
       -f   :   indicates frame size, we can use this flag multiple times to provide different frame sizes 
                 Example  -f 128 –f 512 –f 1024 
      -l   :  indicates Load  
                Example : -l 100 
  Cfg.tcl file is having the basic configurations :- like Spirent chassis IP and load, resolutions and max  and min load and other information can be provided for the performance scripts using this file.  import_cfg1.tcl , import_cfg2.tcl and import_cfg3.tcl files help to take inputs at each stages respectively for each script . 
      We have Different log Files in order to understand the output : 
1.	Algorithm_log.txt which provides every iteration output 
2.	System generated log files for the Spirent commands outputs . 
3.	Tx and Rx stream results and capture files. 

Performance_all.tcl 
The Top Level script and where we can provide the  Tx and Rx ports, Frame size and Load information using flag bits. 
Command to run : 
tclsh performance_all.tcl -t 1/5 -r 1/8 -f 68 -l 100




Performance.tcl 
 The Second Level script and where we can provide the  Tx and Rx ports, Frame size and Load information using flag bits. 
Command to run: 
tclsh performance.tcl -t 1/5 -r 1/8 -f 68 -l 100


Transmit.tcl 
 The Third Level script and where we can provide the  Tx and Rx ports, Frame size and Load information using flag bits. 
Command to run: 
tclsh transmit.tcl -t 1/5 -r 1/8 -f 68 -l 100


Output directory: 
   Will have stream, packet transmitted and received details and packet counts and wire shark capture files. 

Spirent Support Details:

  support.spirent.com
  Spirent Support <support@spirent.com>
  
  E-Mail IDs:  
Kumar, Sasanka <Sasanka.Kumar@spirent.com>; 
Alwyn, Samson <Samson.Alwyn@spirent.com>; 
Mohanty, ChinmayaKumar <ChinmayaKumar.Mohanty@spirent.com>
