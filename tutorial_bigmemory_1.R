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
  
# Trial size
iteration_count <- 10

#row_count <- 5
#column_count <- 2

row_count <- 5000
column_count <- 2000

# -----------------------------------
# Benchmark 1 start time.
start_time <- Sys.time()

data0 <- big.matrix(row_count, column_count, type="double", init = 0.0, dimnames=list(NULL, c("alpha", "beta")))

# Generate some random numbers, store them in the data matrix.
# The process id is reported as this will be helpful info when running on a cluster node.
for (iteration_index in 1:iteration_count) { 
    cat("PID: ", Sys.getpid(), " Iteration: ", iteration_index,'\n') 
	# Insert rows of uniform random numbers in the range 0 to 1
	for (row_index in 1:row_count) {
		data0[row_index,] <- runif(column_count, 0, 1)
	}
}

# Benchmark 1 stop time and record duration as a function of iteration count.
cat("Insert rows duration/sec: ", Sys.time() - start_time)

# -----------------------------------
# Benchmark 2 start time.
start_time <- Sys.time()

data1 <- big.matrix(row_count, column_count, type="double", init = 0.0, dimnames=list(NULL, c("alpha", "beta")))

# Generate some random numbers, store them in the data matrix.
# The process id is reported as this will be helpful info when running on a cluster node.
for (iteration_index in 1:iteration_count) { 
    cat("PID: ", Sys.getpid(), " Iteration: ", iteration_index,'\n') 
	# Insert columns of uniform random numbers in the range 0 to 1
	for (column_index in 1:column_count) {
		data1[,column_index] <- runif(row_count, 0, 1)
	}
}

# Benchmark 2 stop time and record duration as a function of iteration count.
cat("Insert columns duration/sec: ", Sys.time() - start_time)

# -----------------------------------

