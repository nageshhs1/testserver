#!/usr/bin/perl -w

use strict;
use CGI;
use CGI::Carp qw ( fatalsToBrowser );
use File::Basename;

$CGI::POST_MAX = 1024 * 50000;
my $safe_filename_characters = "a-zA-Z0-9_.-";

my $query = new CGI;
my $filename = $query->param("filename");
my $dst_dir = $query->param("file_dir");
#my $dst_dir="/tftpboot/";
if ( !$filename )
{
        print $query->header ( );
        print "There was a problem uploading file $filename to $dst_dir";
        exit;
}

my ( $name, $path, $extension ) = fileparse ( $filename, '..*' );
$filename = $name . $extension;
$filename =~ tr/ /_/;
$filename =~ s/[^$safe_filename_characters]//g;

if ( $filename =~ /^([$safe_filename_characters]+)$/ )
{
        $filename = $1;
}
else
{
        die "Filename contains invalid characters";
}

my $upload_filehandle = $query->upload("filename");
if (-e $dst_dir) {
}
else {
        unless(mkdir $dst_dir) {
          die "Unable to create $dst_dir\n";
   }
}
#chmod(0777, $dst_dir) or die "Couldn't set the permission for $dst_dir: $!";
open ( UPLOADFILE, ">$dst_dir/$filename" ) or die "$!";
binmode UPLOADFILE;

while ( <$upload_filehandle> )
{
        print UPLOADFILE;
}

close UPLOADFILE;

print $query->header ( );
print "uploaded $filename to $dst_dir Ok"
