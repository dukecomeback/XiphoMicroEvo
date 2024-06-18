#!/usr/bin/perl -w

my $usage=<<EOF;
----------------------------------------------
I transform .maf into multiple fasta files, each alignment block will be in one fasta file: fasta/chr_start_end.fa. However, with paramter -c chr:start:end, I only print out the specific region

Usage: $0 input(or stdin) (options)

Options:
-l 	threshold for reference length, default 1000
-f 	assign the folder where result fasta file will be, default fasta/
-c	cut out the assigned region: chr:start:end

			Du Kang 2021-9-15
----------------------------------------------
EOF

$l=1000;
$f="fasta";
while ($_=shift @ARGV) {
	if (/^-l$/) {
		$l=shift @ARGV;
	}elsif (/^-f$/) {
		$f=shift @ARGV;
	}elsif (/^-c$/) {
		$c=shift @ARGV;
	}elsif (!/^-/) {
		push @file, $_;
	}
}
die $usage if (!@file and -t STDIN);

if ($c) {
	($chr,$start,$end)=$c=~/(\S+):(\d+):(\d+)/;
	open IN, "cat @file |" or die $!;
	while(<IN>){
		next unless /^(a|s) /;
		if (/^a /){$sline=0; next}
		$sline++;
		@F=split;
		if($sline==1){
			$s=$F[2];
			$e=$F[2]+$F[3]-1;
			$overlap= ($F[1] eq $chr and &overlap("$s..$e", "$start..$end"))? 1 : 0;
			$exist++ if $overlap;
			next unless $overlap;
			@tmp=sort {$a<=>$b} ($s,$e,$start,$end);
			($S,$E)=($tmp[1],$tmp[2]);

			$l=length $F[-1];
			$p=$s-1;
			foreach $i (0..$l-1){
				$tmp= substr($F[-1],$i,1);
				$p++ unless $tmp eq "-";
				$cutS=$i if $p==$S;
				$cutE=$i and last if $p==$E;
			}
			$cutL=$cutE-$cutS+1;
		}
		next unless $overlap;
		$head= $sline==1? "$F[1]:$S:$E" : $F[1];
		$seq= substr($F[-1], $cutS, $cutL);
		print ">$head\n$seq\n";
	}
	print "Region do not exist in this maf file\n" unless $exist;

}else{
	-e $f or mkdir $f;
	open IN, "cat @file |" or die $!;
	$sline=0;
	while(<IN>){
		if (!/^s/){ $sline=0; close OUT; next }
		@F=split;
		$sline++;
		if($sline==1){$on= $F[3]>=$l? 1 : 0}
		next unless $on;

		$chr=$F[1];
		$start=$F[2];
		$end=$start+$F[3]-1;
		$strand=$F[4];
		$length=$F[5];
		($s,$e)= $strand eq "+"? ($start,$end) : ($length-$end-1,$length-$start-1);

		open OUT, ">>$f/$chr\_$s\_$e.fa" if $sline==1;
		print OUT ">$chr\_$s\_$e\n$F[-1]\n";
	}
}

########################## subs ########################
sub overlap{
	# I eat in two region strings, the query could only be one region while the subject could be multiple regions
	# eg: &overlap(1..3, 5..8_2..4)
	my $query=shift @_;
	my $subject=shift @_;
	my ($a,$b)= $query=~/(\d+)\.\.(\d+)/;
	my $overlap=0;
	foreach $i (split /_/, $subject){
        	my ($s,$e)= $i=~/(\d+)\.\.(\d+)/;
        	unless ($a>$e or $b<$s){$overlap=1; last}
	}
return $overlap;
}
