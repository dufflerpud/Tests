#!/usr/bin/perl
#
#indx#	order.pl - (VERY brief explanation of what this file is/does)
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

use lib "/usr/local/lib/perl";

use cpi_file qw( read_file write_file cleanup );
use cpi_arguments qw( parse_arguments );

our $exit_status = 0;

my %ARGS = &parse_arguments({
    switches=>
    	{
	"input_file"	=> "/dev/stdin",
	"output_file"	=> "/dev/stdout"
	}
    });

foreach $askorderpart ( split(/<askorder>/,&read_file($ARGS{input_file}) ) )
    {
    if( $askorderpart =~ /(.*)<\/askorder>/ )
        {
	my( $askorder ) = $1;
	my($question,@orderparts)=split(/(<order>|<right>|<wrong>)/,$askorder);
	my @order = ();
	my @wrong = ();
	my @right = ();
	foreach $_ ( @orderparts )
	    {
	    if( /(.*)<\/order>/ )
	        { push(@order,$1); }
	    elsif( /(.*)<\/right>/ )
	        { push(@right,$1); }
	    elsif( /(.*)<\/wrong>/ )
	        { push(@wrong,$1); }
	    }
	push( @toprint, "<concept><table><tr><th colspan=2>$question</th></tr>\n" );
	for( $_=0; $_<scalar(@order); $_++ )
	    {
	    push( @toprint, "<tr><td align=right>".($_+1).
	        "</td><td>$order[$_]</td></tr>\n" );
	    }
	foreach $_ ( @right )
	    { push(@toprint, "<tr><td align=right>*</td><td>$_</td></tr>\n"); }
	push(@toprint, "</table>\n");

	while( @order )
	    {
	    push( @toprint, "<question>$question\n" );
	    foreach $_ ( @order )
	        { push( @toprint, "    <answer>$_</answer>\n" ); }
	    foreach $_ ( @right )
	        { push( @toprint, "    <answer right>$_</answer>\n" ); }
	    foreach $_ ( @wrong )
	        { push( @toprint, "    <answer>$_</answer>\n" ); }
	    push( @toprint, "</question>\n" );
	    shift( @order );
	    }
	while( @right )
	    {
	    push( @toprint, "<question>$question\n" );
	    foreach $_ ( shift(@right), @wrong )
	        { push( @toprint, "    <answer>$_</answer>\n" ); }
	    push( @toprint, "</question>\n" );
	    }
	push( @toprint, "</concept>" );
	}
    }

&write_file( $ARGS{output_file}, @toprint );
&cleanup( $exit_status );
