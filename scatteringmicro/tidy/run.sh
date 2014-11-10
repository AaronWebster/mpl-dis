#!/bin/bash
#PBS -N scatter-mpi
#PBS -j oe
#PBS -o scatter-mpi.log
#PBS -m abe
#PBS -q normal
#PBS -l walltime=01:00:00

cd $PBS_O_WORKDIR

DIR="0000"
for I in $(seq 3 1 30)
do
	mpirun scatter --random-seed=10 --output-dir=$DIR$I --nscat=$I --events=1000000
done
