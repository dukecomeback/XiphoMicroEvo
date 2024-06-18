#!/usr/bin/perl -w
my $usage=<<E;
----------------------------------------
I concatenated sequence with the same head

Usage: $0 *.fa(or stdin) >all.fa.concatenated

			Du Kang 2017-1-30
---------------------------------------
E

while ($_=shift @ARGV) {
	push @file, $_;
}
die $usage if (!@file and -t STDIN);

open IN, "cat @file |" or die $!;
while (<IN>) {
	next if /^\s*$/;
	if (/>/) {
		$name = />(\S+?)_/? $1 : />(\S+)/? $1 : 0;
	}else{
		chomp;
		$seq{$name} .= $_;
	}
}
foreach $key (keys %seq) {
	print ">$key\n$seq{$key}\n";
}
