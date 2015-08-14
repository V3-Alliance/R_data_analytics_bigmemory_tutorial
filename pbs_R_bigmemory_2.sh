#!/bin/bash

# pbs launching script R job:
# Exercises big.matrix using bigmemory. Uses just one node.

#     job name:
#PBS -N bigmemory_0

#     how many cpus and cores?
#PBS -l nodes=1:ppn=8

#     How long to run the job? (hours:minutes:seconds)
#PBS -l walltime=0:30:0

# Inherit the correct environment variables
#PBS -V

#     Name of output file:
#PBS -o tutorial_bigmemory_0.out

#     Environmental variables to make it work:

# Specify your email address to be notified of progress.
#PBS -M rrothwell@v3.org.au
# To receive an email:
#       - job is abored: 'a' 
#       - job begins execution: 'b'
#       - job terminates: 'e'
#       Note: Please ensure that the PBS -M option above is set.
#
#PBS -m abe
 
module load R
cd $PBS_O_WORKDIR
 
#     Launching the job!

R --vanilla CMD BATCH tutorial_foreach_2.R


