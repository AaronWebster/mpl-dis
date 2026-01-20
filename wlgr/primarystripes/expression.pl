#!/usr/bin/perl
# Generates theoretical primary stripe angle as a function of position around the ring
# Formula based on Bert's thesis analysis
use POSIX;

# Maximum value for clipping (matches plot y-axis range)
my $MAX_VALUE = 1.5;

for(my $x=0;$x<2*3.14159;$x+=0.005){
	print "$x\t";
	
	# Compute angle: theta = x/1.557478 + 1.124917
	my $theta = $x/1.557478 + 1.124917;
	
	# Primary stripe angle formula: 0.427704 * |1 + e^(i*theta)|^(-1) + 0.082971
	# Where |1 + e^(i*theta)| = sqrt((1+cos(theta))^2 + sin(theta)^2)
	my $magnitude = sqrt( pow((1+cos($theta)),2) + pow(sin($theta),2) );
	my $value = 0.427704 * pow($magnitude, -1) + 0.082971;
	
	# Clip values to avoid singularity spike at theta ≈ π (where magnitude → 0)
	if ($value > $MAX_VALUE) {
		$value = $MAX_VALUE;
	}
	
	print $value; 
	print "\n";
}
