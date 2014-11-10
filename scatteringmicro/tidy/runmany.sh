#!/bin/bash

rm lista listb
DIR=onlyss
for I in $(seq 5 1 30); do
	echo "./scatter --random-seed=10 --nscat=$I --events=1000000 --output-dir=$DIR$I" >> lista
	echo "h5totxt $DIR$I/*.h5 > $DIR$I/phi.dat" >> listb
done

parallel --eta -a lista
parallel --eta -a listb
