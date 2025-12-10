#!/usr/bin/perl
# easy way to print out crazy expression
use POSIX;
for(my $x=0;$x<2*3.14159;$x+=0.005){
	print "$x\t";
	print 0.427704*pow( sqrt( pow((1+cos($x/1.557478+1.124917)),2)
	+pow(sin($x/1.557478+1.124917),2)) ,-1)+0.082971; 
	print "\n";
}
