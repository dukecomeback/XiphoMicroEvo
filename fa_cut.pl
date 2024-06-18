#!/usr/bin/perl -w

my $usage=<<EOF;
----------------------------------------------
Feed me a alignment in fasta, I'll randomly cut out -l bp

Usage: $0 input(or stdin) (-l 1000)

	-l 	length of alignment to cut, default 1000

			Du Kang 2021-9-17
----------------------------------------------
EOF

$l=1000;
while ($_=shift @ARGV) {
	if (/^-l$/) {
		$l=shift @ARGV;
	}elsif (!/^-/) {
		push @file, $_;
	}
}
die $usage if (!@file and -t STDIN);

open IN, "cat @file |" or die $!;
while(<IN>){
	if (/>(\S+)/) {
		$name=$1;
		push @name, $name;
	}else{
		chomp;
		$seq{$name}.=$_;
	}
}

$length=length $seq{$name};
die "Not enougth length to cut!\n" if $l>$length;
$max=$length-$l+1;
$start=int(rand($max));
	# a int between 0 and $max

foreach $name (@name){
	print ">$name\n";
	print substr($seq{$name},$start,$l);
	print "\n";
}
