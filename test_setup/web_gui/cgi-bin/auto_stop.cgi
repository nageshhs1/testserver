#!/usr/bin/perl -w

use strict;
use CGI;
use CGI::Carp qw ( fatalsToBrowser );
use File::Basename;

my $query = new CGI;
my $filename = "status.txt";
my $dst_dir = "auto_log";
my $state = "free";
my $ret = "fail";

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

my $Submit = $query->param("submit");
if (!$Submit) {
	die "fail for not post command"
}
if ($state eq "testing") {
   $state = "stopping";
   
   if (open FILE,  '>',  "$dst_dir/$filename") {
        my $pid = fork();
      if (defined $pid && $pid == 0) {
    # child
      close(STDOUT);close(STDIN);close(STDERR);
      system("nohup ./auto_stopping_ps.sh &");
      exit 0;
      }

        print FILE $state;
        close FILE;
        $ret = "ok";
   }
} else {
}

print $query->header ( );
print $ret;


