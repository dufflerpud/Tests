#!/usr/local/bin/perl
#
#indx#	tab2xml.pl - (VERY brief explanation of what this file is/does)
#@HDR@	$Id$
#@HDR@
#@HDR@	Copyright (c) 2024-2026 Christopher Caldwell (Christopher.M.Caldwell0@gmail.com)
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

my $prog = $0;
my $numanswers = 1;
my @recname = ();
my @fields = ();

sub fatal
    {
    print STDERR "$_[0]\n";
    exit(1);
    }

sub usage
    {
    &fatal(<<EOF);
$_[0]

Usage:  $prog [number answers] < tab_file > xml_file
EOF
    }

sub gen_answers
    {
    my( $arap, $right, $numans ) = @_;
    my( @sofar ) = ( ${$arap}[$right] );
    print "<answer right>".${$arap}[$right]."\n";
    $numans--;
    while( $numans-- > 0 )
        {
	my $try;
	do  {
	    $try = int( rand() * scalar(@{$arap}) );
	    } while ( grep( $_ eq ${$arap}[$try], @sofar ) );
	push( @sofar, ${$arap}[$right] );
	print "<answer>".${$arap}[$try]."\n";
	}
    }

sub read_line
    {
    if( $_ = <STDIN> )
        {
	s/[\r\n]//gs;
	s/\t\t*/\t/g;
	}
    return $_;
    }

&usage("Unknown arguments") if( scalar(@ARGV) > 1 );
if( scalar(@ARGV) > 0 )
    {
    $numanswers = $ARGV[0];
    &usage("Illegal number of answers") if( $numanswers < 1 );
    }

$_ = &read_line();
my( $lookfor, @headings ) = split(/\t/);
my( $num_fields ) = scalar(@headings);
my ( $numqs, $q, $fnum );

for( $numqs=0; $_=&read_line(); $numqs++ )
    {
    my $dummy;
    my @toks;
    ( $recname[$numqs], @toks ) = split(/\t/);
    &fatal("Definition of $recname[$numqs] has the wrong number of fields")
        if( scalar(@toks) != $num_fields );
    for( $fnum=0; $fnum<$num_fields; $fnum++ )
        { $fields[$fnum][$numqs] = $toks[$fnum]; }
    }

#print "<concept><table border=1><tr><th>$lookfor</th>";
#for( $fnum=0; $fnum<$num_fields; $fnum++ )
#    { print "<th>$headings[$fnum]</th>"; }
#print "</tr>";
#for( $q=0; $q<$numqs; $q++ )
#    {
#    print "<tr><th align=left>$recname[$q]</th>";
#    for( $fnum=0; $fnum<$num_fields; $fnum++ )
#        {
#	print "<td>$fields[$fnum][$q]</td>";
#	}
#    print "</tr>\n";
#    }
#print "</table>\n";
for( $q=0; $q<$numqs; $q++ )
    {
    for( $fnum=0; $fnum<$num_fields; $fnum++ )
        {
	$_ = $headings[$fnum];
	s/$lookfor/$recname[$q]/;
	print "<question>$_\n";
	&gen_answers( $fields[$fnum], $q, $numanswers );
	}
    }
