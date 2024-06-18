#!/usr/bin/perl -w

my $usage=<<EOF;
----------------------------------------------
I randomly sample regions that are at least -d kb away from each other

Usage: $0 input(or stdin) (-d 20000)

	-d 	the least distance between samples, default 20000

demo of input:
mac_NC_036443.1_10006914_10009722
mac_NC_036443.1_10010257_10013735
mac_NC_036443.1_10023540_10024558
mac_NC_036443.1_10026026_10035542
mac_NC_036443.1_10039501_10041920

			Du Kang 2021-9-17
----------------------------------------------
EOF

use IntervalTree;
use List::Util qw/shuffle/;

$distance=20000;
while ($_=shift @ARGV) {
	if (/^-d$/) {
		$distance=shift @ARGV;
	}elsif (!/^-/) {
		push @file, $_;
	}
}
die $usage if (!@file and -t STDIN);

open IN, "cat @file |" or die $!;
while(<IN>){ @F=split; push @population, $F[0] }

@population=shuffle @population;
$n=0;
while ($_=shift @population) {
	($chr,$s,$e)=$_=~/(\S+)_(\d+)_(\d+)/;
	${$chr}=IntervalTree->new() unless ${$chr};
	$exit=${$chr}->find($s,$e);
	next if @$exit;

	print "$_\n";
	${$chr}->insert($s-$distance,$e+$distance,"exist");
	$n++;
}

