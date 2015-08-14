# Tutorial 1: High Performance Data Analytics with R (package: bigmemory) 

# This example tests how column vs row population of big.matrix affects exection time.
# It does not use cluster computing.
# It does demonstrated how to benchmark R code for performance.

# bigmemory provides only core functionality and depends on 
# the packages synchronicity, biganalytics, bigalgebra, bigtabulate
# to actually do stuff.

# ============================================================

# Measure how a calculation's duration scales with calculation complexity.
# The results are output to the R console.

# Setup:
# Within the R environment verify that the bigmemory package is installed.
# > installed.packages('bigmemory')
# If it is not install it like so:
# > install.packages('bigmemory')

library(bigmemory)

# ============================================================

iteration_count <- 10

populate_rows <- function(row_count, column_count) {

	data0 <- big.matrix(row_count, column_count, type="double", init = 0.0, dimnames=list(NULL, c("alpha", "beta")))

	cat("\nStart benchmark populate rows: ", "Rows=", row_count, "Cols=", column_count, '\n') 
	# Generate some random numbers, store them in the data matrix.
	# The process id is reported as this will be helpful info when running on a cluster node.
	for (iteration_index in 1:iteration_count) { 
		cat("PID (rows): ", Sys.getpid(), " Iteration: ", iteration_index,'\n') 
		# Insert rows of uniform random numbers in the range 0 to 1
		for (row_index in 1:row_count) {
			data0[row_index,] <- runif(column_count, 0, 1)
		}
	}
}

populate_columns <- function(row_count, column_count) {

	data1 <- big.matrix(row_count, column_count, type="double", init = 0.0, dimnames=list(NULL, c("alpha", "beta")))

	cat("\nStart benchmark populate columns: ", "Rows=", row_count, "Cols=", column_count, '\n') 
	# Generate some random numbers, store them in the data matrix.
	# The process id is reported as this will be helpful info when running on a cluster node.
	for (iteration_index in 1:iteration_count) { 
		cat("PID (columns): ", Sys.getpid(), " Iteration: ", iteration_index,'\n') 
		# Insert columns of uniform random numbers in the range 0 to 1
		for (column_index in 1:column_count) {
			data1[,column_index] <- runif(row_count, 0, 1)
		}
	}
}

# ============================================================
  
# Trial size
trial_count = 10
trial_scale = 10


# Data matrix size.
row_count_0 <- 2
column_count_0 <- 5

# Allocate storage for results
# Count results.
matrix_size <- numeric(trial_count)
# Timing results.
durations0 <- numeric(trial_count)
durations1 <- numeric(trial_count)

# Iterate the trial while varying the trial parameters.
for(trial_index in 1:trial_count) {
    
    # Exercise the function we are benchmarking.
    scale <- trial_index * trial_scale 
    row_count = row_count_0 * scale
    column_count  =  column_count_0 * scale 
	matrix_size [trial_index] <-  row_count * column_count 

    # ---------------------------- 
       
	# Benchmark 1 start time.
	start_time <- Sys.time()

 	populate_rows(row_count, column_count)
 	
    # Benchmark stop time and record duration as a function of iteration count.
    durations0 [trial_index] <- Sys.time() - start_time

	# Benchmark 1 stop time and record duration as a function of iteration count.
	cat("Insert rows duration/sec: ", Sys.time() - start_time)
    
    # ----------------------------    

	# Benchmark 2 start time.
	start_time <- Sys.time()

 	populate_columns(row_count, column_count)
 	
    # Benchmark stop time and record duration as a function of iteration count.
    durations1 [trial_index] <- Sys.time() - start_time

	# Benchmark 2 stop time and record duration as a function of iteration count.
	cat("Insert columns duration/sec: ", Sys.time() - start_time)
	
    # ----------------------------    
}


# ============================================================

