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
my $taskid = `cat $dst_dir/taskid.txt`;

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
print $query->header ( );

my $Submit = $query->param("submit");
if (!$Submit) {
	die "fail for not post command"
}


if ($state eq "finished") {
  $state = "free";
   if (open FILE,  '>',  "$dst_dir/$filename") {
        #system("sudo ./delete_task_folder.sh $taskid");
        my $when = `date +%Y-%m-%d:%H:%M:%S`;
        my $di = 'auto_log/fr.txt';
        chomp($when);
        open(my $fh,'>>', $di) or die "Couldn't find '$di' $!";
        print $fh "$when free $taskid\n";
        close $fh;

        system("sudo rm -rf /tftpboot/task/$taskid");
        print FILE $state;
        close FILE;
        $ret = "ok";
   } else {
      print "fail to open $dst_dir/$filename";
  }
} else {
   print "<p>";
   my $len =  length($state);
   print "current:$state($len).";
   print "<p>";
   $len =  length("finished");
   print "($len).";
}

print $ret;


