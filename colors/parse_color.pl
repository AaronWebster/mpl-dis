#!/usr/bin/perl

# turn the colorbrewer2 definitions into xcolor definitions

# open input file
open(IN,"<colorbrewer_all_schemes.csv") || die "Can't open input\n";

# push input file into array
my @array;
while(<IN>){
	chomp;
	push @array, $_;
}
close(IN);

# remove the first element - the header
shift @array;

# loop over elements
for($i=0;$i<scalar(@array);++$i){
	# get first line
	@line = split(',',@array[$i]);
	for($j=0;$j<$line[1];++$j){
		@line2 = split(',',@array[$i++]);
		print "\\definecolor{";
		print $line[0];
		print $line[1];
		print $line[2];
		print $line2[4];
		#print $line2[5];
		print "}{RGB}{";
		print $line2[6];
		print ",";
		print $line2[7];
		print ",";
		print $line2[8];
		print "}";

		#print $line2[4];
		print "\n";
	}
}
