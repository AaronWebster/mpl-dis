#!/usr/bin/bash

for I in *.mat
do
				h5topng $I -o ${I%%.mat}-1.png
done
