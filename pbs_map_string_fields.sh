#!/bin/bash

# Run with a command line like:
# $ qsub -t 1987-2008  pbs_map_string_fields.sh

# pbs launching application map_fields job:

#     job name:
#PBS -N map_fields

#     how many cpus and cores?
#PBS -l nodes=1:ppn=1

#      how much memory
#PBS -l mem=1G

#     How long to run the job? (hours:minutes:seconds)
#PBS -l walltime=0:5:0

# Inherit the correct environment variables
#PBS -V

#     Name of output file:
#PBS -o map_fields.out
# Join the output and error streams so we can view them together using qpeek 
#PBS -j oe

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
 
module load boost
cd $PBS_O_WORKDIR
 
#     Launching the job as a job array!

#PBS -t 1987-1988

./map_fields /lustre/pVPAC0012/raw/${PBS_ARRAYID}.csv /lustre/pVPAC0012/preprocessed/${PBS_ARRAYID}.csv /lustre/pVPAC0012/reference_data/

# map_fields-<1987-2008>.out will contain the mapping 
# between string identifiers and integers for:
#        airports (flight origin and destination)
#        carriers
#        planes
#        cancellation codes.
