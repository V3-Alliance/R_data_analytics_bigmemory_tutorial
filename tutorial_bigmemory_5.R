# Tutorial 5: High Performance Data Analytics with R (package: bigmemory) 

# Execute this code like so:
# $ qsub pbs_R_bigmemory_5.sh

# This example concatenates a group of big.matrix binary files into one humungous big.matrix file.
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

# See: tutorial_bigmemory_4.R

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
input_folder_path <- paste(project_storage_path, "big_matrices", sep = "/")
output_folder_path <- paste(project_storage_path, "big_matrices", sep = "/")

# ============================================================
# Function definitions.

attach_bigmatrix = function (file_name_desc) {
	file_path_desc <- paste(input_folder_path, file_name_desc, sep = "/")
	cat("\nFile: ", file_name_desc, "\n")
	datadesc <- dget(file_path_desc)
	matrix_0 = attach.big.matrix(datadesc, path=input_folder_path)
	return(matrix_0)
}

# ============================================================

matrix_list = list()
row_count <- 0
col_count <- 0

file_names <- list.files(path = input_folder_path, pattern = "^\\d{4}\\.desc$")

file_count <- length(file_names)
cat("\nFile count: ", file_count, "\n")

# Adjust this value if we need to restart the processing
# while skipping files already processed.

# Set to 1 if we just want to process the last file.
#file_count_0 <- 1
# Set to file_count if we want to process all files.
file_count_0 <- file_count

file_index_start <- file_count - file_count_0 + 1

# Create a list of matrices by attaching binary matrix files.

for (file_index in file_index_start:file_count) {

	# Benchmark start time.
	start_time <- Sys.time()

	file_name_desc <- file_names[file_index]
	part_matrix <- attach_bigmatrix(file_name_desc)
	
	matrix_list <- c(matrix_list, part_matrix)
	row_count <- row_count + nrow(part_matrix)
	col_count <- ncol(part_matrix)
		
	# Benchmark stop time and record duration.
	duration = difftime(Sys.time(), start_time, units = "secs")
	cat("\nAttach memory mapped matrix file duration/sec: ", duration, "\n")
	
}

# Allocate the whole result matrix.	

full_matrix <- filebacked.big.matrix(row_count, col_count, type="integer", init=NULL, 
	dimnames = NULL, separated = FALSE, 
	backingfile = "all.matrix", backingpath = output_folder_path, descriptorfile = "all.matrix.desc")

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
	cat("\nAppend matrix to combined matrix duration/sec: [", matrix_index, "] ", duration, "\n")

}
   
# ============================================================

# Clear out the workspace.
#rm(list = ls())