# Tutorial 3: High Performance Data Analytics with R (package: bigmemory) 

# Execute this code like so:
# $ qsub pbs_R_bigmemory_3.sh

# This example reads a group of csv data files 
# and generates corresponding big.matrices that are file-backed.
# Concatenating the big.matrices into one is left to tutorial_bigmemory_4.R
# It does not use cluster computing.
# It does demonstrated how to benchmark R code for performance.

# This example shows:
# 1. how to refactor code into subroutines
# 2. how to calculate time differences in seconds.
# 4. How to display progress information.
# 6. How to manage very large data sets in the R environment.

# bigmemory provides only core functionality and depends on 
# the packages synchronicity, biganalytics, bigalgebra, bigtabulate
# to actually do stuff.

# ============================================================
# Preparing the dataset.

# Navigate to your project directory:
# $ cd /lustre/pVPAC0012
# Replacing pVPAC0012 with the name of your VPAC project as seen in your account area at:
# <https://hpc.v3.org.au/accounts/profile/projects/>

# To download the files:
# The original data comes from:
# <http://stat-computing.org/dataexpo/2009/the-data.html>
# <http://www.transtats.bts.gov/DL_SelectFields.asp?Table_ID=236>
# $ wget http://stat-computing.org/dataexpo/2009/{1987..2007}.csv.bz2

# To unpack the files:
# $ bunzip2 *.bz2

# Compile the cleaner application:
# $ gcc -W clean_to_ascii.c -o clean_to_ascii

# Clean 2 offending files:
# $ ./clean_to_ascii /lustre/pVPAC0012/2001.csv /lustre/p2PAC0012/2001.clean.csv
# $ mv 2001.csv 2001.csv.orig; mv 2001.clean.csv 2001.csv
# $ ./clean_to_ascii /lustre/pVPAC0012/2002.csv /lustre/p2PAC0012/2002.clean.csv
# $ mv 2002.csv 2002.csv.orig; mv 2002.clean.csv 2002.csv

# ============================================================
# Setup:

# Within the R environment verify that the bigmemory packages is installed.
# > installed.packages('bigmemory')
# If it is not, install it like so:
# > install.packages('bigmemory')

library(bigmemory)

# ============================================================
# Constants

project_storage_path <- "/lustre/pVPAC0012"
input_folder_path <- paste(project_storage_path, "preprocessed", sep = "/")
output_folder_path <- paste(project_storage_path, "big_matrices", sep = "/")

# ============================================================
# Define functions.

read_csv_file_into_bigmatrix = function (file_name_csv) {
	cat("\nFile: ", file_name_csv)
	file_path_csv <- paste(input_folder_path, file_name_csv, sep = "/")
	base_name = strsplit(file_name_csv, "\\.")[[1]][1]
	matrix_file_name = paste(base_name, "matrix", sep = ".")
	desc_file_name = paste(base_name, "desc", sep = ".")
	# matrix_file_path = paste(project_storage_path, matrix_file_name, sep = "/")
	matrix_0 = read.big.matrix(file_path_csv, sep = ',', header = TRUE, 
	    col.names = NULL, row.names = NULL, has.row.names=FALSE, ignore.row.names=FALSE,
	    type = "integer", skip = 0, separated = FALSE,
	    backingfile = matrix_file_name , backingpath = output_folder_path, 
	    descriptorfile = desc_file_name)
	    #backingfile = NULL , backingpath = NULL) Causes the Out Of Memory (OOM) daemon to kill the process.
	flush(matrix_0)
}

# ============================================================

file_names <- list.files(path = input_folder_path, pattern = "^\\d{4}\\.csv$")
file_count <- length(file_names)
file_index_start <- 1
#file_index_start <- 18
for (file_index in file_index_start:file_count) {

	# Benchmark start time.
	start_time <- Sys.time()

	file_name_csv <- file_names[file_index]
	read_csv_file_into_bigmatrix(file_name_csv)
	
	# Benchmark stop time and record duration.
	duration = difftime(Sys.time(), start_time, units="secs")
	cat("\nRead file into matrix duration/sec: ", duration)
}
   
# ============================================================

# Clear out the workspace.
#rm(list = ls())