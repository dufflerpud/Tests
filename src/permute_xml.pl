#!/usr/bin/perl -w
#
#indx#	permute_xml.pl - (VERY brief explanation of what this file is/does)
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

use cpi_file qw( read_file cleanup );
use cpi_arguments qw( parse_arguments );
use cpi_vars;

our $exit_status = 0;

my %ARGS = &parse_arguments({
    switches=>
    	{
	"input_file"	=> "/dev/stdin",
	"output_file"	=> "/dev/stdout"
	}
    });
my @toprint;

my $inp = &read_file( $ARGS{input_file} );

#print "inp=[$inp]\n";
foreach my $question_clause ( split(/(<question.*?<\/question>)/s,$inp) )
    {
    if( $question_clause !~ /^(<question[^>]*?)\s*\bpermute="([^"]*)"([^>]*>)(.*)(<\/question>)/s )
        { push( @toprint, $question_clause ); }
    else
        {
	my($qstart0,$qpermute,$qstart1,$toparse,$qend) = ($1,$2,$3,$4,$5);
	my $qtext = "";
	my %answers = ();
	my %associated = ();
	foreach my $answer_clause ( split(/(\s*<answer.*?<\/answer>)/s,$toparse) )
	    {
	    if( $answer_clause !~ /^(\s*<answer.*?>)(.*)(<\/answer>)$/s )
	        { $qtext .= $answer_clause; }
	    else
	        {
		my ($answer_attributes,$answer_text,$answer_end) = ($1,$2,$3);
		if( $answer_attributes !~ /^(.*?)\s*\bfor="(.*)"(.*)/s )
		    {
		    $answers{$answer_clause} = 1;
		    }
		else
		    {
		    my ( $pre_for, $subval, $post_for ) = ( $1, $2, $3 );
		    #print "Adding $answer_text to associated{$subval}.\n";
		    my $new_text=$pre_for.$post_for.$answer_text.$answer_end;
		    $associated{$subval}{$new_text} = 1;
		    $answers{$new_text} = 1;
		    }
		}
	    }

	my $sep = "";
	foreach my $subval ( keys %associated )
	    {
	    my $subst_qtext = $qtext;
	    $subst_qtext =~ s+$qpermute+$subval+gs;
	    my @right = ();
	    my @wrong = ();
	    foreach my $answer ( keys %answers )
	        {
		$_ = $answer;
		if( $associated{$subval}{$_} )
		    { s/>/ right>/; push(@right,$_); }
		else
		    { s/>/ wrong>/; push(@wrong,$_); }
		}
	    push( @toprint, $sep,$qstart0,$qstart1,$subst_qtext,
	        sort @right,sort @wrong,$qend );
	    $sep = "\n";
	    }
	}
    }

&write_file( $ARGS{output_file}, @toprint );

&cleanup( $exit_status );
