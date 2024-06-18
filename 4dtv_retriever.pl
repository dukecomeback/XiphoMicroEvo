#!/usr/bin/perl -w

my $usage=<<EOF;
----------------------------------------------
I retrieve specified site from codon alignment, by default, I output 4dtv sites.

Usage: $0 cds_aln.fa(or stdin) (options) >output.fa

Options:
-4dtv 	4 fold degenerate site (default). What is 4DTV? https://www.mun.ca/biology/scarr/Gr10-27_4fold.html
-3	the 3st site of codon
-1,2	the 1st and 2nd site of codon

			Du Kang 2021-8-24
----------------------------------------------
EOF

$parameter="-4dtv";
while ($_=shift @ARGV) {
	if (/^-/) {
		$parameter=$_;
	}else{
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
$l=length $seq{$name};

if ($parameter=~/4dtv/) {
	for ($i=0; $i<$l-3; $i+=3) {
		$count=0;
		foreach $name (@name){
			$codon=substr($seq{$name},$i,3);
			$count++ if $codon=~/^(TC|CT|CC|CG|AC|GT|GC|GG)/i;
		}
		next unless @name==$count;	#if all yes, then it's 4dtv site
		foreach $name (@name){
			$dtv{$name}.=substr($seq{$name},$i+2,1);
		}
	}
	foreach $name (@name){
		print ">$name\n$dtv{$name}\n";
	}

} else {
	foreach $name (@name){
		print ">$name\n";
		for ($i=0; $i<=$l-1; $i++) {$n=$i%3+1; print substr($seq{$name},$i,1) if $parameter=~/$n/}
		print "\n";
	}
}
