# R Data Analytics Bigmemory Tutorial
Tutorials that exercise the features of the R bigmemory package for HPC data analytics.

As these R scripts are intended to be run on a HPC cluster there are a number of PBS
scripts to run the R code via the PBS queue, which in turn distribute the computation 
across the nodes of the cluster.

The PBS scripts are:
    * pbs_R_bigmemory_2.sh
    * pbs_R_bigmemory_3.sh
    * pbs_R_bigmemory_4.sh
    * pbs_R_bigmemory_5.sh
    * pbs_R_bigmemory_6.sh
    * pbs_R_bigmemory_7.sh

The corresponding R scripts executed by the PBS scripts are: 
    * tutorial_bigmemory_0.R
    * tutorial_bigmemory_1.R
    * tutorial_bigmemory_2.R
    * tutorial_bigmemory_3.R
    * tutorial_bigmemory_4.R
    * tutorial_bigmemory_5.R
    * tutorial_bigmemory_6.R

The data the R scripts consume comes from:
    [http://stat-computing.org/dataexpo/2009/the-data.html]

Preprocessing of the raw csv files is perforemd by 2 c/c++ 
command-line applications that need to be compiled.
These are:
    1. clean_to_ascii.c
    2. map_fields.cpp

The first of these is used to removed non-ascii characters from 2 of the 
flight details CSV files.

The second is used to replace string field values with integer values
as big.matrix has to have elements that are uniformly some numerical
type (which in this case are integers).