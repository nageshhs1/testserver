#!/usr/bin/perl -w

use strict;
use CGI;
use CGI::Carp qw ( fatalsToBrowser );
use File::Basename;

my $query = new CGI;
my $filename = "status.txt";
my $filename_taskid = "taskid.txt";
my $dst_dir = "auto_log";
my $state = "free";
my $ret = "fail";
my $iamhere;
my $taskfolder = "/tftpboot/task";

if (-e $dst_dir) {
}	
else {
	unless(mkdir $dst_dir) {
          die "Unable to create $dst_dir: Failed\n";
   }
}   
if (open( FILE, '<', "$dst_dir/$filename")) {
	$state = <FILE>;
	chomp($state);
}
close FILE;

my $taskid = $query->param("taskid");

if (!$taskid) {
	die "fail for not post command"
}


die "Task folder $taskid is not exist" unless -d "$taskfolder/$taskid";

if ($state eq "free") {
	     	
   if (open (FILE_taskid, '>', "$dst_dir/$filename_taskid")) {
        print FILE_taskid $taskid;
        close FILE_taskid;
   } else {
        print "fail for open " . $dst_dir . "/" . $filename_taskid . "failed";
   }
   $state = "testing";

   if (open FILE,  '>',  "$dst_dir/$filename") {
      #system "nohup #!/bin/sh ./auto_testing_ps.sh &" == 0 or die "fail";
	  $iamhere="EEE";
      my $pid = fork();
      if (defined $pid && $pid == 0) {
		# child
                  my $when = `date +%Y-%m-%d:%H:%M:%S`;
                  my $di = 'auto_log/di.txt';
                  chomp($when);
                  open(my $fh,'>>', $di) or die "Couldn't find '$di' $!";
                  print $fh "$when task $taskid\n";
                  close $fh;
		  close(STDOUT);close(STDIN);close(STDERR);
		  system("nohup ./auto_testing_ps.sh $taskid &");
		  exit 0;
      }
	  #$iamhere="EE2";
        print FILE $state;
        close FILE;
        $ret = "ok";
   }
} else {
	$iamhere="not free";
}

print $query->header ( );
print $ret;
print "::taskid=$taskid $iamhere $state\n";

