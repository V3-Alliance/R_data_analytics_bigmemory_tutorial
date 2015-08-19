# Tutorial 6: High Performance Data Analytics with R (package: bigmemory) 

# This example queries the humungous big.matrix file.
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
# Constants.

project_storage_path = "/lustre/pVPAC0012"

# ============================================================
# Function definitions.

attach_bigmatrix = function (file_name_desc) {
	file_path_desc <- paste(project_storage_path, file_name_desc, sep = "/")
	cat("\nFile: ", file_name_desc, "\n")
	datadesc <- dget(file_path_desc)
	matrix_0 = attach.big.matrix(datadesc, path=project_storage_path)
	return(matrix_0)
}

# ============================================================

# Attach the whole result matrix.	

# Benchmark start time.
start_time <- Sys.time()

full_matrix <- attach_bigmatrix("all.matrix.desc")

# Benchmark stop time and record duration.
duration = difftime(Sys.time(), start_time, units = "secs")
cat("\nAttach all matrix duration/sec: ", duration, "\n")

# Query the whole result matrix.
# Find indicies of long flights whose time is greater than 120 minutes.
# ActualElapsedTime is at column 12

# Benchmark start time.
start_time <- Sys.time()

long_flight_indices <- mwhich(full_matrix, 12, 1800, 'ge')
cat("\nLong flight count: ", length(long_flight_indices), "\n")
for (flight_index in long_flight_indices) {
	cat("\nFlight number: ", full_matrix[flight_index, 10], "(distance/mi = ", full_matrix[flight_index, 19], ")\n")	
}

# Benchmark stop time and record duration.
duration = difftime(Sys.time(), start_time, units = "secs")
cat("\nQuery duration/sec: ", duration, "\n")
   
# ============================================================

# Clear out the workspace.
#rm(list = ls())