#!/usr/bin/perl

# turn the colorbrewer2 definitions into xcolor definitions

# open input file
open(IN,"<colorbrewer_all_schemes.csv") || die "Can't open input.\n";
open(OUT1,">colors.tex") || die "Can't open output.\n";
open(OUT2,">preview.tex") || die "Can't open output.\n";

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
$here = 0;
for($i=0;$i<scalar(@array);++$i){
	# get first line
	@line = split(',',@array[$i]);
	if($line[9]){ print OUT2 "\\section*{$line[0]}\n"; }
	for($j=0;$j<$line[1];++$j){
		@line2 = split(',',@array[$i++]);
		print OUT1 "\\definecolor{";
		print OUT1 $line[0];
		print OUT1 $line[1];
		print OUT1 $line[2];
		print OUT1 $line2[4];

		print OUT2 "\\tikz \\fill [$line[0]$line[1]$line[2]$line2[4]] (0.0,0.0) rectangle (0.5,0.5);\n";
		#if($line[1]!=$here){
		#	$here=$line[1];
		#	print OUT2 "$line[0]$line[1]$line[2]\n";
		#	print OUT2 "\\\\";
		#}

		#print $line2[5];
		print OUT1 "}{RGB}{";
		print OUT1 $line2[6];
		print OUT1 ",";
		print OUT1 $line2[7];
		print OUT1 ",";
		print OUT1 $line2[8];
		print OUT1 "}";
		#print $line2[4];
		print OUT1 "\n";
	}
	if($line[1]){ print OUT2 "$line[0]$line[1]$line[2]\\\\"; }
}

$here = 0;
for($i=0;$i<scalar(@array);++$i){
	# get first line
	@line = split(',',@array[$i]);
	if($line[1]){ 
		print OUT1 "\\pgfplotsset{\/pgfplots\/colormap={$line[0]$line[1]$line[2]}{\n";
		print OUT2 <<EOF
\\section*{$line[0]$line[1]$line[2]}
\\begin{tikzpicture}
\\begin{axis}[
    hide axis,
    scale only axis,
    height=0pt,
    width=0pt,
    colormap name = $line[0]$line[1]$line[2],
    colorbar horizontal,
    point meta min=0,
    point meta max=1,
    colorbar style={
        width=10cm,
    }]
    \\addplot [draw=none] coordinates {(0,0)};
\\end{axis}
\\end{tikzpicture}
EOF

	}

	for($j=0;$j<$line[1];++$j){
		@line2 = split(',',@array[$i++]);

		print OUT1 "\trgb255=(";
		print OUT1 $line2[6];
		print OUT1 ",";
		print OUT1 $line2[7];
		print OUT1 ",";
		print OUT1 $line2[8];
		print OUT1 ") \n";
	}
	if($line[1]){ print OUT1 "}}\n"; }
}

close(IN);
close(OUT1);
close(OUT2);
