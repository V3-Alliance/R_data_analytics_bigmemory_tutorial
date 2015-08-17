# Tutorial 3: High Performance Data Analytics with R (package: bigmemory) 

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

# Setup:
# Within the R environment verify that the bigmemory packages is installed.
# > installed.packages('bigmemory')
# If it is not, install it like so:
# > install.packages('bigmemory')

library(bigmemory)

# ============================================================

read_csv_file_into_bigmatrix = function (file_name_csv) {
	cat("\nFile: ", file_name_csv)
	file_path_csv <- paste(project_storage_path, file_name_csv, sep = "/")
	base_name = strsplit(file_name_csv, "\\.")[[1]][1]
	matrix_file_name = paste(base_name, "matrix", sep = ".")
	matrix_file_path = paste(project_storage_path, matrix_file_name, sep = "/")
	matrix_0 = read.big.matrix(file_path_csv, sep = ',', header = TRUE, 
	    col.names = NULL, row.names = NULL, has.row.names=FALSE, ignore.row.names=FALSE,
	    type = NA, skip = 0, separated = FALSE,
	    backingfile = matrix_file_name , backingpath = "/lustre/pVPAC0012/")
	    #backingfile = NULL , backingpath = NULL) Causes the Out of memory killer to kill the process.
	flush(matrix_0)
}

# ============================================================

project_storage_path = "/lustre/pVPAC0012"
file_names <- list.files(path = project_storage_path, pattern = "^\\d{4}\\.csv$")
file_count <- length(file_names)
for (file_index in 1:file_count) {

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