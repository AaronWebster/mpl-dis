#!/bin/bash
# setup.sh

N=100	   # samples
MIN=0			 # minimum
MAX=1000 # maximum

rm runmany.in filenames.in

# create file with the list of commands
V=0
for I in $(linspace $MIN $MAX $N) 
do 
	VV=$(printf %.5d $V)
	echo "./distsprpixelconverge.m $VV $I" >> runmany.in 
	echo $VV-distsprpixelconverge$I.dat >> filenames.in
	let V=($V+1)
done

N=50	   # samples
MIN=1000			 # minimum
MAX=10000 # maximum
for I in $(linspace $MIN $MAX $N) 
do 
	VV=$(printf %.5d $V)
	echo "./distsprpixelconverge.m $VV $I" >> runmany.in 
	echo $VV-distsprpixelconverge$I.dat >> filenames.in
	let V=($V+1)
done

N=25	   # samples
MIN=10000			 # minimum
MAX=20000 # maximum
for I in $(linspace $MIN $MAX $N) 
do 
	VV=$(printf %.5d $V)
	echo "./distsprpixelconverge.m $VV $I" >> runmany.in 
	echo $VV-distsprpixelconverge$I.dat >> filenames.in
	let V=($V+1)
done
