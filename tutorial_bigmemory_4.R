# Tutorial 4: High Performance Data Analytics with R (package: bigmemory) 

# This example concatenates a group of csv data files so they can be processed by bigmemory.
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

project_storage_path = "/lustre/pVPAC0012"

# ============================================================
# Function definitions

read_csv_file_into_bigmatrix = function (file_name_csv) {
	cat("\nFile: ", file_name_csv, "\n")
	file_path_csv <- paste(project_storage_path, file_name_csv, sep = "/")
	base_name = strsplit(file_name_csv, "\\.")[[1]][1]
	matrix_file_name = paste(base_name, "matrix", sep = ".")
	desc_file_name = paste(base_name, "desc", sep = ".")
	matrix_file_path = paste(project_storage_path, matrix_file_name, sep = "/")
	matrix_0 = read.big.matrix(file_path_csv, sep = ',', header = TRUE, 
	    col.names = NULL, row.names = NULL, has.row.names=FALSE, ignore.row.names=FALSE,
	    type = NA, skip = 0, separated = FALSE,
	    backingfile = matrix_file_name, backingpath = project_storage_path,
	    descriptor = desc_file_name)
	flush(matrix_0)
	return(matrix_0)
}

# ============================================================

matrix_list = list()
row_count <- 0
col_count <- 0

file_names <- list.files(path = project_storage_path, pattern = "^\\d{4}\\.csv$")

file_count <- length(file_names)
cat("\nFile count: ", file_count, "\n")

# Adjust this value if we need to restart the processing
# while skipping files already processed.

# Set to 1 if we just want to process the last file.
#file_count_0 <- 1
# Set to file_count if we want to process all files.
file_count_0 <- file_count

file_index_start <- file_count - file_count_0 + 1

# Create a list of matrices by reading files.

for (file_index in file_index_start:file_count) {

	# Benchmark start time.
	start_time <- Sys.time()

	file_name_csv <- file_names[file_index]
	part_matrix <- read_csv_file_into_bigmatrix(file_name_csv)
	
	matrix_list <- c(matrix_list, part_matrix)
	row_count <- row_count + nrow(part_matrix)
	col_count <- ncol(part_matrix)
		
	# Benchmark stop time and record duration.
	duration = difftime(Sys.time(), start_time, units = "secs")
	cat("\nRead file into matrix duration/sec: ", duration, "\n")
	
}

# Allocate the whole result matrix.	

full_matrix <- filebacked.big.matrix(row_count, col_count, type="integer", init=NULL, 
	dimnames = NULL, separated = FALSE, 
	backingfile = "all.matrix", backingpath = project_storage_path, descriptorfile = "all.matrix.desc")

# Populate the whole result matrix.

row_end_index <- 0
row_start_index <- row_end_index + 1
matrix_count <- length(matrix_list)
matrix_index_start <- file_index_start
for (matrix_index in 1:matrix_count) {

	# Benchmark start time.
	start_time <- Sys.time()

	current_matrix <- matrix_list[[matrix_index]]
	row_end_index <- row_start_index + nrow(current_matrix) - 1
    full_matrix[row_start_index:row_end_index, ] <- current_matrix[,]
    row_start_index <- row_end_index + 1		

	# Benchmark stop time and record duration.
	duration = difftime(Sys.time(), start_time, units = "secs")
	cat("\nAppend matrix to all matrix duration/sec: ", duration, "\n")

}
   
# ============================================================

# Clear out the workspace.
#rm(list = ls())