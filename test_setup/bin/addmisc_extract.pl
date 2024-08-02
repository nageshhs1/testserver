#!/usr/local/bin/perl

#use strict; 
use Device::SerialPort qw( :PARAM :STAT 0.07 );
use CGI qw/:standard/;

my $ob = Device::SerialPort->new("/dev/ttyS0");

  $ob->baudrate(115200);
  $ob->parity("none");
  $ob->databits(8);
  $ob->stopbits(1);
  $ob->handshake("none");

  $ob->write_settings;
  $ob->save("tpj4.cfg");

my $filename_in="/dev/ttyS0";
my $filename_out="/dev/ttyS0";
my $file = "";
my $time_out=0;
if($ARGV[2])
{
	$time_out=$ARGV[2];

}
else
{
	$time_out=10;
}

if ($ARGV[0])
{
	$file=$ARGV[0];
}
else
{
	$file="/tmp/addmisc_data";
}


	local $SIG{ALRM} = sub { die "ALERT -> Serial port read : TIMEOUT\n" };
	alarm $time_out;
	open(WD, "> $file") || die("Can't Open $file! for writing");
	open (SERIALOUT,"+< $filename_out") || die("Can't Open $filename_out! for reading/writing");
	open (my $fh, '+<', "/dev/ttyS0") or die $!;
	my ($buf, $data, $set,$count,$stop_count); 

		if ($ARGV[1])
		{
			print "timeout = $time_out #####################################";
			print "Sending $ARGV[1] command via serial port\n";
			print SERIALOUT "$ARGV[1]\r";
		}
		else
		{
			print SERIALOUT "print addmisc\r";
		}
		$set=1;
		$count=0;
		$stop_count=50000;
		while ($set != 0) 
		{
			read $fh, $data, 1;
			if ($data eq "#")
			{
				print "Unset here..............";
				$set=0;
			}
				$buf.=$data;		
			if ($count == $stop_count)
			{
				$set=0;
				print WD "exit\n";
				print WD "exit\n";
				print WD "exit\n";
				print WD "exit\n";
				close ($fh);
				close (SERIALOUT);
				close (WD);
				die("Exiting perl script:ABORT\n");
			}
			$count++;
		} 
		print WD "#$buf";
		print "#$buf";
		print "Reading data via /dev/ttyS0  :\n";
		#print "Reading data via /dev/ttyS0  :\n#$buf\n";
		print "Writing Serial data to $ARGV[0]\n";

	close ($fh);
	close (SERIALOUT);
	close (WD);
	alarm 0;

