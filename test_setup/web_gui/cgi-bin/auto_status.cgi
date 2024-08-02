#!/usr/bin/perl -w

use strict;
use CGI;
use CGI::Carp qw ( fatalsToBrowser );
use File::Basename;

my $query = new CGI;
my $filename = "status.txt";
my $dst_dir = "auto_log";
my $state = "free";

if (-e $dst_dir) {
}	
else {
	unless(mkdir $dst_dir) {
          die "Unable to create $dst_dir\n";
   }
}   
if (open FILE, "$dst_dir/$filename") {
	 $state = <FILE>;
	close FILE;
}
print $query->header ( );
print $state


