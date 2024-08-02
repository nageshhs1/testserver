#!/usr/bin/perl

use CGI qw/:standard/; # load standard CGI routines
use Cwd;
use File::Copy;

my $read_terminal = `cat auto_log/logfile.txt`; # supply the log file name
my $ts_ip = `ifconfig eth0 | grep "inet addr" | cut -d ':' -f 2 | cut -d ' ' -f 1`;
chomp($ts_ip);
start();

sub start 
{
	print header;
	print start_html('Read_Terminal');
	print start_form;
	print "<body bgcolor=\"black\"onLoad=\"scroll_down()\" >";
	print "<script>";
	print "	function scroll_down()
		{
			window.scroll(0,10000);
		}";
	print "</script>";
	print "<h3><div style=\"text-align: center\"><font style=\"color:green\">TERMINAL LOG</font></div></h3>";
	Read_Terminal();
	print end_form;
	print hr,"\n";
	print end_html;
	print "</body>";	
}


sub Read_Terminal
{
	open(FH,$read_terminal);
	seek(FH,-1000, 2 );
	my @list=<FH>;close FH;
		for($i = 0; $list[$i]; $i++)
		{ 
			print "<h6><font style=\"color:yellow\"><b>$list[$i]</b></font></h6>";
		}
		print "<META HTTP-EQUIV=Refresh CONTENT=\"5\" URL=\"http://$ts_ip/cgi-bin/auto_live_log.pl\">"
}
