#!/usr/bin/perl -w
#
#indx#	xml_to_quiz.pl - (VERY brief explanation of what this file is/does)
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

use cpi_file qw( fatal read_file write_file first_in_path );
use cpi_arguments qw( parse_arguments );
use cpi_filename qw( text_to_filename );

#$| = 1;			# Uncomment for easier debugging

use strict;

my $origfile = $0;

my %ARGS = &parse_arguments({
    flags	=>	[ "preprocess" ],
    switches=>
    	{
	"mode"	=>	"js",
	"tfs"	=>	{alias => ["-mode=tfs"] },
	"js"	=>	{alias => ["-mode=js"] }
	}
    });

if( $ARGS{mode} eq "tfs" )
    { $origfile =~ s/\.pl$/.tfs/g; }	# tfs should be in same dir as pl.
else
    { $origfile =~ s/\.pl$/.js/g; }	# html should be in same dir as pl.

my $SEP = "%%";

sub fix_permuted_questions
    {
    my( $inp ) = @_;
    my @result = ();
    foreach my $question_clause ( split(/(<question.*?<\/question>)/s,$inp) )
	{
	if( $question_clause !~ /^(<question[^>]*?)\s*\bpermute="([^"]*)"([^>]*>)(.*)(<\/question>)/s )
	    { push( @result, $question_clause ); }
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
			my $new_text=$pre_for.$post_for.$answer_text.$answer_end;
			$associated{$subval}{$new_text} = 1;
			$answers{$new_text} = 1;
			}
		    }
		}

	    my $sep = "";
	    foreach my $subval ( sort keys %associated )
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
			{ push(@wrong,$_); }
		    }
		push( @result, $sep,$qstart0,$qstart1,$subst_qtext,
		    sort @right,sort @wrong,$qend );
		$sep = "\n";
		}
	    }
	}
    return join("",@result);
    }

my @questions;
my @results;
my @sections;
my @concepts;

my $tmplfile = &read_file( $origfile );
$tmplfile =~ s:^//.*?\n::gm;
my $xmlcontents = join("",<STDIN>);

$xmlcontents = &fix_permuted_questions( $xmlcontents );

if( $ARGS{preprocess} )
    { print $xmlcontents; exit(0); }

$xmlcontents =~ s/<concept.*?>/<concept>/gis;
$xmlcontents =~ s+</concept.*?>+<concept>+gis;	# OK, this is cheating
						# An end of concept will
						# cause questions thereafter
						# to have an empty concept
						# This will force the next
						# concept
$xmlcontents =~ s/<section.*?>/<section>/gis;
$xmlcontents =~ s+</section.*?>+<section>+gis;	# Cheating for the same reason
$xmlcontents =~ s/<question.*?>/<question>/gis;
$xmlcontents =~ s+</question.*?>++gis;
$xmlcontents =~ s+<explanation.*?>+<explanation>+gis;
$xmlcontents =~ s+</explanation.*?>++gis;
#$xmlcontents =~ s/<answer.*?>/<answer>/gis;
$xmlcontents =~ s+</answer.*?>++gis;
$xmlcontents =~ s/\\/\\\\/g;
$xmlcontents =~ s/"/\\"/g;
$xmlcontents =~ s/[\r\n]+/ /gs;


my ( $prog, $vname );
if( ($prog = &first_in_path( "md5sum" )) || ($prog=&first_in_path("sum")) )
    {
    my $TMPFILE = "/tmp/q.$$";
    &write_file( $TMPFILE, $xmlcontents );

    $vname = &read_file( "$prog < $TMPFILE |" );
    $vname =~ s/[^\w].*//gs;
    $vname = "q_" . substr( $vname, 0, 10 );
    unlink( $TMPFILE );
    }
else
    {
    $vname = "q_".time()."_$$";
    }

my $question_text = "";
my $section_text = "";
my $concept_text = "";
my $total_questions = 0;

my $concept_num = -1;
my $concept_ind = 0;
my $section_num = -1;
my $section_ind = 0;

my $concepts_in_file = 0;
my $concept;
foreach $concept ( split(/<concept>/,$xmlcontents) )
    {
    my $sections_in_concept = 0;
    my $section;
    $concept_num = -1;
    foreach $section ( split(/<section>/,$concept) )
	{
	my $questions_in_section = 0;
	my $qatok;
	$section_num = -1;
	foreach $qatok ( split(/<question>/,$section) )
	    {
	    if( $questions_in_section )
		{
		$_ = $qatok;
		s/<answer\s+right\s*>/<answer>RiGhT/gis;
		my( @answers ) = split(/<answer>/);
		grep( s/^[\r\n\s]*//m, @answers );
		grep( s/[\r\n\s]*$//m, @answers );
		my ( $question_explanation ) = shift( @answers );
		my( $question, $explanation ) =
		    split("<explanation>",$question_explanation);
		$explanation = "" if( ! $explanation );
		my @right0 = grep( /^RiGhT/, @answers );
		my @right1 = grep( s/^RiGhT//g, @right0 );
		my @wrong = grep( !/^RiGhT/, @answers );
		push( @right1, shift(@wrong) ) if( ! @right1 );
		&fatal("Malformed question:  $qatok") unless (@right1);
		if( $ARGS{mode} eq "js" )
		    {
		    push( @questions,
			join( $SEP,
			    $concept_num, $section_num, $question, $explanation,
			    @right1, @wrong ) );
		    }
		else
		    {
		    grep( s/RiGhT//g, @answers );
		    chomp( $question );
		    $question =~ s/(<br>)*$//g;
		    my $qtok = &text_to_filename( $question );
		    my $rtok = &text_to_filename( $right1[0] );
		    push( @questions,
		        "\t\"" . $total_questions . "\"\t{\n"
		        . "\t\toneof $qtok \"$question\" [ "
			    . join( ", ",
			        map { &text_to_filename($_) . " \"$_\"" }
				    @answers )
			    . " ] random_order checks line_per;\n"
		        . "\t\t}\n" );
		    push( @results,
		        "\t\"" . $total_questions . "\"\t{\n"
		        . "\t\tright_wrong( $qtok, \"$rtok\", $concept_num );\n"
		        . "\t\t$qtok=\"\";\n"
		        . "\t\t}\n" );
		    }
		$total_questions++;
		}
	    elsif( $sections_in_concept )
	        {
		push( @sections, $qatok );
		$section_num = $section_ind++;
		}
	    elsif( $concepts_in_file )
	        {
		$concept_num = $concept_ind++;
		if( $ARGS{mode} eq "js" )
		    { push( @concepts, $qatok ); }
		else
		    {
		    push( @concepts,
			"\t\"$concept_num\"\t{\n"
			. "\t\thtml \"$qatok\";\n"
			. "\t\t}\n" );
		    }
		}
	    else
	        {
		}
	    $questions_in_section++;
	    }
	$sections_in_concept++;
	}
    $concepts_in_file++;
    }

my $result_text;

if( $ARGS{mode} eq "js" )
    {
    $result_text = ( @results ? '"'.join("\",\n\"",@questions).'"': "" );
    $question_text = ( @questions ? '"'.join("\",\n\"",@questions).'"': "" );
    $concept_text  = ( @concepts  ? '"'.join("\",\n\"",@concepts).'"' : "" );
    $section_text  = ( @sections  ? '"'.join("\",\n\"",@sections).'"' : "" );
    }
else
    {
    $result_text = join("\n",@results);
    $question_text = join("\n",@questions);
    $concept_text = join("\n",@concepts);
    $section_text  = (@sections ? "html \"".join("\n",@sections)."\";" : "");
    }

$tmplfile =~ s+\[RESULTS\]+$result_text+gs;
$tmplfile =~ s+\[QUESTIONS\]+$question_text+gs;
$tmplfile =~ s+\[SECTIONS\]+$section_text+gs;
$tmplfile =~ s+\[CONCEPTS\]+$concept_text+gs;
$tmplfile =~ s+\[NUMBER_QUESTIONS\]+$total_questions+gs;
$tmplfile =~ s+\[UNIQUENAME\]+$vname+gs;
print $tmplfile;
