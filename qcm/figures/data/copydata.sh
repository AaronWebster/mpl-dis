#!/usr/bin/bash
# copies data from /tmp to here under some name I give it
# used with plotdata.m 

for I in ang-freq ang-res ang freq-res freq res temp 
do
 cp /tmp/plotdata-$I.txt $1-$I.txt
done
