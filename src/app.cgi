#!/usr/bin/perl -w

use strict;

use lib "/usr/local/lib/perl";

use cpi_file qw( fatal read_file fqfiles_in cleanup files_in );
use cpi_cgi qw( CGIheader CGIreceive );
use cpi_filename qw( filename_to_text basename );
use cpi_vars;

my $exit_status = 0;

my @toprint;

sub title_of
    {
    return &filename_to_text( &basename( @_ ) );
    }

&CGIheader();

my @flist;
my %lengths;
for( my @todo=("."); @todo; )
    {
    my $processing = shift(@todo);
    if( -d $processing )
        { push( @todo, &fqfiles_in($processing) ); }
    elsif( $processing =~ /\.html/ )
        {
	my @pieces;
	foreach my $piece ( split(/\//,$processing) )
	    {
	    push( @pieces, $piece );
	    $lengths{ join("/",@pieces) }++;
	    }
	push( @flist, $processing );
	}
    }

push( @toprint,
    "</head><body bgcolor='#4070c0' link='white' vlink='white'><center>\n",
    "<table bgcolor='#60a0e0' border=1 style='border-collapse:collapse'>\n" );
foreach my $fname ( sort @flist )
    {
    push( @toprint, "<tr>" );
    my @pieces;
    foreach my $piece ( split(/\//,$fname) )
        {
	if( $piece =~ /\.html$/ )
	    {
	    push( @toprint, "<td><a href='$fname'>",
	        &title_of( $fname ),
		"</a></td>" );
	    }
	else
	    {
	    push( @pieces, $piece );
	    my $ind = join("/",@pieces);
	    push( @toprint,
		"<th valign=top align=left rowspan=$lengths{$ind}>",
		&title_of( $piece ),
		"</th>" ) if( $lengths{$ind} );
	    $lengths{$ind} = 0;
	    }
	}
    push( @toprint, "</tr>\n" );
    }

push( @toprint, "</table></center></body></html>\n" );

print @toprint;

&cleanup( $exit_status );
