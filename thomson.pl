#!/usr/bin/perl -w

use LWP::Simple;
use URI;
use HTML::TableExtract;
use strict;

our $URL = "http://192.168.100.1/Diagnostics.asp";
our $statfile = "/tmp/thomson-diag";

my @downstream;
my @upstream;

sub connect_and_parse
{
	#get($URL);
	#my $page = get($URL) or die "Unable to get page";

	our $te = HTML::TableExtract->new( subtables=>1 );
	#$te->parse($page);

	$te->parse_file($statfile);

	my $downrows = $te->table(4,0)->rows;

	for ( my $rownum = 1; $rownum < @$downrows; $rownum++)
	{
		my ($channel, $freq, $power, $snr, $ber, $modulation) = @{$downrows->[$rownum]};
		#print "   ", join(',', @{$downrows->[$rownum]} ), "\n";
		
		$freq = (split / /, $freq)[0];
		$snr = (split / /, $snr)[0];
		$power = (split / /, $power)[0];

		push @downstream, { freq => $freq, power => $power, snr => $snr };
	}
}

sub print_config
{
	print "graph_title Thomson Signal to Noise (dB)\n";
	print "graph_vlabel dB (decibels)\n";
	print "graph_category thomson\n";

        for my $downrow ( 0 .. @downstream-1)
        {
		print "downstream_" . $downrow . "_snr.label Downstream CH" . $downrow . "\n";

	}

	exit 0;
}

sub print_values
{
	for my $downrow ( 0 .. @downstream-1)
	{
		my $chan = $downstream[$downrow];
		print "downstream_" . $downrow . "_snr.value " . $chan->{'snr'} . "\n";
	
	}
}

connect_and_parse();

if ( $ARGV[0] && $ARGV[0] eq "config" ) {
        print_config();
}

print_values();
