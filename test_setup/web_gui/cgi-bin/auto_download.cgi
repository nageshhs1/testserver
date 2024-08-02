#!/usr/bin/perl -w

use strict;
use CGI;
use CGI::Carp qw ( fatalsToBrowser );
use File::Basename;

$CGI::POST_MAX = 1024 * 50000;
my $safe_filename_characters = "a-zA-Z0-9_.-";

my $query = new CGI;
my $filename = $query->param("file_dir");
if ( !$filename )
{
        print $query->header ( );
        #print "CGI not find parameter \"file_dir\"\n";
        exit;
}

#chmod(0777, $dst_dir) or die "Couldn't set the permission for $dst_dir: $!";
if ( !open ( SRCFILE, "<$filename" ) ) {
        #print $query->header ("404 File Not found" );
        print $query->header(
                 -status=>'503 Database Unavailable',
                 -type=>'text/plain'
        );
        #print "Content-type: text/plain", "\n";
        #print "Status: 400 Bad Request", "\n\n";
        print "Fail";
        exit 5; #
        #die "";
}
#binmode UPLOADFILE;
#print "Content-Type: application/octet-stream\n\n";
#print  "Content-Type: attachment; filename=somecustomname.txt\n\n";
#print "Content-Type: application/x-download\n\n";
print"Content-type:text/plain\n";
print "Content-disposition:attachment; filename=t.txt\n\n";
my $fileContents;
while ($fileContents = <SRCFILE>)
{
        print $fileContents;
}

close SRCFILE;
