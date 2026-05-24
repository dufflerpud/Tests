#!/usr/bin/perl
#
#indx#	test_index.pl - (VERY brief explanation of what this file is/does)
#@HDR@	$Id$
#@HDR@
#@HDR@	Copyright (c) 2026 Christopher Caldwell (Christopher.M.Caldwell0@gmail.com)
#@HDR@
#@HDR@	Permission is hereby granted, free of charge, to any person
#@HDR@	obtaining a copy of this software and associated documentation
#@HDR@	files (the "Software"), to deal in the Software without
#@HDR@	restriction, including without limitation the rights to use,
#@HDR@	copy, modify, merge, publish, distribute, sublicense, and/or
#@HDR@	sell copies of the Software, and to permit persons to whom
#@HDR@	the Software is furnished to do so, subject to the following
#@HDR@	conditions:
#@HDR@	
#@HDR@	The above copyright notice and this permission notice shall be
#@HDR@	included in all copies or substantial portions of the Software.
#@HDR@	
#@HDR@	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY
#@HDR@	KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
#@HDR@	WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE
#@HDR@	AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
#@HDR@	HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
#@HDR@	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
#@HDR@	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
#@HDR@	OTHER DEALINGS IN THE SOFTWARE.
#
#hist#	2026-05-24 - Christopher.M.Caldwell0@gmail.com - Created
########################################################################
#doc#	(Less brief explanation of what this file is/does)
########################################################################

use strict;

use lib "/usr/local/lib/perl";

use cpi_file qw( fatal cleanup files_in read_file write_file );
use cpi_arguments qw( parse_arguments );

my $exit_status = 0;

my $ALWAYS=1;
my @OTHERLIST = ("cgi","doc","html","jpeg","mp3","mp4","mpg","pl","pps","ppt","txt","wav","wmv","mid");

my @toprint;
my @files;

sub traverse_dirs
    {
    my( $dn ) = @_;
    my( @worklist ) = ( $dn );
    my( @alldirs ) = ();
    my %filemap = ();
    my $fn;
    while( $dn = shift(@worklist) )
        {
	push( @alldirs, $dn );
	foreach $fn ( @{$filemap{$dn}} = &files_in($dn) )
	    {
	    my $fqfn = "$dn/$fn";
	    push( @worklist, $fqfn ) if( -d $fqfn && ! -l $fqfn );
	    }
	}
    foreach $dn ( @alldirs )
        {
	if( $ALWAYS || -f "$dn/index.html" )
	    {
	    my $ofn = "$dn/index.html";
	    print "Creating $ofn.\n";
	    @toprint = ();
	    push @toprint, <<EOF;
<body bgcolor="#4070c0" link="white" vlink="white">
<center><table bgcolor="#60a0e0" border=1 cellpadding=0 cellspacing=0>
EOF
	    foreach $fn ( @{$filemap{$dn}} )
	        {
		next if( $fn eq "index.htm" || $fn eq "index.html" );
		my $fqfn = "$dn/$fn";
		my $ext = $fn;
		$ext =~ s/.*\.//;
		$ext="unknown" if( $ext eq $fn );
		if( -d $fqfn )
		    {
		    push @toprint, "<tr><th align=left>";
		    if( 1 || -f "$fn/index.html" )
		        { push @toprint, "Directory:  <a href=$fn/index.html>$fn</a>"; }
		    else
		        { push @toprint, "Directory:  <a href=$fn>$fn</a>"; }
		    push @toprint, "</th></tr>";
		    }
		elsif( grep( $_ eq $ext, "htm", "html" ) )
		    {
		    push @toprint, "<tr><th align=left>";
		    my $l = &read_file("$dn/$fn");
		    if( $l =~ /<title.*?>(.*?)<\/title>/is )
		        { push @toprint, "Titled:  <a href=$fn>$1</a>"; }
		    elsif( $l =~ /<h1.*?>(.*?)<\/h1>/is )
		        { push @toprint, "Headered:  <a href=$fn>$1</a>"; }
		    elsif( $l =~ /<h\d.*?>(.*?)<\/h\d+>/is )
		        { push @toprint, "Headered:  <a href=$fn>$1</a>"; }
		    elsif( $l =~ /<caption.*?>(.*?)<\/caption>/is )
		        { push @toprint, "Captioned:  <a href=$fn>$1</a>"; }
		    else
		        { push @toprint, "File:  <a href=$fn>$fn</a>"; }
		    push @toprint, "</th></tr>";
		    }
#		elsif( grep( $_ eq $ext, "gif", "jpg", "jpeg", "JPG", "JPEG" ) )
#		    {
#		    push @toprint, "<img src=$fn>";
#		    }
#		elsif( 1 || grep( $_ eq $ext, @OTHERLIST ) )
#		    {
#		    push @toprint, "File:  <a href=$fn>$fn</a>";
#		    }
#		else
#		    {
#		    push @toprint, "File:  $fn";
#		    }
		}
	    push @toprint, "</table></center>\n";
	    &write_file( $ofn, @toprint );
	    }
	}
    }

my %ARGS = &parse_arguments({
    non_switches=>\@files
    });

&traverse_dirs( $files[0] );

&cleanup( $exit_status );
