#!/usr/bin/perl -w
#
#indx#	flash_cards.pl - (VERY brief explanation of what this file is/does)
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

use cpi_file qw( cleanup read_file write_file fatal );

my @non_switches;
my @toprint;
my %ARGS;
our $exit_status = 0;

my $DESTDIR="/home/chris/public_html/usmle";
my $TESTDIR=`/bin/pwd`;
chomp( $TESTDIR );
my $RETRIEVEDIR="$TESTDIR/incoming_htmls";
my %SUB_TO_URL =
    (
    "Anatomy"=>
	"http://usmle.myplayspace.com/members/FAanatomy/mccQ1A.php?subject=anatomy",
    "Psychology"=>
	"http://usmle.myplayspace.com/members/FApsychology/mccQ1A.php?subject=psychology",
    "Biochemistry"=>
	"http://usmle.myplayspace.com/members/FAbiochemistry/mccQ1A.php?subject=biochemistry",
    "Microbiology"=>
	"http://usmle.myplayspace.com/members/FAmicrobiology/mccQ1A.php?subject=microbiology",
    "Pathology"=>
	"http://usmle.myplayspace.com/members/FApathology/mccQ1A.php?subject=pathology",
    "Pharmacology"=>
	"http://usmle.myplayspace.com/members/FApharmacology/mccQ1A.php?subject=pharmacology",
    "Physiology"=>
	"http://usmle.myplayspace.com/members/FAphysiology/mccQ1A.php?subject=physiology",
    "Rapid_Recall"=>
	"http://usmle.myplayspace.com/members/rr/mccQ1A.php?subject=",
    "Concept_Blaster"=>
	"http://usmle.myplayspace.com/members/FAfree/mccQ1A.php?subject=",
    "Tommy_K"=>
	"http://usmle.myplayspace.com/members/tommyk/mccQ1A.php?subject=tommyk"
    );

#########################################################################
#	Print a usage message and die.  Called by parse_arguments().	#
#########################################################################
sub usage
    {
    my ( $msg ) = @_;
    &fatal("$msg\nUsage:  flash_cards (-r|-p|-i|-x) { SUBJECT }\n" .
        "Where SUBJECT is one of:\n\t".
        join("\n\t",(sort keys %SUB_TO_URL)));
    }

#########################################################################
#########################################################################
sub slurp_subject
    {
    my( $subject ) = @_;
    print "Grabbing $subject.\n";
    my $url = $SUB_TO_URL{ $subject };
    my $qnum;
    system("mkdir -p $DESTDIR") if( ! -d $DESTDIR );
    chdir( $RETRIEVEDIR ) || &fatal("Cannot chdir($RETRIEVEDIR):  $!");
    system("rm -f $subject.*.html");
    for( $qnum=1; ; $qnum++ )
	{
	my $outfn = sprintf("%s.%04d.html",$subject,$qnum);
	my $cmd = sprintf("wget -q '%s&nextq=%d' -O -",$url,$qnum);
	print "[$cmd]\n" if( $ARGS{verbosity} );
	open( INF, "$cmd |" ) || &fatal("Cannot run $cmd:  $!");
	my $filedata = "";
	my $bogus_record = "";
	while( $_ = <INF> )
	    {
	    $bogus_record++ if( /Sorry, we have no records/ );
	    $bogus_record++ if( /Sorry, no more questions/ );
	    $filedata .= $_;
	    }
	close( INF );
	last if( $bogus_record || $filedata eq "" );
	&write_file( $outfn, $filedata );
	}
    $qnum--;
    chdir( $TESTDIR ) || &fatal("Cannot chdir($TESTDIR):  $!");
    print "$qnum questions retrieved from $subject.\n";
    }

#########################################################################
#########################################################################
sub do_one_file
    {
    my( $curfile, $ind ) = @_;
    my $state = 0;
    push( @toprint, "<div id=sect_$ind style='display:none'>" );
    my $endfont = 0;
    my $sectctr = 0;
    foreach $_ ( split(/\n/,&read_file($curfile)) )
	{
	s/[\s\r\n]*$//g;
	next if( $_ eq "" );
	if( /<body/ )
	    { $state=1; }
	elsif( /<\/body/ )
	    { $state=0; }
	else
	    {
	    if( /<font color=red>/ )
	        {
	        s+(<font color=red>)+</div><div id=ans_$ind style='display:none'>$1+;
		$endfont = 1;
		}
	    elsif( /^<td align=left><font size=\+3>/ )
	        {
		if( $sectctr++ >= 1 )
		    {
		    s/<td align=left><font size=\+3>(.*?)<\/td>/<td align=left><font size=+3><div id=ans_$ind style='display:none'>$1<\/div><\/font><\/td>/;
		    }
		}
	    else
	        {
		s+(<p><font size=5 color=blue>A:)+</div><div id=ans_$ind style='display:none'>$1+;
		}
	    push( @toprint, "$_\n" ) if( $state==1 );
	    }
	}
    push( @toprint, "</font>" ) if( $endfont );
    push( @toprint, "</div>\n" );
    }

#########################################################################
#########################################################################
sub xml_one_file
    {
    my( $curfile ) = @_;
    my $state = 0;
    my $endfont = 0;
    my $sectctr = 0;
    my $blastermode = 0;
    push( @toprint, "<question>" );
    foreach $_ ( &read_file( $curfile ) )
	{
	s/[\s\r\n]*$//g;
	next if( $_ eq "" );
	if( /<body/ )
	    { $state=1; }
	elsif( /<\/body/ )
	    { $state=0; }
	else
	    {
	    $blastermode = 1 if( /Concept Blaster/ || /Rapid Recall/ );
	    if( $blastermode )
	        {
		s+</*tr>++g;
		s+</*td.*?>++g;
		s+</*table>++g;
		s+</*font.*?>++g;
		}

	    if( /<font color=red>/ )
	        {
	        s+(<font color=red>)+<answer>$1+;
		$endfont = 1;
		}
	    elsif( /<b>Buzzwords:/ )
	        {
		s+(<b>Buzzwords:)+<answer>$1+;
		}
	    elsif( /<b>Associated Pathology:/ )
	        {
		s+(<b>Associated Pathology:)+<answer>$1+;
		}
	    else
	        {
		s+(<p><font size=5 color=blue>A:)+<answer>$1+;
		}
	    push( @toprint, "$_\n" ) if( $state==1 );
	    }
	}
    push( @toprint, "</font>" ) if( $endfont );
    push( @toprint, "</answer></question>" );
    }

#########################################################################
#########################################################################
sub xml_subject
    {
    my( $subj ) = @_;
    print "Processing $subj.\n";
    my( @files ) = ();
    my( $fn ) = "$TESTDIR/$subj.xml";
    opendir( DP, $RETRIEVEDIR ) || &fatal("Cannot opendir($RETRIEVEDIR):  $!");
    while( $_ = readdir(DP) )
	{
        push( @files, "$RETRIEVEDIR/$_" ) if(/^$subj\..*\.html$/);
	}
    closedir( DP );
    my $numargs = scalar( @files );
    @toprint = ();
    my $i;
    for( $i=0; $i<=$#files; $i++ )
	{
	&xml_one_file( $files[$i] );
	}
    &write_file( $fn, @toprint );
    print "$i files processed.\n";
    }

#########################################################################
#########################################################################
sub xmlhtml_subject
    {
    my( $subj ) = @_;
    my( $cmd ) = "/home/chris/projects/q/q.pl < $TESTDIR/$subj.xml > $DESTDIR/$subj.html";
    print "$cmd\n";
    system( $cmd );
    }

#########################################################################
#########################################################################
sub process_subject
    {
    my( $subj ) = @_;
    print "Processing $subj.\n";
    my( @files ) = ();
    my( $fn ) = "$DESTDIR/$subj.html";
    opendir( DP, $RETRIEVEDIR ) || &fatal("Cannot opendir($RETRIEVEDIR):  $!");
    while( $_ = readdir(DP) )
	{
        push( @files, "$RETRIEVEDIR/$_" ) if(/^$subj\..*\.html$/);
	}
    closedir( DP );
    my $numargs = scalar( @files );
    @toprint = ();
    push( @toprint, <<EOF );
<script>
function display( id, val )
    {
    document.getElementById(id).style.display = val;
    }

function cookieval(name)
    {
    var cookievar = document.cookie.split("; ");
    for( i=0; i<cookievar.length; i++ )
        {
	if( name == cookievar[i].split("=")[0] )
	    { return cookievar[i].split("=")[1]; }
	}
    return "";
    }

var seen_val = new String( cookieval("${subj}_${numargs}") );

function get_seen(sectval)
    {
    if( seen_val == "" )
        {
	var ctr = $numargs;
	while( ctr-- > 0 )
	    {
	    seen_val += "0";
	    }
	}
    return parseInt( seen_val.charAt(sectval) );
    }

function put_seen(sectval,v)
    {
    if( seen_val == "" )
        {
	var ctr = $numargs;
	while( ctr-- > 0 )
	    {
	    seen_val += "0";
	    }
	}
    expiredate = new Date;
    expiredate.setMonth(expiredate.getMonth()+6);
    var nv = new String("");
    var ctr = $numargs;
    for( ctr=0; ctr<$numargs; ctr++ )
	{
        if( ctr == sectval )
	    {
	    nv += v;
	    }
	else if( seen_val == "" )
	    {
	    nv += "0";
	    }
	else
	    {
	    nv += seen_val.charAt(ctr);
	    }
	}
    seen_val = nv;

    document.cookie = "${subj}_${numargs}="+seen_val+";expires="+expiredate.toGMTString();
    }

var cur_section = 0;
function transition( offset )
    {
    display("sect_"+cur_section,"none");
    display("ans_"+cur_section,"none");
    with( window.document.form )
	{
	if( offset == 0 )
	    {
	    cur_section = section.value - 1;
	    put_seen( cur_section, 0 );
	    }
	else
	    {
	    var ctr = $numargs;
	    do  {
		cur_section = ( cur_section + offset + $numargs ) % $numargs;
		if( ctr-- < 0 )
		    {
		    alert("All questions now complete.  Clearing history.");
		    clear_history();
		    }
		} while( get_seen(cur_section) );
	    section.value = cur_section + 1;
	    }
	answerbutton.value = "Answer";
	}
    display("sect_"+cur_section,"block");
    display("ans_"+cur_section,"none");
    return false;
    }

function clear_history()
    {
    seen_val = new String("");
    put_seen( 0, 0 );
    }

function answer()
    {
    display("ans_"+cur_section,"block");
    with ( window.document.form )
        {
	if( answerbutton.value == "Answer" )
	    {
	    answerbutton.value = "Know it already";
	    }
	else
	    {
	    put_seen( cur_section, 1 );
	    transition( 1 );
	    }
	}
    }

</script>
<form name=form onSubmit='return false;'>
<table><tr><th>
<input type=button value=Previous onClick='transition(-1);'>
<input type=text name=section size=4 onChange='transition(0);'>
<input type=button value=Next onClick='transition(1);'>
</th><th>
<input type=button value=Top onClick='window.location="index.html";'>
<input type=button value="Forget history" onClick='clear_history();'>
<input type=button name=answerbutton value=Answer onClick='answer();'>
</th>
</tr></table>
</form>
<hr>
EOF
    my $i;
    for( $i=0; $i<=$#files; $i++ )
	{
	&do_one_file( $files[$i], $i );
	}

    push( @toprint, <<EOF );
<script>
cur_section = $numargs - 1;
transition(1);
</script>
EOF
    &write_file( $fn, @toprint );
    print "$i files processed.\n";
    }

#########################################################################
#########################################################################
sub genindex()
    {
    my ( $fn ) = @_;
    print "Generating $fn.\n";
    my $subj;
    @toprint = ();
    push( @toprint, <<EOF );
<center><table border=1>
<tr><th colspan=2>Top level directory</th></tr>
EOF
    foreach $subj ( sort keys %SUB_TO_URL )
        {
	push( @toprint, "<tr><th align=left>$subj:</th>" .
		    "<td><a href=$subj.html>$subj.html</a></td></tr>\n" );
	}
    push( @toprint, "</table></center>\n" );
    &write_file( $fn, @toprint );
    }

my $arg;
my @subjects = ();
%ARGS = &parse_arguments({
    flags		=> [ "retreive","process","index","xprocess","xhtmlprocess" ],
    non_switches	=> \@non_switches,
    switches=>
    	{
	verbosity	=>	0,
	}
    });

foreach $_ ( @non_switches )
    {
    if( $SUB_TO_URL{$_} )
        { push( @subjects, $_ ); }
    else
        { &usage("Unknown argument $_"); }
    }

@subjects = (sort keys %SUB_TO_URL) if( ! @subjects );

&usage("You must specify -r, -p, -xp, -xh or -i")
    unless ($ARGS{retrieve}||$ARGS{process}||$ARGS{index}||$ARGS{xprocess}||$ARGS{xhtmlprocess});

foreach $arg ( @subjects )
    {
    &slurp_subject($arg)	if( $ARGS{retrieve} );
    &process_subject($arg)	if( $ARGS{process} );
    &xml_subject($arg)		if( $ARGS{xprocess} );
    &xmlhtml_subject($arg)	if( $ARGS{xhtmlprocess} );
    }

&genindex("$DESTDIR/index.html") if( $ARGS{index} );

&cleanup( $exit_status );
