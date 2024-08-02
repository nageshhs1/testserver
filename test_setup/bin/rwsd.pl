#!/usr/bin/perl
use strict;
use warnings;
use threads;
use Time::HiRes qw(setitimer time ITIMER_REAL);
use Device::SerialPort qw( :PARAM :STAT 0.07 );
use CGI qw/:standard/;

#Local Variable
my $set=1; #set
my $unset=0; #unset
my $delay=5; #seconds
my $TIMER = 2; #minutes
my $TIMER_CHECK=$set;
my $FAIL_FLAG=$set; 
my $retry_limit=5;
my $retry_delay=1;

my ($line, $buf,$name_buf,$data,$fh,$retry_count,$run,$WD,$serial_port,$serial_read_loop,@array,$Read_Buffer,$Read_Data); 
my ($serial_device, $baudrate, $parity, $databits, $stopbits, $handshake, $serial_read_write_result_log, $read_char_time);
my $board_common = "../board/board_common.cfg";

my @Platrform_error_notification_str = ('not defined','Unknown command','try \'help\'');
my $Platform_uboot_command=$ARGV[0];
my $Platform_uboot_command_promt="";
my $Platform_uboot_variable="";
my $reset="reset";
my $save="save";
my $flash_flash="flash_flash";
my $read="read";		
my $Platform_uboot_stop_autoboot_string="stop autoboot";



#Serial Device Initialization
open (FILE, '+<', "$board_common") or die $!;
while ($line = <FILE>)
{ 

	chomp($line);       # remove newlines
	$line =~ s/^\s+//;  # remove leading  whitespace
	$line =~ s/\s+$//;  # remove trailing whitespace
	
	next if($line =~ /^$/);  # skip blank lines
	next if($line =~ /^\#/); # skip comments		

	if ($line =~ /SERIAL_DEVICE=(.*)export/)
	{
		$serial_device = $1;
		$serial_device =~ s/\s+$//;
	}
	if ($line =~ /BAUDRATE=(.*)export/)
	{
		$baudrate = $1;
		$baudrate =~ s/\s+$//;
	}
	if ($line =~ /PARITY=(.*)export/)
	{
		$parity = $1;
		$parity =~ s/\s+$//;
	}
	if ($line =~ /DATABITS=(.*)export/)
	{
		$databits = $1;
		$databits =~ s/\s+$//;
	}
	if ($line =~ /STOPBITS=(.*)export/)
	{
		$stopbits = $1;
		$stopbits =~ s/\s+$//;
	}		
	if ($line =~ /HANDSHAKE=(.*)export/)
	{
		$handshake = $1;
		$handshake =~ s/\s+$//;
	}
	if ($line =~ /READ_CHAR_TIME=(.*)export/)
	{
		$read_char_time = $1;
		$read_char_time =~ s/\s+$//;
	}
	if ($line =~ /serial_read_write_result_log=(.*)export/)
	{
		$serial_read_write_result_log = $1;
		$serial_read_write_result_log =~ s/\s+$//;
	}	
	
}	
close (FILE);

#printf "$baudrate, $handshake, $serial_device, $serial_read_write_result_log\n";
$serial_port = Device::SerialPort->new($serial_device) || die "Can't open $serial_device $!";
$serial_port->baudrate($baudrate);
$serial_port->parity($parity);
$serial_port->databits($databits);
$serial_port->stopbits($stopbits);
$serial_port->handshake($handshake);
$serial_port->buffers(50, 50);
my @max_buffer_size = $serial_port->buffer_max;
$serial_port->read_char_time($read_char_time);
$serial_port->write_settings;
$serial_port->save("tprev.cfg");	
	

#Signal Handler
$SIG{ALRM} = sub { 
local $|=1;
	$TIMER_CHECK = $TIMER--; 
	printf": Caught SIGALRM in main() [ WAIT TIME :$TIMER_CHECK Minutes remaining for UnSucessful Program Termination ]\n";
	if (($FAIL_FLAG) && ($TIMER_CHECK < 3))
	{
		$serial_port->write("\r"); #send in a carriage return to refresh the cpe command prompt
	}

	if($TIMER_CHECK == 0)
	{
		if ($FAIL_FLAG)
		{	
			print $WD "FAIL";	
			printf "\nREAD/WRITE serial port : CPE BOARD HANG/CRASH........[UnSucessful Program Termination:ABORT SCRIPT] \n";
		}
		else
		{
			print $WD "PASS";	
		}
		close ($fh);
		close ($WD);
		exit 0;
	}
 };
setitimer(ITIMER_REAL, 10, 60);

main(); #start
sub main
{
	open($WD,">", "$serial_read_write_result_log") or die $!;
	if ( "$read" eq "$Platform_uboot_command") #just to moniter serial out
	{
		read_serial_port();
	}
	elsif ( $#ARGV > 0) #set many uboot env variables
	{
		setenv_boot_param()
	}		
	else #run uboot command
	{
		get_platform_uboot_command_promt();
		run_command();	
	}
	close ($WD);
	printf "\nREAD/WRITE serial port : Normal Program Termination\n";
	exit 0;
}

sub get_platform_uboot_command_promt
{
	$retry_count=1;

	$run=$set;
	while($run)
	{
		$serial_port->write("echo");
		$serial_port->write("\r");
		open ($fh, '+<', "$serial_device") or die $!;
		$serial_read_loop=$set;
		$run=$unset;
		$_ = 0 for my ($name_buf);
		$data = "";
		@array = "";

		while ($serial_read_loop) 
		{
			read $fh, $data, 1;
			printf "$data";
			$name_buf.=$data;
			if ( ($data eq "#") && ($name_buf) )
			{
				@array = ($name_buf =~ m/(\s[A-Z]+[0-9]+\s+\W+)/g);

				if (@array)
				{
					$serial_read_loop=$unset;
				}
				else
				{
					close ($fh);
					$serial_read_loop=$unset;
					$run=$set;
					$FAIL_FLAG=$set;
					$retry_count++;
					sleep $delay;
				}
			}
		}
		close ($fh);

		if ( $retry_count > $retry_limit)
		{
			printf "\nRetry_Count Elasped [run $Platform_uboot_command FAIL]\n";
			$run=$unset;
			print $WD "FAIL";	
		}
	}

	
	my $TEMP="";
	$TEMP="@array";
	@array = ($TEMP =~ m/([A-Z]+[0-9]+\s+\W+)/g);
	$Platform_uboot_command_promt="@array";
	printf "\nPlatform_uboot_command_promt=$Platform_uboot_command_promt\n";
}

sub setenv_boot_param
{
	if($ARGV[0] eq "boot_param") {
		$Platform_uboot_command = "setenv ethaddr $ARGV[1]; setenv ipaddr $ARGV[2]; setenv serverip $ARGV[3]; setenv tftppath $ARGV[4]";
	} elsif($ARGV[0] eq "images") {
		$Platform_uboot_command = "setenv update_all 'run $ARGV[1]; run $ARGV[2]; run $ARGV[3]; run $ARGV[4]'";
	}
	printf "$Platform_uboot_command\n";
	$serial_port->write("\n");
	$serial_port->write("$Platform_uboot_command\r");
	open ($fh, '+<', "$serial_device") or die $!;
	$Read_Buffer="";
	$serial_read_loop=$set;
	while ($serial_read_loop) 
	{
		read $fh, $Read_Data, 1;
		printf "$Read_Data";
		$Read_Buffer.=$Read_Data;
		if ( ($Read_Data eq "#") && ($Read_Buffer) )
		{
			$serial_read_loop=$unset;
		}
	}
	close ($fh);
}

sub read_serial_port #just to moniter serial out
{
	$TIMER = 1; #1 minutes
	$FAIL_FLAG=$unset; 

	open ($fh, '+<', "$serial_device") or die $!;
	$serial_read_loop=$set;
	while ($serial_read_loop) 
	{
		$data="";
		read $fh, $data, 1;
		if ( $data ne "%")
		{
			printf "$data";
		}
	}
}

sub run_command
{
	$retry_count=1;
	$run=$set;
        chomp($Platform_uboot_command);
	printf "\nRUN COMMAND : run $Platform_uboot_command\n";
	while($run)
	{
		my $Char_Counter=0;

		if ( "$flash_flash" eq "$Platform_uboot_command")
		{
			$TIMER = 2; #4 minutes
			$FAIL_FLAG=$unset; 
		}

		if ( ("$reset" eq "$Platform_uboot_command") || ("$save" eq "$Platform_uboot_command"))
		{
			$serial_port->write("$Platform_uboot_command\r");
		}
		else
		{
			$serial_port->write("run $Platform_uboot_command\r");
		}

		open ($fh, '+<', "$serial_device") or die $!;
		$serial_read_loop=$set;
		$run=$unset;
		$_ = 0 for my ($buf);
		while ($serial_read_loop) 
		{
			$data="";
			read $fh, $data, 1;
			if ( $data ne "%")
			{
				printf "$data";
			}

			$Char_Counter++;
			for(my $i = 0; $Platrform_error_notification_str[$i]; $i++)
			{
				if ( grep /$Platrform_error_notification_str[$i]/i,$buf)
				{
					print "\nChar_Counter=$Char_Counter\n";
					printf "\nRUN UBOOT CMD [RETRY COUNT $retry_count ]: due to error notification \"$Platrform_error_notification_str[$i]\"\n";
					close ($fh);
					$serial_read_loop=$unset;
					$run=$set;
					$FAIL_FLAG=$set; 
					$retry_count++;
					$_ = 0 for my ($buf);
					$data = "";
					sleep $retry_delay;
				}
	
			} 
			if ( grep /$Platform_uboot_stop_autoboot_string/i,$buf )
			{
				print "\nChar_Counter (stop autoboot)=$Char_Counter\n";
				close ($fh);
				$serial_port->write("\n\r");
				print $WD "PASS";	
				$serial_read_loop=$unset;
			}
			elsif ( (grep /$Platform_uboot_command_promt/i,$buf) && !($run))
			{
				print "\nChar_Counter (stop at #)=$Char_Counter\n";
				print $WD "PASS";	
				$serial_read_loop=$unset;
			}
			else
			{
				$buf.=$data;		
			}
		} 
		close ($fh);
		
		if ( $retry_count > $retry_limit )
		{
			printf "\nRetry_Count Elasped [run $Platform_uboot_command FAIL]\n";
			$run=$unset;
			print $WD "FAIL";	
		}
	}
}
