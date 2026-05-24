#!/usr/bin/perl
#
#indx#	lq2xml.pl - (VERY brief explanation of what this file is/does)
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

my @answers = ();
my $right = 0;
my $num_answers = 0;
my $questionsofar = "";
my $infosection = "";
my $atmode = "";
my $hasinfo = 0;

our $exit_status = 0;

#########################################################################
#	Convert text to something acceptable to html.			#
#########################################################################
sub make_html
    {
    my ( $txt ) = @_;
    $txt =~ s/\&/\&amp;/g;
    $txt =~ s/</\&lt;/g;
    $txt =~ s/>/\&gt;/g;
    $txt =~ s/\n/<br>/gs;
    return $txt;
    }

#########################################################################
#	Dump question and answer read in so far.			#
#########################################################################
my @toprint;
sub dump_question
    {
    if( $infosection )
        {
	push( @toprint, "</pre></concept>" ) if( $hasinfo );
        push( @toprint, "\n<concept><pre>".&make_html($infosection) );
	$infosection = "";
	$hasinfo = 1;
	}
    push( @toprint, "\n<question>".&make_html($questionsofar)) if( $questionsofar );
    $questionsofar = "";
    if( ($num_answers>0) && ($atmode =~ /^\@t(\d+)/) )
	{
	my $right = $1 - 1;
	my $i;
	push( @toprint, "\n<answer right>".&make_html($answers[$right]));
	for( $i=0; $answers[$i] ne ""; $i++ )
	    {
	    push( @toprint, "\n<answer>".&make_html($answers[$i])) if( $i != $right );
	    }
	@answers = ();
	$num_answers = 0;
	}
    }

#########################################################################
#	Main								#
#########################################################################
my $ansmode = 0;

my %ARGS = &parse_arguments({
    switches=>
    	{
	"input_file"	=> "/dev/stdin",
	"output_file"	=> "/dev/stdout"
	}
    });

foreach $_ ( split(/\n/,&read_file( $ARGS{input_file} ) ) )
    {
    if( /^#/ )
        {
	# Ignore comments and headers
	}
    elsif( /^@/ )
        {
	&dump_question();
	s/^\@q/\@t/;
	s/^\@t/\@t1/ if( ! /^\@t(\d+)/ );
	$atmode = $_;
	$ansmode = 0;
	}
    elsif( /^>(.*)/ )
        {
	$answers[$num_answers++] = $1;
	$ansmode = 1;
	}
    elsif( $ansmode && ! /^@/ )
        {
	$answers[$num_answers-1] .= " $_";
	}
    elsif( $atmode =~ /^\@t/ )
        {
	$questionsofar .= " $_";
	}
    elsif( $atmode =~ /^\@i/ || $atmode =~ /^\@e/ )
	{
	$infosection .= " $_";
	}
    }
&dump_question();

&write_file( $ARGS{output_file}, @toprint );

&cleanup( $exit_status );
